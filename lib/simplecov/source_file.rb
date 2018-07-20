# frozen_string_literal: true

module SimpleCov
  #
  # Representation of a source file including it's coverage data, source code,
  # source lines and featuring helpers to interpret that data.
  #
  class SourceFile # rubocop:disable Metrics/ClassLength
    # Representation of a single line in a source file including
    # this specific line's source code, line_number and code coverage,
    # with the coverage being either nil (coverage not applicable, e.g. comment
    # line), 0 (line not covered) or >1 (the amount of times the line was
    # executed)
    class Line
      # The source code for this line. Aliased as :source
      attr_reader :src
      # The line number in the source file. Aliased as :line, :number
      attr_reader :line_number
      # The coverage data for this line: either nil (never), 0 (missed) or >=1 (times covered)
      attr_reader :coverage
      # Whether this line was skipped
      attr_reader :skipped

      # Lets grab some fancy aliases, shall we?
      alias source src
      alias line line_number
      alias number line_number

      def initialize(src, line_number, coverage)
        raise ArgumentError, "Only String accepted for source" unless src.is_a?(String)
        raise ArgumentError, "Only Integer accepted for line_number" unless line_number.is_a?(Integer)
        raise ArgumentError, "Only Integer and nil accepted for coverage" unless coverage.is_a?(Integer) || coverage.nil?
        @src         = src
        @line_number = line_number
        @coverage    = coverage
        @skipped     = false
      end

      # Returns true if this is a line that should have been covered, but was not
      def missed?
        !never? && !skipped? && coverage.zero?
      end

      # Returns true if this is a line that has been covered
      def covered?
        !never? && !skipped? && coverage > 0
      end

      # Returns true if this line is not relevant for coverage
      def never?
        !skipped? && coverage.nil?
      end

      # Flags this line as skipped
      def skipped!
        @skipped = true
      end

      # Returns true if this line was skipped, false otherwise. Lines are skipped if they are wrapped with
      # # :nocov: comment lines.
      def skipped?
        !!skipped
      end

      # The status of this line - either covered, missed, skipped or never. Useful i.e. for direct use
      # as a css class in report generation
      def status
        return "skipped" if skipped?
        return "never" if never?
        return "missed" if missed?
        return "covered" if covered?
      end
    end

    #
    # Representing single branch that been detected in coverage report
    # Give us support methods that handle neede calculations
    class Branch
      attr_reader :type,
                  :id,
                  :start_line,
                  :start_col,
                  :end_line,
                  :end_col

      attr_accessor :coverage

      def initialize(*branch_attrs)
        @type       = branch_attrs[0]
        @id         = branch_attrs[1]
        @start_line = branch_attrs[2]
        @start_col  = branch_attrs[3]
        @end_line   = branch_attrs[4]
        @end_col    = branch_attrs[5]
        @coverage   = 0
      end

      #
      # Return true if there is relevant count defined > 0
      #
      # @return [Boolean]
      #
      def covered?
        coverage > 0
      end

      #
      # Check if branche missed or not
      #
      # @return [Boolean]
      #
      def missed?
        coverage.zero?
      end

      #
      # Check if branch covers the line in it's range
      # @param [Integer] line_number
      #
      # @return [Boolean]
      #
      def cover_line?(line_number)
        (start_line..end_line).cover?(line_number)
      end
    end

    # The full path to this source file (e.g. /User/colszowka/projects/simplecov/lib/simplecov/source_file.rb)
    attr_reader :filename
    # The array of coverage data received from the Coverage.result
    attr_reader :coverage

    def initialize(filename, coverage)
      @filename = filename
      @coverage = coverage
    end

    # The path to this source file relative to the projects directory
    def project_filename
      @filename.sub(/^#{SimpleCov.root}/, "")
    end

    # The source code for this file. Aliased as :source
    def src
      # We intentionally read source code lazily to
      # suppress reading unused source code.
      @src ||= File.open(filename, "rb", &:readlines)
    end
    alias source src

    # Returns all source lines for this file as instances of SimpleCov::SourceFile::Line,
    # and thus including coverage data. Aliased as :source_lines
    def lines
      @lines ||= build_lines
    end
    alias source_lines lines

    def build_lines
      coverage_exceeding_source_warn if coverage[:lines].size > src.size

      lines = src.map.with_index(1) do |src, i|
        SimpleCov::SourceFile::Line.new(src, i, coverage[:lines][i - 1])
      end

      process_skipped_lines(lines)
    end

    def branches
      @branches ||= build_branches
    end

    #
    # Call recursive method that transform our static hash to array of objects
    # @return [Array]
    #
    def build_branches
      branches_collection(coverage[:branches] || {})
    end

    #
    # Recursive method brings all of the branches as array of objects
    # In logic here we collect only the positive or negative branch,
    # not the first called branch for it
    #
    # @param [Hash] given_branches
    #
    # @return [Array]
    #
    def branches_collection(given_branches)
      @branches_collection ||= []

      given_branches.each do |branch_args, value|
        branch = SimpleCov::SourceFile::Branch.new(*branch_args)

        if value.is_a?(Integer)
          branch.coverage = value
          @branches_collection << branch
        else
          branches_collection(value)
        end
      end

      @branches_collection
    end

    # Warning to identify condition from Issue #56
    def coverage_exceeding_source_warn
      $stderr.puts "Warning: coverage data provided by Coverage [#{coverage.size}] exceeds number of lines in #{filename} [#{src.size}]"
    end

    # Access SimpleCov::SourceFile::Line source lines by line number
    def line(number)
      lines[number - 1]
    end

    # The coverage for this file in percent. 0 if the file has no coverage lines
    def covered_percent
      return 100.0 if no_lines?

      return 0.0 if relevant_lines.zero?

      Float(covered_lines.size * 100.0 / relevant_lines.to_f)
    end

    def covered_strength
      return 0.0 if relevant_lines.zero?

      round_float(lines_strength / relevant_lines.to_f, 1)
    end

    def no_lines?
      lines.length.zero? || (lines.length == never_lines.size)
    end

    def lines_strength
      lines.map(&:coverage).compact.reduce(:+)
    end

    def relevant_lines
      lines.size - never_lines.size - skipped_lines.size
    end

    # Returns all covered lines as SimpleCov::SourceFile::Line
    def covered_lines
      @covered_lines ||= lines.select(&:covered?)
    end

    # Returns all lines that should have been, but were not covered
    # as instances of SimpleCov::SourceFile::Line
    def missed_lines
      @missed_lines ||= lines.select(&:missed?)
    end

    # Returns all lines that are not relevant for coverage as
    # SimpleCov::SourceFile::Line instances
    def never_lines
      @never_lines ||= lines.select(&:never?)
    end

    # Returns all lines that were skipped as SimpleCov::SourceFile::Line instances
    def skipped_lines
      @skipped_lines ||= lines.select(&:skipped?)
    end

    # Returns the number of relevant lines (covered + missed)
    def lines_of_code
      covered_lines.size + missed_lines.size
    end

    # Will go through all source files and mark lines that are wrapped within # :nocov: comment blocks
    # as skipped.
    def process_skipped_lines(lines)
      skipping = false

      lines.each do |line|
        if SimpleCov::LinesClassifier.no_cov_line?(line.src)
          skipping = !skipping
          line.skipped!
        elsif skipping
          line.skipped!
        end
      end
    end

    #
    # Selelect the covered branches
    #
    # @return [Array]
    #
    def covered_branches
      branches.select(&:covered?)
    end

    #
    # Return the relevant branches to source file
    #
    # @return [Array]
    #
    def relevant_branches
      covered_branches + missed_branches
    end

    #
    # Select the missed branches with coverage equal to zero
    #
    # @return [Array]
    #
    def missed_branches
      branches.select(&:missed?)
    end

    # Check if any of the file branches covers the given line number
    #
    # @param [Integer] line_number
    #
    # @return [Object <Branch>]
    #
    def on_branch(line_number)
      branches.select do |branch|
        branch.cover_line?(line_number) && branch.covered?
      end.first
    end

    def branch_covered?(line_number)
      branches.select do |branch|
        branch.cover_line?(line_number) && branch.covered?
      end.any?
    end

  private

    # ruby 1.9 could use Float#round(places) instead
    # @return [Float]
    def round_float(float, places)
      factor = Float(10 * places)
      Float((float * factor).round / factor)
    end
  end
end

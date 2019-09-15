# frozen_string_literal: true

# An array of SimpleCov SourceFile instances with additional collection helper
# methods for calculating coverage across them etc.
module SimpleCov
  class FileList < Array
    # Returns the count of lines that have coverage
    def covered_lines
      map { |f| f.covered_lines.count }.sum
    end

    # Returns the count of lines that have been missed
    def missed_lines
      map { |f| f.missed_lines.count }.sum
    end

    # Returns the count of lines that are not relevant for coverage
    def never_lines
      map { |f| f.never_lines.count }.sum
    end

    # Returns the count of skipped lines
    def skipped_lines
      map { |f| f.skipped_lines.count }.sum
    end

    # Computes the coverage based upon lines covered and lines missed for each file
    # Returns an array with all coverage percentages
    def covered_percentages
      map(&:covered_percent)
    end

    # Finds the least covered file and returns that file's name
    def least_covered_file
      sort_by(&:covered_percent).first.filename
    end

    # Returns the overall amount of relevant lines of code across all files in this list
    def lines_of_code
      covered_lines + missed_lines
    end

    # Computes the coverage based upon lines covered and lines missed
    # @return [Float]
    def covered_percent
      return 100.0 if empty? || lines_of_code.zero?
      Float(covered_lines * 100.0 / lines_of_code)
    end

    # Computes the strength (hits / line) based upon lines covered and lines missed
    # @return [Float]
    def covered_strength
      return 0.0 if empty? || lines_of_code.zero?
      Float(map { |f| f.covered_strength * f.lines_of_code }.sum / lines_of_code)
    end

    # Return total count of branches in all files
    def total_branches
      map { |file| file.total_branches.count }.sum
    end

    alias relevant_branches total_branches

    # Return total count of covered branches
    def covered_branches
      map { |file| file.covered_branches.count }.sum
    end

    # Return total count of covered branches
    def missed_branches
      map { |file| file.missed_branches.count }.sum
    end

    def covered_methods
      map { |file| file.covered_methods.count }.sum
    end

    def relevant_methods
      map { |file| file.relevant_methods.count }.sum
    end

    def covered_methods_percent
      covered_methods * 100.0 / relevant_methods.to_f
    end

    def relevant_lines
      map(&:relevant_lines).sum
    end

    def covered_branches_percent
      covered_branches * 100.0 / relevant_branches.to_f
    end
  end
end

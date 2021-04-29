# frozen_string_literal: true

require "digest/sha1"
require "forwardable"

module SimpleCov
  #
  # A simplecov code coverage result, initialized from the Hash Ruby's built-in coverage
  # library generates (Coverage.result).
  #
  class Result
    extend Forwardable
    # Instance of SimpleCov used for generation of result. Defaults to SimpleCov.instance
    attr_reader :instance
    # Returns the original Coverage.result used for this instance of SimpleCov::Result
    attr_reader :original_result
    # Returns all files that are applicable to this result (sans filters!) as instances of SimpleCov::SourceFile. Aliased as :source_files
    attr_reader :files
    alias source_files files
    # Explicitly set the Time this result has been created
    attr_writer :created_at
    # Explicitly set the command name that was used for this coverage result. Defaults to SimpleCov.command_name
    attr_writer :command_name

    def_delegators :files, :covered_percent, :covered_percentages, :least_covered_file, :covered_strength,
                   :covered_lines, :missed_lines, :total_branches, :covered_branches, :missed_branches,
                   :coverage_statistics, :coverage_statistics_by_file
    def_delegator :files, :lines_of_code, :total_lines

    # Initialize a new SimpleCov::Result from given Coverage.result (a Hash of filenames each containing an array of
    # coverage data)
    def initialize(original_result, command_name: nil, created_at: nil, instance: SimpleCov.instance)
      result = original_result

      @instance = instance
      @original_result = result.freeze
      @command_name = command_name
      @created_at = created_at

      source_files = result.map do |filename, coverage|
        SimpleCov::SourceFile.new(filename, coverage, instance: instance) if File.file?(filename)
      end

      @files = SimpleCov::FileList.new(source_files.compact.sort_by(&:filename), instance: instance)

      filter!
    end

    # Returns all filenames for source files contained in this result
    def filenames
      files.map(&:filename)
    end

    # Returns a Hash of groups for this result. Define groups using SimpleCov.add_group 'Models', 'app/models'
    def groups
      @groups ||= instance.grouped(files)
    end

    # Applies the configured SimpleCov.formatter on this result
    def format!
      instance.formatter.new.format(self)
    end

    # Defines when this result has been created. Defaults to Time.now
    def created_at
      @created_at ||= Time.now
    end

    # The command name that launched this result.
    # Delegated to SimpleCov.command_name if not set manually
    def command_name
      @command_name ||= instance.command_name
    end

    # Returns a hash representation of this Result that can be used for marshalling it into JSON
    def to_hash
      SimpleCov::ResultSerialization.serialize(self)
    end

    # Loads a SimpleCov::Result#to_hash dump
    def self.from_hash(hash, instance: SimpleCov.instance)
      SimpleCov::ResultSerialization.deserialize(hash, instance: instance)
    end

  private

    def coverage
      keys = original_result.keys & filenames
      Hash[keys.zip(original_result.values_at(*keys))]
    end

    # Applies all configured SimpleCov filters on this result's source files
    def filter!
      @files = instance.filtered(files)
    end
  end
end

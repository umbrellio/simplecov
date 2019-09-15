# frozen_string_literal: true

require "English"
require "coverage"

#
# Code coverage for ruby. Please check out README for a full introduction.
#
# Coverage may be inaccurate under JRUBY.
if defined?(JRUBY_VERSION) && defined?(JRuby)

  # @see https://github.com/jruby/jruby/issues/1196
  # @see https://github.com/metricfu/metric_fu/pull/226
  # @see https://github.com/colszowka/simplecov/issues/420
  # @see https://github.com/colszowka/simplecov/issues/86
  # @see https://jira.codehaus.org/browse/JRUBY-6106

  unless org.jruby.RubyInstanceConfig.FULL_TRACE_ENABLED
    warn 'Coverage may be inaccurate; set the "--debug" command line option,' \
      ' or do JRUBY_OPTS="--debug"' \
      ' or set the "debug.fullTrace=true" option in your .jrubyrc'
  end
end
module SimpleCov
  class << self
    attr_accessor :running
    attr_accessor :pid
    attr_reader :exit_exception

    #
    # Sets up SimpleCov to run against your project.
    # You can optionally specify a profile to use as well as configuration with a block:
    #   SimpleCov.start
    #    OR
    #   SimpleCov.start 'rails' # using rails profile
    #    OR
    #   SimpleCov.start do
    #     add_filter 'test'
    #   end
    #     OR
    #   SimpleCov.start 'rails' do
    #     add_filter 'test'
    #   end
    #
    # Please check out the RDoc for SimpleCov::Configuration to find about available config options
    #
    def start(profile = nil, &block)
      load_profile(profile) if profile
      configure(&block) if block_given?
      @result = nil
      self.running = true
      self.pid = Process.pid
      start_coverage_measurment
    end

    #
    # Returns the result for the current coverage run, merging it across test suites
    # from cache using SimpleCov::ResultMerger if use_merging is activated (default)
    #
    def result
      return @result if result?
      # Collect our coverage result

      process_coverage_result if running

      # If we're using merging of results, store the current result
      # first (if there is one), then merge the results and return those
      if use_merging
        wait_for_other_processes
        SimpleCov::ResultMerger.store_result(@result) if result?
        @result = SimpleCov::ResultMerger.merged_result
      end

      @result
    ensure
      self.running = false
    end

    #
    # Returns nil if the result has not been computed
    # Otherwise, returns the result
    #
    def result?
      defined?(@result) && @result
    end

    #
    # Applies the configured filters to the given array of SimpleCov::SourceFile items
    #
    def filtered(files)
      result = files.clone
      filters.each do |filter|
        result = result.reject { |source_file| filter.matches?(source_file) }
      end
      SimpleCov::FileList.new result
    end

    #
    # Applies the configured groups to the given array of SimpleCov::SourceFile items
    #
    def grouped(files)
      grouped = {}
      grouped_files = []
      groups.each do |name, filter|
        grouped[name] = SimpleCov::FileList.new(files.select { |source_file| filter.matches?(source_file) })
        grouped_files += grouped[name]
      end
      if !groups.empty? && !(other_files = files.reject { |source_file| grouped_files.include?(source_file) }).empty?
        grouped["Ungrouped"] = SimpleCov::FileList.new(other_files)
      end
      grouped
    end

    #
    # Applies the profile of given name on SimpleCov configuration
    #
    def load_profile(name)
      profiles.load(name)
    end

    def load_adapter(name)
      warn "#{Kernel.caller.first}: [DEPRECATION] #load_adapter is deprecated. Use #load_profile instead."
      load_profile(name)
    end

    #
    # Clear out the previously cached .result. Primarily useful in testing
    #
    def clear_result
      @result = nil
    end

    #
    # Capture the current exception if it exists
    # This will get called inside the at_exit block
    #
    def set_exit_exception
      @exit_exception = $ERROR_INFO
    end

    #
    # Returns the exit status from the exit exception
    #
    def exit_status_from_exception
      return SimpleCov::ExitCodes::SUCCESS unless exit_exception

      if exit_exception.is_a?(SystemExit)
        exit_exception.status
      else
        SimpleCov::ExitCodes::EXCEPTION
      end
    end

    # @api private
    #
    # Called from at_exit block
    #
    def run_exit_tasks!
      exit_status = SimpleCov.exit_status_from_exception

      SimpleCov.at_exit.call

      # Don't modify the exit status unless the result has already been computed
      exit_status = SimpleCov::ResultProcessor.call(SimpleCov.result, exit_status) if SimpleCov.result?

      # Force exit with stored status (see github issue #5)
      # unless it's nil or 0 (see github issue #281)
      if exit_status && exit_status.positive?
        $stderr.printf("SimpleCov failed with exit %d\n", exit_status)
        Kernel.exit exit_status
      end
    end

    #
    # @api private
    #
    def final_result_process?
      !defined?(ParallelTests) || ParallelTests.last_process?
    end

    #
    # @api private
    #
    def wait_for_other_processes
      return unless defined?(ParallelTests) && final_result_process?
      ParallelTests.wait_for_other_processes_to_finish
    end

  private

    #
    # Trigger Coverage.start depends on given config use_branchable_report
    #
    # With Positive branch it supports all coverage measurement types
    # With Negative branch it supports only line coverage measurement type
    #
    def start_coverage_measurment
      if branchable_report
        Coverage.start(:all)
      else
        Coverage.start
      end
    end

    #
    # Finds files that were to be tracked but were not loaded and initializes
    # the line-by-line coverage to zero (if relevant) or nil (comments / whitespace etc).
    #
    def add_not_loaded_files(result)
      if tracked_files
        result = result.dup
        Dir[tracked_files].each do |file|
          absolute = File.expand_path(file)
          result[absolute] ||= RunFileCoverage.start(absolute)
        end
      end

      result
    end

    #
    # Unite the result so it wouldn't matter what coverage type was called
    #
    # @return [Hash]
    #
    def adapt_coverage_result
      @result = SimpleCov::ResultAdapter.call(Coverage.result)
    end

    #
    # Filter coverage result
    # The result before filter also has result of coverage for files
    # are not related to the project like loaded gems coverage.
    #
    # @return [Hash]
    #
    def remove_useless_results
      @result = SimpleCov::UselessResultsRemover.call(@result)
    end

    #
    # Initialize result with files that are not included by coverage
    # and added inside the config block
    #
    # @return [Hash]
    #
    def result_with_not_loaded_files
      @result = SimpleCov::Result.new(add_not_loaded_files(@result))
    end

    #
    # Call steps that handle process coverage result
    #
    # @return [Hash]
    #
    def process_coverage_result
      adapt_coverage_result
      remove_useless_results
      result_with_not_loaded_files
    end
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))
require "simplecov/configuration"
SimpleCov.send :extend, SimpleCov::Configuration
require "simplecov/exit_codes"
require "simplecov/profiles"
require "simplecov/supports/branch_support"
require "simplecov/supports/source_file_support"
require "simplecov/source_file"
require "simplecov/file_list"
require "simplecov/result"
require "simplecov/filter"
require "simplecov/formatter"
require "simplecov/last_run"
require "simplecov/lines_classifier"
require "simplecov/result_merger"
require "simplecov/result_processor"
require "simplecov/command_guesser"
require "simplecov/version"
require "simplecov/result_adapter"
require "simplecov/result_serialization"
require "simplecov/combiners/base_combiner"
require "simplecov/combiners/branches_combiner"
require "simplecov/combiners/files_combiner"
require "simplecov/combiners/lines_combiner"
require "simplecov/combiners/methods_combiner"
require "simplecov/run_results_combiner"
require "simplecov/branches_per_file"
require "simplecov/useless_results_remover"
require "simplecov/run_file_coverage"

# Load default config
require "simplecov/defaults" unless ENV["SIMPLECOV_NO_DEFAULTS"]

# Load Rails integration
require "simplecov/railtie" if defined? Rails::Railtie

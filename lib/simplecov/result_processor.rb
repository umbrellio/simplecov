# frozen_string_literal: true

# Class responsible for processing the result and generating exit code.
# Also writes last run result in case of a successful run.
module SimpleCov
  class ResultProcessor
    def self.call(*args)
      new(*args).call
    end

    def initialize(result, exit_status = SimpleCov::ExitCodes::SUCCESS)
      @result = result
      @exit_status = exit_status
    end

    def call
      return exit_status if exit_status != SimpleCov::ExitCodes::SUCCESS # Existing errors
      result_exit_status = get_result_exit_status(result)
      write_last_run if result_exit_status == SimpleCov::ExitCodes::SUCCESS # No result errors
      SimpleCov.final_result_process? ? result_exit_status : SimpleCov::ExitCodes::SUCCESS
    end

  private

    attr_reader :result, :exit_status

    def write_last_run
      SimpleCov::LastRun.write(:result => {:covered_percent => covered_percent})
    end

    def covered_percent
      @covered_percent ||= result.covered_percent.round(2)
    end

    def covered_percentages
      @covered_percentages ||= result.covered_percentages.map { |percentage| percentage.round(2) }
    end

    def get_result_exit_status(_result)
      low_line_coverage ||
        low_branch_coverage ||
        low_method_coverage ||
        low_file_coverage ||
        high_coverage_drop ||
        SimpleCov::ExitCodes::SUCCESS
    end

    def low_line_coverage
      return unless covered_percent < SimpleCov.minimum_coverage

      $stderr.printf(
        "Line coverage (%.2f%%) is below the expected minimum coverage (%.2f%%).\n",
        covered_percent, SimpleCov.minimum_coverage
      )

      SimpleCov::ExitCodes::MINIMUM_COVERAGE
    end

    def low_branch_coverage
      return unless result.covered_branches_percent < SimpleCov.minimum_branch_coverage

      $stderr.printf(
        "Branch coverage (%.2f%%) is below the expected minimum coverage (%.2f%%).\n",
        result.covered_branches_percent, SimpleCov.minimum_branch_coverage
      )

      SimpleCov::ExitCodes::MINIMUM_COVERAGE
    end

    def low_method_coverage
      return unless result.covered_methods_percent < SimpleCov.minimum_method_coverage

      $stderr.printf(
        "Method coverage (%.2f%%) is below the expected minimum coverage (%.2f%%).\n",
        result.covered_methods_percent, SimpleCov.minimum_method_coverage
      )

      SimpleCov::ExitCodes::MINIMUM_COVERAGE
    end

    def low_file_coverage
      return unless covered_percentages.any? { |p| p < SimpleCov.minimum_coverage_by_file }

      $stderr.printf(
        "File (%s) is only (%.2f%%) covered. This is below the expected minimum coverage per file of (%.2f%%).\n",
        result.least_covered_file, covered_percentages.min, SimpleCov.minimum_coverage_by_file
      )

      SimpleCov::ExitCodes::MINIMUM_COVERAGE
    end

    def high_coverage_drop
      return unless (last_run = SimpleCov::LastRun.read)
      coverage_diff = last_run.fetch("result").fetch("covered_percent") - covered_percent
      return unless coverage_diff > SimpleCov.maximum_coverage_drop

      $stderr.printf(
        "Coverage has dropped by %.2f%% since the last time (maximum allowed: %.2f%%).\n",
        coverage_diff, SimpleCov.maximum_coverage_drop
      )

      SimpleCov::ExitCodes::MAXIMUM_COVERAGE_DROP
    end
  end
end

# frozen_string_literal: true

module SimpleCov
  class ResultsCombiner
    attr_reader :results

    def self.combine!(*results)
      new(*results).call
    end

    def initialize(*results)
      @results = results
    end

    def call
      results.reduce({}) do |result, next_result|
        combine_result_sets(result, next_result)
      end
    end

    def combine_result_sets(first_result, second_result)
      shared_files = first_result.keys | second_result.keys

      shared_files.each_with_object({}) do |file_name, combined_results|
        combined_results[file_name] = combine_file_coverage(
          first_result[file_name],
          second_result[file_name]
        )
      end
    end

    #
    # Combine two files coverage results
    #
    # @param [Hash] first_coverage
    # @param [Hash] second_coverage
    #
    # @return [Hash]
    #
    def combine_file_coverage(first_coverage, second_coverage)
      SimpleCov::Combiners::FilesCoverage.combine!(first_coverage, second_coverage)
    end
  end
end

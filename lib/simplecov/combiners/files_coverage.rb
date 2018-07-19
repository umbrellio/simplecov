module SimpleCov
  module Combiners
    class FilesCoverage < BaseCombiner
      attr_reader :combined_results

      def initialize(first_coverage, second_coverage)
        @combined_results    = {}
        super
      end

      #
      # Handle strategy of combining the results between two files
      # => Check if any of the files coverage is empty or not
      # => Call lines combiner
      # => Call Branches combiner
      #
      # @return [Hash] <description>
      #
      def combine
        return existed_coverage unless empty_coverage?

        combine_lines_coverage

        combine_branches_coverage

        combined_results
      end

      #
      # Merge combined lines coverage results inside total results hash
      #
      # @return [Hash]
      #
      def combine_lines_coverage
        combined_results.merge!(
          :lines => call_lines_combiner
        )
      end

      #
      # Merge combined branches coverage results inside total results hash
      #
      # @return [Hash]
      #
      def combine_branches_coverage
        combined_results.merge!(
          :branches => call_branches_combiner
        )
      end

      private

      def call_lines_combiner
        SimpleCov::Combiners::LinesCoverage.combine!(
          first_coverage[:lines],
          second_coverage[:lines]
        )
      end

      def call_branches_combiner
        SimpleCov::Combiners::BranchesCombiner.combine!(
          first_coverage[:branches],
          second_coverage[:branches]
        )
      end
    end
  end
end
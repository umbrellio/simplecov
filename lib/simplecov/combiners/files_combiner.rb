# frozen_string_literal: true

module SimpleCov
  module Combiners
    #
    # Handle combining two coverage results for same file
    #
    class FilesCombiner < BaseCombiner
      #
      #
      # @param [Hash] first_coverage
      # @param [Hash] second_coverage
      #
      def initialize(first_coverage, second_coverage)
        @combined_results ||= {}
        super
      end

      #
      # Handle combining results
      # => Check if any of the files coverage is empty or not
      # => Call lines combiner
      # => Call Branches combiner
      # Notice: this structure gives possibility to add in future methods coverage combiner
      #
      # @return [Hash]
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
        combined_results[:lines] = SimpleCov::Combiners::LinesCombiner.combine!(
          first_coverage[:lines],
          second_coverage[:lines]
        )
      end

      #
      # Merge combined branches coverage results inside total results hash
      #
      # @return [Hash]
      #
      def combine_branches_coverage
        combined_results[:branches] = SimpleCov::Combiners::BranchesCombiner.combine!(
          first_coverage[:branches],
          second_coverage[:branches]
        )
      end

    private

      attr_reader :combined_results
    end
  end
end

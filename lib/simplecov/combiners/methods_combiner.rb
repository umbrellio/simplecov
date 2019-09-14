# frozen_string_literal: true

module SimpleCov
  module Combiners
    #
    # Combine different method coverage results on single file.
    #
    class MethodsCombiner < BaseCombiner
      #
      # Return merged methods or the existed branche if other is missing.
      #
      # @return [Hash]
      #
      def combine
        return existed_coverage unless empty_coverage?
        combine_methods
      end

      #
      # @return [Hash]
      #
      def combine_methods
        result_coverage = {}

        first_coverage.each_key do |method|
          result_coverage[method] = first_coverage.fetch(method) + second_coverage.fetch(method)
        end

        result_coverage
      end
    end
  end
end

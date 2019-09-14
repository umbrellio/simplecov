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
        processed_first_coverage = process(first_coverage)
        processed_second_coverage = process(second_coverage)

        processed_first_coverage.each_key do |method|
          processed_first_coverage[method] += processed_second_coverage.fetch(method)
        end

        processed_first_coverage unless processed_first_coverage == {}
      end

      private

      def process(coverage)
        result = {}

        # NOTE: move to serialization?
        coverage.each do |key, value|
          new_key = key.dup
          new_key[0].sub!(/0x[0-9a-f]{16}/, "0x0000000000000000")
          result[new_key] = value
        end

        result
      end
    end
  end
end

# frozen_string_literal: true

module SimpleCov
  module Combine
    # Combine different method coverage results on single file.
    module MethodsCombiner
    module_function

      #
      # Combine method coverage from 2 sources
      #
      # @return [Hash]
      #
      def call(coverage_a, coverage_b)
        result_coverage = {}

        keys = (coverage_a.keys + coverage_b.keys).uniq

        keys.each do |method_name|
          result_coverage[method_name] =
            coverage_a.fetch(method_name, 0) + coverage_b.fetch(method_name, 0)
        end

        result_coverage
      end
    end
  end
end

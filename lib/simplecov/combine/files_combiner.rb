# frozen_string_literal: true

module SimpleCov
  module Combine
    # Handle combining two coverage results for same file
    class FilesCombiner
      def initialize(instance:)
        @instance = instance
      end

      #
      # Combines the results for 2 coverages of a file.
      #
      # @return [Hash]
      #
      def call(cov_a, cov_b)
        combination = {}

        combination[:lines] = Combine.combine(LinesCombiner, cov_a[:lines], cov_b[:lines])

        if instance.branch_coverage? # rubocop:disable Style/IfUnlessModifier
          combination[:branches] = Combine.combine(BranchesCombiner, cov_a[:branches], cov_b[:branches])
        end

        if instance.method_coverage? # rubocop:disable Style/IfUnlessModifier
          combination[:methods] = Combine.combine(MethodsCombiner, cov_a[:methods], cov_b[:methods])
        end

        combination
      end

      private

      attr_reader :instance
    end
  end
end

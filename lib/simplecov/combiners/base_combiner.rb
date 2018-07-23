# frozen_string_literal: true

module SimpleCov
  module Combiners
    #
    # Represents the base behavior or the combiner
    # take two coverage statisitcs and combine them depends on the logic needed
    #
    class BaseCombiner
      attr_reader :first_coverage, :second_coverage

      def self.combine!(*args)
        new(*args).combine
      end

      def initialize(first_coverage, second_coverage)
        @first_coverage  = first_coverage
        @second_coverage = second_coverage
      end

    private

      def empty_coverage?
        first_coverage && second_coverage
      end

      def existed_coverage
        first_coverage || second_coverage
      end
    end
  end
end

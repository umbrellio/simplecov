# frozen_string_literal: true

module SimpleCov
  #
  # Manage classification of the coverage results for given lines
  # It merges the lines & branches classification in one hash
  #
  class CoverageClassifier
    attr_reader :lines

    def self.call(*args)
      new(*args).merge
    end

    def initialize(lines)
      @lines = lines
      @classified_result = {}
    end

    def merge
      classified_lines
      classified_branches

      @classified_result
    end

    def classified_lines
      @classified_result.merge!(
        :lines => SimpleCov::LinesClassifier.new.classify(lines)
      )
    end

    def classified_branches
      @classified_result.merge!(
        :branches => {} # SimpleCov::BranchesClassifier.classify(lines)
      )
    end
  end
end

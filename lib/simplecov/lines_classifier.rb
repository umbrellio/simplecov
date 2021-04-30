# frozen_string_literal: true

module SimpleCov
  # Classifies whether lines are relevant for code coverage analysis.
  # Comments & whitespace lines, and :nocov: token blocks, are considered not relevant.

  class LinesClassifier
    RELEVANT = 0
    NOT_RELEVANT = nil

    WHITESPACE_LINE = /^\s*$/.freeze
    COMMENT_LINE = /^\s*#/.freeze
    WHITESPACE_OR_COMMENT_LINE = Regexp.union(WHITESPACE_LINE, COMMENT_LINE)

    def initialize(instance: SimpleCov.instance)
      @instance = instance
    end

    def no_cov_line
      @no_cov_line ||= /^(\s*)#(\s*)(:#{instance.nocov_token}:)/
    end

    def no_cov_line?(line)
      no_cov_line.match?(line)
    rescue ArgumentError
      # E.g., line contains an invalid byte sequence in UTF-8
      false
    end

    def whitespace_line?(line)
      WHITESPACE_OR_COMMENT_LINE.match?(line)
    rescue ArgumentError
      # E.g., line contains an invalid byte sequence in UTF-8
      false
    end

    def classify(lines)
      skipping = false

      lines.map do |line|
        if no_cov_line?(line)
          skipping = !skipping
          NOT_RELEVANT
        elsif skipping || whitespace_line?(line)
          NOT_RELEVANT
        else
          RELEVANT
        end
      end
    end

  private

    attr_reader :instance
  end
end

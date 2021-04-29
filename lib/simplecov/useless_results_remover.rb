# frozen_string_literal: true

module SimpleCov
  #
  # Select the files that related to working scope directory of SimpleCov
  #
  module UselessResultsRemover
    def self.call(coverage_result, instance: SimpleCov.instance)
      root_regx = /\A#{Regexp.escape(instance.root + File::SEPARATOR)}/i.freeze

      coverage_result.select do |path, _coverage|
        path =~ root_regx
      end
    end
  end
end

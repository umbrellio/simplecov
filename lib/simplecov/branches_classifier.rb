# frozen_string_literal: true

module SimpleCov
  module BranchesClassifier
    def self.classify(source_file_path)
      return {} unless SimpleCov.measurement_targets
      Coverage.start(:all)
      require source_file_path
      Coverage.result[source_file_path][:branches]
    end
  end
end

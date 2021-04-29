# frozen_string_literal: true

require "json"

module SimpleCov
  class LastRun
    attr_reader :instance

    def initialize(instance: SimpleCov.instance)
      @instance = instance
    end

    def last_run_path
      File.join(instance.coverage_path, ".last_run.json")
    end

    def read
      return nil unless File.exist?(last_run_path)

      json = File.read(last_run_path)
      return nil if json.strip.empty?

      JSON.parse(json, symbolize_names: true)
    end

    def write(json)
      File.write(last_run_path, JSON.pretty_generate(json))
    end
  end
end

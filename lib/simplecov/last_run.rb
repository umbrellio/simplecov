# frozen_string_literal: true

require "json"

module SimpleCov
  module LastRun
    # TODO[@tycooon]: use class
    class << self
      def last_run_path(instance: SimpleCov.instance)
        File.join(instance.coverage_path, ".last_run.json")
      end

      def read(instance: SimpleCov.instance)
        return nil unless File.exist?(last_run_path(instance: instance))

        json = File.read(last_run_path)
        return nil if json.strip.empty?

        JSON.parse(json, symbolize_names: true)
      end

      def write(json, instance: SimpleCov.instance)
        File.open(last_run_path(instance: instance), "w+") do |f|
          f.puts JSON.pretty_generate(json)
        end
      end
    end
  end
end

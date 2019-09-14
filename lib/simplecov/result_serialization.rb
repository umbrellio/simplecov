# frozen_string_literal: true

module SimpleCov
  class ResultSerialization
    class << self
      def serialize(result)
        coverage = {}

        result.coverage.each do |file_path, file_data|
          serializable_file_data = {}

          file_data.each do |key, value|
            serializable_file_data[key] = serialize_value(value)
          end

          coverage[file_path] = serializable_file_data
        end

        data = { "coverage" => coverage, "timestamp" => result.created_at.to_i }
        { result.command_name => data }
      end

      def deserialize(hash)
        command_name, data = hash.first

        coverage = {}

        data["coverage"].each do |file_name, file_data|
          parsed_file_data = {}

          file_data.each do |key, value|
            parsed_file_data[key.to_sym] = deserialize_value(value)
          end

          coverage[file_name] = parsed_file_data
        end

        result = SimpleCov::Result.new(coverage)
        result.command_name = command_name
        result.created_at = Time.at(data["timestamp"])
        result
      end

      private

      def serialize_value(value)
        case value
        when Hash
          value.map { |key, value| [key, serialize_value(value)] }
        else
          value
        end
      end

      def deserialize_value(value)
        if value.is_a?(Array) && value.all? { |x| x.is_a?(Array) && x.size == 2 }
          hash = {}

          value.each do |key, value|
            hash[key] = deserialize_value(value)
          end

          hash
        else
          value
        end
      end
    end
  end
end

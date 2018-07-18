# frozen_string_literal: true

module SimpleCov
  #
  # Resposible of adapting the format of the coverage result weather it's default or with statistics
  #
  #
  class ResultAdapter
    attr_reader :result

    def initialize(result)
      @result = result
    end

    def self.call(*args)
      new(*args).adapt
    end

    def adapt
      return result unless result

      result.each_with_object({}) do |(file_name, cover_statistic), adapted_result|
        if cover_statistic.is_a?(Array)
          adapted_result.merge!(file_name => {:lines => cover_statistic})
        else
          adapted_result.merge!(file_name => cover_statistic)
        end
      end
    end
  end
end

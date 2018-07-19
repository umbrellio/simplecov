# frozen_string_literal: true

module SimpleCov
  module RawCoverage
  module_function

    # Merges multiple Coverage.result hashes
    def merge_results(*results)
      results.reduce({}) do |result, second_result|
        merge_result_sets(result, second_result)
      end
    end

    # Merges two Coverage.result hashes
    def merge_result_sets(first_result, second_result)
      (first_result.keys | second_result.keys).each_with_object({}) do |file_name, merged|

        first_result_file  = first_result[file_name]
        second_result_file = second_result[file_name]

        merged[file_name] = merge_file_coverage(first_result_file, second_result_file)
      end
    end

    def merge_file_coverage(file1, file2)

      return (file1 || file2).dup unless file1 && file2

      merge_results = {}
      merge_results.merge!( :lines => lines_coverage(file1, file2))
      # TODO: add branche coverage
      merge_results
    end

    def lines_coverage(file1, file2)
      if file1[:lines] == nil
        binding.pry
      end
      file1[:lines].map.with_index do |line1, index|
        line2 = file2[:lines][index]
        merge_line_coverage(line1, line2)
      end
    end


    def merge_line_coverage(count1, count2)
      sum = count1.to_i + count2.to_i
      if sum.zero? && (count1.nil? || count2.nil?)
        nil
      else
        sum
      end
    end
  end
end

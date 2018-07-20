# frozen_string_literal: true

module SimpleCov
  module Combiners
    class BranchesCombiner < BaseCombiner
      #
      # Return merged branches or the existed branche if other is missing
      #
      # @return [Hash]
      #
      def combine
        return existed_coverage unless empty_coverage?
        combine_branches
      end

      #
      # Logic here is to simple
      # Branches inside files are always same if they exists, the difference only in coverage count
      # Branch coverage report for any conditional case is build from hash it's key is condition and
      # body also hash with hashes inside << keys from condition and value is coverage rate >>
      # ex: branches =>{ [:if, 3, 8, 6, 8, 36] => {[:then, 4, 8, 6, 8, 12] => 1, [:else, 5, 8, 6, 8, 36]=>2}, other branches...}
      # So we create copy of result and update it values depends on the combined branches coverage values
      #
      # @return [Hash]
      #
      def combine_branches
        combine_result = first_coverage.clone
        first_coverage.each do |(condition, branches_inside)|
          branches_inside.each do |(branch_key, branch_coverage_value)|
            compared_branch_coverage = second_coverage[condition][branch_key]

            combine_result[condition][branch_key] = branch_coverage_value + compared_branch_coverage
          end
        end

        combine_result
      end
    end
  end
end

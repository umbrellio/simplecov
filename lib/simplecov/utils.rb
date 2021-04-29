# frozen_string_literal: true

module SimpleCov
  # Functionally for rounding coverage results
  module Utils
  module_function

    #
    # @api private
    #
    # Rounding down to be extra strict, see #679
    def round_coverage(coverage)
      coverage.floor(2)
    end
  end
end

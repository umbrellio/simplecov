# frozen_string_literal: true

# :nocov:

# We have to start coverage ourself since it should be done before requiring any SimpleCov code
require "coverage"

coverage_args = Coverage.method(:start).arity.zero? ? [] : [:all]
Coverage.start(*coverage_args)

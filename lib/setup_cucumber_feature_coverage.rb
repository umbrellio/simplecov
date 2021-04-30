# frozen_string_literal: true

# :nocov:

# This file should be required in all cucumber features instead of just "simplecov".
# It setups measuring coverage of SimpleCov itself. The results are later merged into
# "tmp/cucumber-coverage" directory (see features/support/env.rb)

require_relative "setup_test_coverage"
require_relative "simplecov"

simplecov = SimpleCov.build

# We need unique directory for each cucumber scenario
timestamp = (Time.now.to_f * 1_000_000_000).to_i

simplecov.start do
  formatter SimpleCov::Formatter::SimpleFormatter
  root File.expand_path("..", __dir__)
  coverage_dir "tmp/features-coverage/#{timestamp}"
  enable_coverage :line
  enable_coverage :branch
  enable_coverage :method
end

Kernel.at_exit { simplecov.at_exit_behavior }

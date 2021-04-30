# frozen_string_literal: true

require "rspec"
require "stringio"
require "open3"

# Loaded before simplecov to also capture parse time warnings
require "support/fail_rspec_on_ruby_warning"

require "setup_test_coverage"
require "simplecov"

simplecov = SimpleCov.build

# Defaults are not loaded for custom instance so we have to configure all the stuff here
simplecov.start do
  formatter SimpleCov::Formatter::HTMLFormatter
  add_filter "/spec/"
  track_files "lib/**/*.rb"
  coverage_dir "tmp/rspec-coverage"
  enable_coverage :line
  enable_coverage :branch
  enable_coverage :method
end

Kernel.at_exit { simplecov.at_exit_behavior }

SimpleCov.external_at_exit = true
SimpleCov.coverage_dir("tmp/coverage")

def source_fixture(filename)
  File.join(source_fixture_base_directory, "fixtures", filename)
end

def source_fixture_base_directory
  @source_fixture_base_directory ||= File.dirname(__FILE__)
end

# Taken from http://stackoverflow.com/questions/4459330/how-do-i-temporarily-redirect-stderr-in-ruby
def capture_stderr
  # The output stream must be an IO-like object. In this case we capture it in
  # an in-memory IO object so we can return the string value. You can assign any
  # IO object here.
  previous_stderr = $stderr
  $stderr = StringIO.new
  yield
  $stderr.string
ensure
  # Restore the previous value of stderr (typically equal to STDERR).
  $stderr = previous_stderr
end

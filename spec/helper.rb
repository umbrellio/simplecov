# frozen_string_literal: true

require "rspec"
require "stringio"
require "open3"
# loaded before simplecov to also capture parse time warnings
require "support/fail_rspec_on_ruby_warning"

# we have to start coverage ourself since we should do it before requiring any SimpleCov code
require "coverage"
coverage_args = Coverage.method(:start).arity.zero? ? [] : [:all]
Coverage.start(*coverage_args)

require "simplecov"

simplecov = SimpleCov.build

simplecov.start do
  formatter SimpleCov::Formatter::HTMLFormatter
  add_filter "/spec/"
  track_files "lib/**/*.rb"
  enable_coverage :line
  enable_coverage :branch
  enable_coverage :method
end

Kernel.at_exit { simplecov.at_exit_behavior }

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

unless '1.9'.respond_to?(:encoding)
  $stderr.puts "Sorry, Cucumber features are only meant to run on Ruby 1.9+ :("
  exit 0
end

require 'bundler'
Bundler.setup
require 'aruba/cucumber'
require 'capybara/cucumber'
require 'capybara/webkit'

# Fake rack app for capybara that just returns the latest coverage report from aruba temp project dir
Capybara.app = lambda { |env|
  request_path = env['REQUEST_PATH'] || '/'
  request_path = '/index.html' if request_path == '/'

  [200, {'Content-Type' => 'text/html'},
    [File.read(File.join(File.dirname(__FILE__), '../../tmp/aruba/project/coverage', request_path))]]
}

# https://github.com/thoughtbot/capybara-webkit
Capybara.default_driver = Capybara.javascript_driver = :webkit

Before do
  @aruba_timeout_seconds = 20
  this_dir = File.dirname(__FILE__)
  # Clean up and create blank state for fake project
  in_current_dir do
    FileUtils.rm_rf 'project'
    FileUtils.cp_r File.join(this_dir, '../../test/faked_project/'), 'project'
  end
  step 'I cd to "project"'
end

# Workaround for https://github.com/cucumber/aruba/pull/125
Aruba.configure do |config|
  config.before_cmd do
    set_env('JRUBY_OPTS', '-X-C --1.9')
  end
end

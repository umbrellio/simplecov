# frozen_string_literal: true

source "https://rubygems.org"

case ENV["SIMPLECOV_HTML_MODE"]
when "local"
  # Use local copy of simplecov-html in development when checked out
  gem "simplecov-html", path: File.join(__dir__, "../simplecov-html")
when "github"
  # Use development version of html formatter from github
  gem "simplecov-html", github: "simplecov-ruby/simplecov-html"
when "methods" # TODO: remove after simplecov-html release
  gem "simplecov-html", github: "umbrellio/simplecov-html", branch: "add-method-coverage-support"
end

gem "matrix"

group :development do
  gem "apparition", github: "twalpole/apparition"
  gem "activesupport", "~> 6.1"
  gem "aruba"
  gem "capybara"
  if RUBY_VERSION < "2.7"
    gem "rack", "< 3"
  else
    gem "rackup"
  end
  gem "cucumber"
  gem "minitest"
  gem "rake"
  gem "rspec"
  gem "pry"
  gem "rubocop"
  gem "test-unit"
  # Explicitly add webrick because it has been removed from stdlib in Ruby 3.0
  gem "webrick"
end

group :benchmark do
  gem "benchmark-ips"
end

gemspec

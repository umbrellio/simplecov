# frozen_string_literal: true

source "https://rubygems.org"

if ENV["SIMPLECOV_HTML_BRANCH"]
  # Use development version of html formatter from github
  gem "simplecov-html-method-cov", github: "umbrellio/simplecov-html", branch: ENV["SIMPLECOV_HTML_BRANCH"]
else
  # Use local copy of simplecov-html-method-cov in development when checked out
  gem "simplecov-html-method-cov", path: "#{File.dirname(__FILE__)}/../simplecov-html"
end

group :development do
  gem "apparition", "~> 0.6.0"
  gem "aruba", "~> 1.0"
  gem "capybara", "~> 3.31"
  gem "cucumber", "~> 4.0"
  gem "minitest"
  gem "rake", "~> 13.0"
  gem "rspec", "~> 3.2"
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

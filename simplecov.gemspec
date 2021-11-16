# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "simplecov/version"

Gem::Specification.new do |gem|
  gem.name        = "simplecov-method-cov"
  gem.version     = SimpleCov::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ["Christoph Olszowka", "Tobias Pfeiffer", "Yuri Smirnov"]
  gem.email       = ["christoph at olszowka de", "pragtob@gmail.com", "tycoooon@gmail.com"]
  gem.homepage    = "https://github.com/umbrellio/simplecov/"
  gem.summary     = "Code coverage for Ruby"
  gem.description = %(Code coverage for Ruby with a powerful configuration library and automatic merging of coverage across test suites)
  gem.license     = "MIT"
  gem.metadata    = {
    "bug_tracker_uri"       => "https://github.com/umbrellio/simplecov/issues",
    "changelog_uri"         => "https://github.com/umbrellio/simplecov/blob/main/CHANGELOG.md",
    "documentation_uri"     => "https://www.rubydoc.info/gems/simplecov-method-cov/#{gem.version}",
    "source_code_uri"       => "https://github.com/umbrellio/simplecov/tree/v#{gem.version}",
    "rubygems_mfa_required" => "true"
  }

  gem.required_ruby_version = ">= 2.5.0"

  gem.add_dependency "docile", "~> 1.1"
  gem.add_dependency "simplecov-html-method-cov", "~> 1.0"
  gem.add_dependency "simplecov_json_formatter", "~> 0.1"

  gem.files         = Dir["{lib}/**/*.*", "bin/*", "LICENSE", "CHANGELOG.md", "README.md", "doc/*"]
  gem.require_paths = ["lib"]
end

@rspec
Feature:

  Running specs with a failing rspec setup

  Background:
    Given I'm working on the project "faked_project"

  Scenario: Fail if rspec fails before starting its tests
    Given a file named "spec/spec_helper.rb" with:
      """
      require "simplesetup_cucumber_feature_coveragecov"
      SimpleCov.start
      raise "some exception in the class loading before the tests start"
      """
    When I run `bundle exec rspec spec`
    Then the exit status should not be 0

@test_unit @rspec @merging @config
Feature: Custom names for individual test suites

  Each test suite needs a name it can be identified by. SimpleCov tries
  best to detect Rails' Unit, Functional, Integration tests as well as regular
  Test/Unit, RSpec and Cucumber, but if that is insufficient, each test suite
  config can be given a custom command name using SimpleCov.command_name.

  Background:
    Given I'm working on the project "faked_project"

  Scenario:
    Given SimpleCov for Test/Unit is configured with:
      """
      require "setup_cucumber_feature_coverage"

      SimpleCov.start do
        command_name "I'm in UR Unitz"
      end
      """
    Given SimpleCov for RSpec is configured with:
      """
      require "setup_cucumber_feature_coverage"

      SimpleCov.start do
        command_name "Dreck macht Speck"
      end
      """

    When I open the coverage report generated with `bundle exec rake test`
    Then the report should be based upon:
      | I'm in UR Unitz |

    When I open the coverage report generated with `bundle exec rspec spec`
    Then the report should be based upon:
      | Dreck macht Speck |
      | I'm in UR Unitz   |

  Scenario: RSpec auto detection with spec/features
    Given SimpleCov for RSpec is configured with:
      """
      require "setup_cucumber_feature_coverage"
      SimpleCov.start
      """
    And a file named "spec/features/foobar_spec.rb" with:
      """
      """
    When I open the coverage report generated with `bundle exec rspec spec`
    Then the report should be based upon:
      | RSpec |

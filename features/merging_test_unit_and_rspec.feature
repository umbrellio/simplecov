@test_unit @rspec @merging
Feature:

  Test suites like RSpec and Test/Unit should be merged automatically
  when both have been run recently. The coverage report will feature
  the joined results of all test suites that are using SimpleCov.

  Background:
    Given I'm working on the project "faked_project"

  Scenario:
    Given SimpleCov for Test/Unit is configured with:
      """
      require "setup_cucumber_feature_coverage"

      SimpleCov.start do
        add_filter "test.rb"
        add_filter "spec.rb"
      end
      """
    And SimpleCov for RSpec is configured with:
      """
      require "setup_cucumber_feature_coverage"

      SimpleCov.start do
        add_filter "test.rb"
        add_filter "spec.rb"
      end
      """

    When I open the coverage report generated with `bundle exec rake test`
    Then the report should be based upon:
      | Unit Tests |

    When I open the coverage report generated with `bundle exec rspec spec`
    Then the report should be based upon:
      | RSpec      |
      | Unit Tests |

    And I should see the groups:
      | name      | coverage | files |
      | All Files | 90.48%   | 4     |

    And I should see the source files:
      | name                                    | coverage |
      | lib/faked_project.rb                    | 100.00 %  |
      | lib/faked_project/some_class.rb         |  80.00 %  |
      | lib/faked_project/framework_specific.rb |  87.50 %  |
      | lib/faked_project/meta_magic.rb         | 100.00 %  |

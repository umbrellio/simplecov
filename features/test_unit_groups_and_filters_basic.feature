@test_unit
Feature:

  Defining some groups and filters should give a corresponding
  coverage report that respects those settings after running tests

  Background:
    Given I'm working on the project "faked_project"

  Scenario:
    Given SimpleCov for Test/Unit is configured with:
      """
      require "setup_cucumber_feature_coverage"

      SimpleCov.start do
        add_group "Libs", "lib/faked_project/"
        add_filter "/test/"
      end
      """

    When I open the coverage report generated with `bundle exec rake test`
    Then I should see the groups:
      | name      | coverage | files |
      | All Files | 88.1%    | 4     |
      | Libs      | 86.11%   | 3     |
      | Ungrouped | 100.0%   | 1     |

    And I should see the source files:
      | name                                    | coverage |
      | lib/faked_project.rb                    | 100.00 %  |
      | lib/faked_project/some_class.rb         |  80.00 %  |
      | lib/faked_project/framework_specific.rb |  75.00 %  |
      | lib/faked_project/meta_magic.rb         | 100.00 %  |

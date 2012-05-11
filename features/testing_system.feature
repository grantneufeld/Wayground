@test
Feature: Testing system
  In order to test that the systems for testing the code are operational
  As a developer
  I want to run some tests that use the various testing features

  Scenario: Test a feature
    When I test a feature
    Then I should get "Feature tested."

  @wip
  Scenario: In progress features are ignored during regular test cycles
    Given I have something in progress
    When I run the regular test suite
    Then nothing should happen

  @future
  Scenario: Future features are ignored during all test cycles
    Given I have a scenario for a feature to be implemented in the future
    When I run any test suites
    Then nothing should happen

  Scenario: Factory girl has built-in cucumber step for generating a single object
    Given no TestModel records exist
    And a test_model exists
    Then I should have 1 test model

  Scenario: Factory girl has built-in cucumber step for generating a bunch of objects at once
    Given no TestModel records exist
    And 5 test_models exist
    Then I should have 5 test models

  Scenario: Factory girl has built-in cucumber step for generating a bunch of objects from a table
    Given no TestModel records exist
    And the following test models exist
      | test_attribute |
      | one |
      | two |
    Then I should have 2 test models
    And I should have a test model with test_attribute "one"
    And I should have a test model with test_attribute "two"

  Scenario: Factory girl has built-in cucumber step for generating an object with a set column value
    Given no TestModel records exist
    And a test model exists with a test attribute of "something"
    Then I should have 1 test model
    And I should have a test model with test_attribute "something"

  Scenario: Factory girl has built-in cucumber step for generating a bunch of objects with a set column value
    Given no TestModel records exist
    And 4 test models exist with a test attribute of "somethings"
    Then I should have 4 test models
    And I should have a test model with test_attribute "somethings"

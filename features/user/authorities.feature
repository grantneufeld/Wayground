@future
Feature: Authorities
  In order to prevent people from doing inappropriate things
  As a signed in website visitor
  I want to only be able to access items I have authority for

  Scenario: an unauthorized user tries to access a restricted item
    Given I have signed in
    And there is a secure item "secure"
    Then I should not be able to access the item "secure"

  Scenario: an authorized user accesses a restricted item
    Given I have signed in as "testuser"
    And there is a secure item "secure"
    And user "testuser" has access to secure item "secure"
    Then I should be able to access the item "secure"

  Scenario: a user with access to the applicable area accesses a restricted item
    Given I have signed in as "testuser"
    And there is a secure item "secure"
    And user "testuser" has access to the "item" area
    Then I should be able to access the item "secure"

  Scenario: an admin user accesses a restricted item
    Given I have signed in as an admin
    And there is a secure item "secure"
    Then I should be able to access the item "secure"


@user
Feature: Sign out
  In order to protect my account from unauthorized access
  A signed in user
  Should be able to sign out

  # most of these scenarios are derived from the ones that come from Clearance

  Scenario: User signs out
    Given I am signed up and confirmed as "test+email@wayground.ca/password"
    When I sign in with email test+email@wayground.ca and password "password"
    And I sign out
    Then I should see "You are now signed out"
    And I should be signed out
    When I return next time
    Then I should be signed out

  Scenario: User tries to go to the sign out page when not signed in
    When I go to the sign out page
    Then I should see "You are not signed in"

  @future
  Scenario: User tries to sign out when not signed in
    When I try to sign out
    Then I should see "You are not signed in"

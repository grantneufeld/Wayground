@future @user
Feature: Sign out
  In order to protect my account from unauthorized access
  A signed in user
  Should be able to sign out

  # most of these scenarios are derived from the ones that come from Clearance 
  
  Scenario: User signs out
    Given I am signed up and confirmed as "test+email@wayground.ca/password"
    When I sign in as "test+email@wayground.ca/password"
    Then I should be signed in
    And I sign out
    Then I should see "Signed out"
    Then I should be signed out
    When I return next time
    Then I should be signed out

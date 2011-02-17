@future @user
Feature: Sign up
  In order to have a sustained identity and access controlled functions of the site
  A user
  Should be able to sign up to create an account
  
  # most of these scenarios are derived from the ones that come from Clearance 
  
  Scenario: User signs up with invalid data
    When I go to the sign up page
    And I fill in "Email" with "invalidemail"
    And I fill in "Password" with "password"
    And I fill in "Confirm password" with ""
    And I fill in "Name" with ""
    And I press "Sign Up"
    Then I should see error messages

  Scenario: User signs up with valid data
    When I go to the sign up page
    And I fill in "Email" with "test+email@wayground.ca"
    And I fill in "Password" with "password"
    And I fill in "Confirm password" with "password"
    And I fill in "Name" with "nickname"
    And I press "Sign Up"
    Then I should see "instructions for confirming"
    And a confirmation message should be sent to "test+email@wayground.ca"

  Scenario: User confirms his account
    Given I signed up with "test+email@wayground.ca/password"
    When I follow the confirmation link sent to "test+email@wayground.ca"
    Then I should see "Confirmed email and signed in"
    And I should be signed in

  Scenario: Signed in user clicks confirmation link again
    Given I signed up with "test+email@wayground.ca/password"
    When I follow the confirmation link sent to "test+email@wayground.ca"
    Then I should be signed in
    When I follow the confirmation link sent to "test+email@wayground.ca"
    Then I should see "Confirmed email and signed in"
    And I should be signed in

  Scenario: Signed out user clicks confirmation link again
    Given I signed up with "test+email@wayground.ca/password"
    When I follow the confirmation link sent to "test+email@wayground.ca"
    Then I should be signed in
    When I sign out
    And I follow the confirmation link sent to "test+email@wayground.ca"
    Then I should see "Already confirmed email. Please sign in."
    And I should be signed out

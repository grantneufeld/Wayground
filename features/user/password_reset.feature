@future @user
Feature: Password reset
  In order to sign in even if user forgot their password
  A user
  Should be able to reset it

  # most of these scenarios are derived from the ones that come from Clearance 
  
  Scenario: User is not signed up
    Given no user exists with an email of "test+email@wayground.ca"
    When I request password reset link to be sent to "test+email@wayground.ca"
    Then I should see "Unknown email"

  Scenario: User is signed up and requests password reset
    Given I signed up with "test+email@wayground.ca/password"
    When I request password reset link to be sent to "test+email@wayground.ca"
    Then I should see "instructions for changing your password"
    And a password reset message should be sent to "test+email@wayground.ca"

  Scenario: User is signed up updated his password and types wrong confirmation
    Given I signed up with "test+email@wayground.ca/password"
    When I follow the password reset link sent to "test+email@wayground.ca"
    And I update my password with "newpassword/wrongconfirmation"
    Then I should see error messages
    And I should be signed out

  Scenario: User is signed up and updates his password
    Given I signed up with "test+email@wayground.ca/password"
    When I follow the password reset link sent to "test+email@wayground.ca"
    And I update my password with "newpassword/newpassword"
    Then I should be signed in
    When I sign out
    Then I should be signed out
    And I sign in with email test+email@wayground.ca and password "newpassword"
    Then I should be signed in

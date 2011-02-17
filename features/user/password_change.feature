@future @user
Feature: Password change
  In order to change their password
  A signed-in user
  Should be able to set a new password to use

  Scenario: User tries to submit a blank password change request
    Given I am signed in as "test+email@wayground.ca/password"
    When I go to the user password change form
    And I press "Change My Password"
    Then I should see "Your password could not be changed. Please make sure all fields are filled in correctly."

  Scenario: User tries to submit a password change request with invalid old password
    Given I am signed in as "test+email@wayground.ca/password"
    When I go to the user password change form
    And I fill in "Current Password" with "invalidpassword"
    And I fill in "New Password" with "newpassword"
    And I fill in "Confirm New Password" with "newpassword"
    And I press "Change My Password"
    Then I should see "Your password could not be changed. Please make sure all fields are filled in correctly."

  Scenario: User tries to submit a password change request with no new password
    Given I am signed in as "test+email@wayground.ca/password"
    When I go to the user password change form
    And I fill in "Current Password" with "password"
    And I press "Change My Password"
    Then I should see "Your password could not be changed. Please make sure all fields are filled in correctly."

  Scenario: User tries to submit a password change request with invalid confirmation
    Given I am signed in as "test+email@wayground.ca/password"
    When I go to the user password change form
    And I fill in "Current Password" with "password"
    And I fill in "New Password" with "newpassword"
    And I fill in "Confirm New Password" with "invalidpassword"
    And I press "Change My Password"
    Then I should see "Your password could not be changed. Please make sure all fields are filled in correctly."

  Scenario: User tries to submit a password change request with an insecure password
    Given I am signed in as "test+email@wayground.ca/password"
    When I go to the user password change form
    And I fill in "Current Password" with "password"
    And I fill in "New Password" with "insecure"
    And I fill in "Confirm New Password" with "insecure"
    And I press "Change My Password"
    Then I should see "Your password could not be changed. Please make sure all fields are filled in correctly."

  Scenario: User submits a valid password change request
    Given I am signed in as "test+email@wayground.ca/password"
    When I go to the user password change form
    And I fill in "Current Password" with "password"
    And I fill in "New Password" with "newpassword"
    And I fill in "Confirm New Password" with "newpassword"
    Then I should see "Your password has been updated."


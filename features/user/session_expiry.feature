@future @user
Feature: Session expiry
  In order to reduce the security risk of having a session kept active for too long
  As a user
  I want to have to re-sign-in after a set period, or after going too long with no activity

  # Currently, expecting sessions to expire 3 days after sign-in, or after 12 hours of inactivity

  Scenario: User comes back 12 hours after signing-in
    Given the date is "January 1, 2011, 1:00 am"
    And I have signed in with "test+email@wayground.ca/password"
    And the date is now "January 1, 2011, 1:00 pm"
    When I go to the home page
    Then I should be signed out

  Scenario: User comes back just under 12 hours after signing-in
    Given the date is "January 1, 2011, 1:00 am"
    And I have signed in with "test+email@wayground.ca/password"
    And the date is now "January 1, 2011, 12:59 pm"
    When I go to the home page
    Then I should be signed in

  Scenario: User keeps session open for three days
    Given the date is "January 1, 2011, 1:00 am"
    And I have signed in with "test+email@wayground.ca/password"
    And the date is now "January 1, 2011, 12:59 pm"
    And I go to the home page
    And the date is now "January 2, 2011, 12:58 am"
    And I go to the home page
    And the date is now "January 2, 2011, 12:57 pm"
    And I go to the home page
    And the date is now "January 3, 2011, 12:56 am"
    And I go to the home page
    And the date is now "January 3, 2011, 12:55 pm"
    And I go to the home page
    And the date is now "January 4, 2011, 12:54 am"
    And I go to the home page
    And the date is now "January 4, 2011, 1:00 am"
    When I go to the home page
    Then I should be signed out

@future @user
Feature: Remember sign-in
  In order to keep a user signed-in on a browser across sessions
  As a user
  I want to have the site remember my sign-in

  Scenario: User signs-in with the “remember me” flag set
    Given I am signed up and confirmed as "test+email@wayground.ca/password"
    When I go to the sign in page
    And I fill in "Email" with "test+email@wayground.ca"
    And I fill in "Password" with "password"
    And I check "Keep me signed-in"
    And I press "Sign-in"
    And I quit the browser
    And I go to the home page
    Then I should be signed in

  Scenario: User signs-in with the “remember me” flag set, but doesn’t come back for a month
    Given I am signed up and confirmed as "test+email@wayground.ca/password"
    And the date is "January 1, 2011"
    When I go to the sign in page
    And I fill in "Email" with "test+email@wayground.ca"
    And I fill in "Password" with "password"
    And I check "Keep me signed-in"
    And I press "Sign-in"
    And I quit the browser
    Given the date is now "February 1, 2011"
    When I go to the home page
    Then I should be signed out

@user
Feature: Sign up
  In order to have a sustained identity and access controlled functions of the site
  A user
  Should be able to sign up to create an account

  # some of these scenarios are derived from the ones that come from Clearance

  Scenario: User tries to sign up when already signed in
    Given I have signed in with "test+signup@wayground.ca/password"
    When I go to the sign up page
    Then I should see "You are already signed up"

  Scenario: User tries to sign up with invalid data
    When I go to the sign up page
    And I fill in "Email" with "invalidemail"
    And I fill in "user_password" with "password"
    And I fill in "Confirm Password" with ""
    And I fill in "Name" with ""
    And I press "Sign Up"
    Then I should see error messages

  Scenario: User signs up
    Given there is already a user "Someone Else"
    When I go to the sign up page
    And I fill in "Email" with "test+signup@wayground.ca"
    And I fill in "user_password" with "password"
    And I fill in "Confirm Password" with "password"
    And I fill in "Name" with "A. Person"
    And I press "Sign Up"
    Then I should be on the account page
    And I should see "You are now registered on this site."

  @future
  Scenario: User signs up with valid data continued... confirmation message
    # This should just be tagged on to the end of the previous scenario,
    # but i haven't implemented email confirmation yet, so it is “to do”.
    Then a confirmation message should be sent to "test+email@wayground.ca"

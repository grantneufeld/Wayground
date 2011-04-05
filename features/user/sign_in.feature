@user
Feature: Sign in
  In order to get access to protected sections of the site
  A user
  Should be able to sign in

  # most of these scenarios are derived from the ones that come from Clearance 
  
  Scenario: User is not signed up
    Given no user exists with an email of "test+email@wayground.ca"
    When I go to the sign in page
    And I sign in with email test+email@wayground.ca and password "password"
    Then I should see "Wrong email or password"
    And I should be signed out

  Scenario: User enters wrong password
    Given I am signed up and confirmed as "test+email@wayground.ca/password"
    When I go to the sign in page
    And I sign in with email test+email@wayground.ca and password "wrongpassword"
    Then I should see "Wrong email or password"
    And I should be signed out

  @future
  Scenario: User is not confirmed
    Given I signed up with "test+email@wayground.ca/password"
    When I go to the sign in page
    And I sign in with email test+email@wayground.ca and password "password"
    Then I should see "User has not confirmed email"
    And I should be signed out

  Scenario: User tries to go to the sign in page when already signed in
    Given I have signed in with "test+email@wayground.ca/password"
    When I go to the sign in page
    Then I should see "You are already signed in"

  Scenario: User signs in successfully
    Given I am signed up and confirmed as "test+signin@wayground.ca/password"
    When I go to the sign in page
    And I fill in "Email" with "test+signin@wayground.ca"
    And I fill in "Password" with "password"
    And I press "Sign In"
    Then I should see "You are now signed in"
    And I should be signed in
    # TODO: returning user is not signed if they did not use remember me flag on sign in
    # When I return next time
    # Then I should be signed out

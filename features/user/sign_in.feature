@future @user
Feature: Sign in
  In order to get access to protected sections of the site
  A user
  Should be able to sign in

  # most of these scenarios are derived from the ones that come from Clearance 
  
  Scenario: User is not signed up
    Given no user exists with an email of "test+email@wayground.ca"
    When I go to the sign in page
    And I sign in as "test+email@wayground.ca/password"
    Then I should see "Bad email or password"
    And I should be signed out

  Scenario: User is not confirmed
    Given I signed up with "test+email@wayground.ca/password"
    When I go to the sign in page
    And I sign in as "test+email@wayground.ca/password"
    Then I should see "User has not confirmed email"
    And I should be signed out

  Scenario: User enters wrong password
    Given I am signed up and confirmed as "test+email@wayground.ca/password"
    When I go to the sign in page
    And I sign in as "test+email@wayground.ca/wrongpassword"
    Then I should see "Bad email or password"
    And I should be signed out

  Scenario: User signs in successfully
    Given I am signed up and confirmed as "test+email@wayground.ca/password"
    When I go to the sign in page
    And I sign in as "test+email@wayground.ca/password"
    Then I should see "Signed in"
    Then I should be signed in
    When I return next time
    Then I should be signed in

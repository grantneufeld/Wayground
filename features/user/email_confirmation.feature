@user
Feature: Email confirmation
  In order to verify that the user owns the email address they have registered
  As a user
  I want to confirm my email address

  Scenario: User tries to confirm with an invalid confirmation code
    Given I signed up with "test+confirm@wayground.ca/password"
    And I sign in as "test+confirm@wayground.ca/password"
    When I try to confirm my email with "invalid"
    Then I should see "Invalid confirmation code"

  Scenario: User tries to confirm when not signed in
    Given I signed up with "test+confirm@wayground.ca/password"
    When I follow the confirmation link sent to "test+confirm@wayground.ca"
    Then I should see "You must be signed-in to access your account"

  Scenario: User tries to confirm when already confirmed
    Given I am signed up and confirmed as "test+confirm@wayground.ca/password"
    And I sign in as "test+confirm@wayground.ca/password"
    When I try to confirm my email with "already-used-code"
    Then I should see "Your email address was already confirmed"

  Scenario: User tries to confirm when there is a database failure
    Given I signed up with "test+confirm@wayground.ca/password"
    And I sign in as "test+confirm@wayground.ca/password"
    When I follow the confirmation link sent to "test+confirm@wayground.ca" with a failure
    Then I should see "There was a problem while trying to update your information"

  Scenario: User confirms their email address
    Given I signed up with "test+confirm@wayground.ca/password"
    And I sign in as "test+confirm@wayground.ca/password"
    When I follow the confirmation link sent to "test+confirm@wayground.ca"
    Then I should see "Thank-you for confirming your email address"

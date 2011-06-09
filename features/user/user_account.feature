@user
Feature: User account
  In order to give users control of their information
  As a user
  I want access to my account details

  Scenario: User tries to access account page without being signed in
    When I go to the account page
    Then I should be on the sign in page

  Scenario: User accesses the account page
    Given I have signed in with "test+email@wayground.ca/password"
    When I go to the account page
    Then I should see my account details

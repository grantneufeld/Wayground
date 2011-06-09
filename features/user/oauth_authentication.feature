@user
Feature: Registration from external websites
  In order to make it easier for users to register
  As a user
  I want to register and sign-in using my existing account on an external website

  Background:
    Given I am pretending to access the external websites

  Scenario: Register a new user from a Twitter account
    Given I have my Twitter account @testuser
    When I sign in with my Twitter account
    Then I should be signed in
    And I should be registered with my Twitter account @testuser

  Scenario: Register a new user from a Facebook account
    Given I have my Facebook account
    When I sign in with my Facebook account
    Then I should be signed in
    And I should be registered with my Facebook account

  Scenario: User signs-in again with an account registered from a Twitter account
    Given I have previously signed in with my Twitter account
    And I am not signed in
    When I sign in with my Twitter account again
    Then I should be signed in

  Scenario: User who has signed-in with our email and password form registers with their Twitter account
    Given I have signed in with my email test+email@wayground.ca and password "password"
    And I have my Twitter account @testuser
    When I register my Twitter account
    Then I should be registered with my Twitter account @testuser

  Scenario: Signed-in user tries to use an authentication already registered to another user
    Given I have previously signed in with my Twitter account @testuser
    And I have signed in with my email test+email@wayground.ca and password "password"
    When I note which user I am
    And I try to register my Twitter account @testuser
    Then I should not be registered with my Twitter account @testuser

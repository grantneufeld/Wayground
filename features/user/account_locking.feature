@future @user
Feature: Account locking
  In order to secure user accounts against brute-force password attacks
  As a user
  I want accounts to be locked for a period of time after a set number of failed sign-in attempts

  # Currently, 10 failed attempts in a row will result in an account being locked
  # locks will hold for 1 hour

  Scenario: Ten invalid sign-in attempts are made on a user’s account

  Scenario: Nine invalid sign-in attempts are made and then the user signs in

  Scenario: A user’s account is locked and then a valid sign-in attempt is made 59 minutes later

  Scenario: A user’s account is locked and then a valid sign-in attempt is made one hour later

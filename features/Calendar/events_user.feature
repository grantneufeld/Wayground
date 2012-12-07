Feature: Events
  In order to provide more value to users
  As a user
  I want to be able to view and post event listings

  Background:
    Given there is a user "The Boss"

  # Posting Events

  Scenario: User adds an event
    Given I have signed in
    #And my timezone is "Mountain Time (US & Canada)"
    When I go to the event form
    And I fill in "Start at" with "January 1, 2020, 3:00 PM"
    And I fill in "End at" with "January 3, 2020, 3:00 AM"
    And I fill in "event_title" with "New User Event"
    And I fill in "event_description" with "This is an event, newly posted by a user."
    And I press "Save Event"
    Then I should see a notice that "The event has been submitted."
    And I should be on the page for the event "New User Event"

  Scenario: Anonymous user is blocked from adding events
    Given I am not signed in
    When I go to the event form
    Then I should be told to sign in

  Scenario: User is blocked from updating events
    Given I have signed in
    And there is an event "Can’t Edit Event"
    When I go to the edit page for the event "Can’t Edit Event"
    Then I should be denied access

  Scenario: User is blocked from deleting events
    Given I have signed in
    And there is an event "Can’t Delete Event"
    When I go to the delete page for the event "Can’t Delete Event"
    Then I should be denied access

  # Viewing Events

  Scenario: Anonymous user views the list of upcoming events
    Given there are 5 upcoming events
    When I go to the upcoming events page
    Then I should see 5 events

  @future
  Scenario: Anonymous user views the events for a given month

  Scenario: Anonymous user views an individual event
    Given I am not signed in
    And there is an event on "December 31, 2012 at 4:30 PM" titled "Individual Example Event"
    When I go to the page for the event "Individual Example Event"
    Then I should see the event "Individual Example Event"
    And I should see that the event starts on "December 31, 2012 at 4:30 PM"

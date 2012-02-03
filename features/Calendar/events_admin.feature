Feature: Events
  In order to provide more value to users
  As an admin
  I want to be able to add and update event listings

  Scenario: Admin adds an event
    Given I have signed in as an admin
    #And my timezone is "Mountain Time (US & Canada)"
    When I go to the event form
    And I fill in "Start at" with "January 1, 2020, 3:00 PM"
    And I fill in "End at" with "January 3, 2020, 3:00 AM"
    And I fill in "Title" with "New Admin Event"
    And I fill in "Description" with "This is an event, newly posted by an admin."
    And I press "Save Event"
    Then there should be an event "New Admin Event"
    And I should see a notice that "The event has been saved."
    And I should be on the page for the event "New Admin Event"

  @future
  Scenario: Admin views the list of pending events
  @future
  Scenario: Admin rejects an event posted by a user
  @future
  Scenario: Admin approves an event posted by a user

  Scenario: Admin updates an event
    Given I have signed in as an admin
    And there is an event "Existing Event"
    When I go to the page for the event "Existing Event"
    And I follow "Edit"
    And I fill in "Title" with "Updated Event"
    And I press "Save Event"
    Then I should see a notice that "The event has been saved."
    And I should be on the page for the event "Updated Event"

  Scenario: Admin deletes an event
    Given I have signed in as an admin
    And there is an event "Delete This Event"
    When I go to the page for the event "Delete This Event"
    And I follow "Delete"
    # which, in an actual browser, would put up a confirmation alert
    Then there should not be an event "Delete This Event"

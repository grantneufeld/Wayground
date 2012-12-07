Feature: Events have External Links
  In order to provide more value to users
  As an admin
  I want to be able to attach External Links to Events

  Scenario: Admin adds an external link while creating an event
    Given I have signed in as an admin
    When I go to the event form
    And I fill in "Start at" with "February 23, 2014, 12:30 PM"
    And I fill in "End at" with "February 23, 2014, 12:45 PM"
    And I fill in "event_title" with "New Event With Link"
    And I fill in "event_description" with "This is an event, newly posted by an admin, that includes a link."
    And I fill in "event_external_links_attributes_0_url" with "http://create.event.tld/"
    And I press "Save Event"
    Then the event "New Event With Link" should have the link "http://create.event.tld/"

  Scenario: Admin adds an external link while updating an event
    Given I have signed in as an admin
    And there is an event "Linkless Event"
    When I go to the page for the event "Linkless Event"
    And I follow "Edit"
    And I fill in "event_title" with "Linked Event"
    And I fill in "event_external_links_attributes_0_url" with "http://addlink.event.tld/"
    And I press "Save Event"
    Then the event "Linked Event" should have the link "http://addlink.event.tld/"

  Scenario: Admin removes an external link while updating an event
    Given I have signed in as an admin
    And there is an event "Event With Link" with link ""
    When I go to the page for the event "Event With Link"
    And I follow "Edit"
    And I fill in "event_title" with "De-Linked Event"
    And I check "event_external_links_attributes_0__destroy"
    And I press "Save Event"
    Then the event "De-Linked Event" should not have any links

  @future
  Scenario: Admin sorts the order of external links attached to an event


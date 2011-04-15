Feature: Custom Paths (URLs)
  In order to improve findability of content and comprehensibility for users of resource identifiers
  As a user or search engine
  I want to access the website’s content using meaningful urls

  Scenario: Show default home page when no home path is set
    Given there are no custom paths
    When I go to the home page
    Then I should see the default home page

  Scenario: Create a custom path that redirects to a different url on the site
    Given I have signed in as an admin
    When I create a custom path "/redirect/url" that redirects to "/"
    And I go to "/redirect/url"
    Then I should be redirected to "/"

  Scenario: Create a custom path that redirects to a url on another site
    Given I have signed in as an admin
    When I create a custom path "/remote/url" that redirects to "http://wayground.ca/"
    And I use the custom path "/remote/url"
    Then I should be redirected to "http://wayground.ca/"

  Scenario: Update a path to a new location
    Given I have signed in as an admin
    And I have a custom path "/custom/path"
    When I update the custom path "/custom/path" to "/revised/path"
    Then I should not have a custom path "/custom/path"
    And I should have a custom path "/revised/path"

  Scenario: try to update a path with invalid parameters
    Given I have signed in as an admin
    And I have a custom path "/custom/path"
    When I fill out the form to edit a custom path "/custom/path" with invalid data
    Then I should see errors for Sitepath and Redirect

  Scenario: Delete a path
    Given I have signed in as an admin
    And I have a custom path "/custom/path"
    When I delete the custom path "/custom/path"
    Then I should not have a custom path "/custom/path"

  Scenario: Review the custom paths used by the website
    Given I have some custom paths
    Then I should just be able to see the public paths for the website

  Scenario: As an admin, review the custom paths used by the website
    Given I have some custom paths
    And I have signed in as an admin
    Then I should be able to see the all paths for the website


# AUTHORIZATIONS

  @allow-rescue
  Scenario: try to access the path creation form without authorization
    When I go to the custom path form
    Then I should be denied access

  @allow-rescue
  Scenario: try to create a path without authorization
    When I try to create a custom path "/custom/path" that redirects to "/"
    Then I should be denied access

  @allow-rescue
  Scenario: try to access the path edit form without authorization
    Given I have a custom path "/custom/path"
    When I go to the edit form for custom path "/custom/path"
    Then I should be denied access

  @allow-rescue
  Scenario: try to update a path without authorization
    Given I have a custom path "/custom/path"
    When I try to update the custom path "/custom/path" to "/revised/path"
    Then I should be denied access

  @allow-rescue
  Scenario: try to delete a path without authorization
    Given I have a custom path "/custom/path"
    When I try to delete the custom path "/custom/path"
    Then I should be denied access

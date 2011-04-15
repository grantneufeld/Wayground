Feature: Custom Web Pages
  In order to have arbitrary content available as web pages on the site
  As a content editor
  I want to be able to create and manage custom web pages

  # VIEW

  @future
  Scenario: View a public web page

  # CREATE

  @future
  Scenario: try to create a web page with invalid params

  Scenario: Create a new web page with a custom path
    Given I am authorized to manage web pages
    When I create a web page as "newpage"
    And I look at "/newpage"
    Then I should see the web page for "newpage"

  @future
  Scenario: try to create a new web page with an invalid custom path
  @future
  Scenario: Create a web page as a sub-page for a parent page
  @future
  Scenario: try to create a web page as a sub-page for an invalid parent page
  @future
  Scenario: Create a home page

  # UPDATE

  @future
  Scenario: Update a web page

  @future
  Scenario: try to update a web page with invalid params

  # DELETE

  @future
  Scenario: Delete a web page

  @future
  Scenario: a page without a title should use the filename as the title


  # AUTHORIZATIONS

  @future
  Scenario: users with authority to modify a page see appropriate links on a page

  @future
  Scenario: users with authorities to modify pages see appropriate links on the page index

  @future @allow-rescue
  Scenario: try to access the new web page form without authorization

  @future @allow-rescue
  Scenario: try to create a web page without authorization

  @future @allow-rescue
  Scenario: try to access the web page edit form without authorization

  @future @allow-rescue
  Scenario: try to update a web page without authorization

  @future @allow-rescue
  Scenario: try to delete a web page without authorization

  @future @allow-rescue
  Scenario: try to destroy a web page without authorization

  @future @allow-rescue
  Scenario: try to access a private page without authorization

  @future
  Scenario: an authorized user accesses a private page

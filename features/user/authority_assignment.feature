Feature: Authority assignment
  In order to assign access authorities to users
  As an admin
  I want to be able to set and change authorities for individual users

  # creating first user as admin

  Scenario: creating the first user
    Given there are no users or authorities
    When I sign up as "First Admin"
    Then the user "First Admin" should be an admin

  Scenario: users subsequent to the first user should not be admins by default
    Given there are no users or authorities
    When I sign up as "First Admin"
    And I sign out
    And I sign up as "Second Signup"
    Then the user "Second Signup" should not be an admin

  # setting user access

  @allow-rescue
  Scenario: a user who is not logged in cannot access authority admin
    When I go to the authorities index
    Then I should be denied access

  @allow-rescue
  Scenario: a non-admin user cannot access authority admin
    Given there is already an admin user "Test Admin"
    When I sign in as "Test User"
    And I go to the authorities index
    Then I should be denied access

  Scenario: an admin can access list of authorities
    Given there is an admin user "Test Admin"
    When I sign in as "Test Admin"
    And I go to the authorities index
    Then I should see the authorities index

  Scenario: an admin can review an authority
    Given there is an admin user "Test Admin"
    When I sign in as "Test Admin"
    And I go to the authorities index
    And I follow "Show"
    Then I should be on an authority page

  Scenario: an admin can add an area-specific authority
    Given there is an admin user "Test Admin"
    And there is a user "Test User"
    When I sign in as "Test Admin"
    And I add an authority for "Test User" to edit Users
    Then "Test User" should have authority to edit Users

  Scenario: an admin can add a global authority
    Given there is an admin user "Test Admin"
    And there is a user "Test User"
    When I sign in as "Test Admin"
    And I add an authority for "Test User" to edit globally
    Then "Test User" should have authority to edit anything

  @future
  Scenario: an admin can add an item-specific authority

  Scenario: attempt to add an authority with invalid params
    Given there is an admin user "Test Admin"
    When I sign in as "Test Admin"
    And I try to add an authority with invalid settings
    Then I should see errors for User and Area

  Scenario: an admin can modify an authority
    Given there is an admin user "Test Admin"
    And there is a user "Test User"
    And "Test User" has authority to edit Users
    When I sign in as "Test Admin"
    And I add an authority for "Test User" to delete Users
    Then "Test User" should have authority to edit Users
    And "Test User" should have authority to delete Users

  @future
  Scenario: attempt to update an authority with invalid params

  Scenario: an admin can remove an authority
    Given there is an admin user "Test Admin"
    And there is a user "Test User"
    And "Test User" has authority to edit Users
    When I sign in as "Test Admin"
    And I remove the authority to edit Users from "Test User"
    Then "Test User" should not have authority to edit Users

# The following is a straight copy from an incomplete project.
# They may not all be useful or applicable now.

  # accessing an item
  @future
  Scenario: user with no authorities blocked from accessing an item
  @future
  Scenario: user with global authority can access an item
  @future
  Scenario: user with area-specific authority can access an item
  @future
  Scenario: user with item-specific authority can access an item

  # adding an item (page)
  @future
  Scenario: user with no authority cannot add a page
  @future
  Scenario: user with global authority can add a page
  @future
  Scenario: user with area-specific authority can add a page
  @future
  Scenario: user with item-specific authority can add a sub-page

  # modifying an item (page)
  @future
  Scenario: user with no authority cannot edit a page
  @future
  Scenario: user with global authority can edit a page
  @future
  Scenario: user with area-specific authority can edit a page
  @future
  Scenario: user with item-specific authority can edit a page

  # removing an item
  @future
  Scenario: user with no authority cannot remove an item
  @future
  Scenario: user with global authority can remove an item
  @future
  Scenario: user with area-specific authority can remove an item
  @future
  Scenario: user with item-specific authority can remove an item


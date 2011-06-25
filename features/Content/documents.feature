Feature: Documents (files)
  In order to provide more value to users
  As a user
  I want to be able to upload and retrieve documents

  Scenario: User uploads a document
    Given I am authorized to upload documents
    And there is no document "sample.txt" in the system
    When I upload a document "sample.txt"
    Then there should be a document "sample.txt" in the system

  Scenario: User downloads a document
    Given a document "sample.txt"
    Then I should be able to download the document file "sample.txt"

  Scenario: User renames a document
    Given I have uploaded a document "sample.txt"
    When I edit the document "sample.txt"
    And I fill in "filename" with "changed.txt"
    And I save the document
    Then there should be a document "changed.txt"
    And there should not be a document "sample.txt"

  Scenario: User changes a document description
    Given I have uploaded a document "sample.txt"
    When I edit the document "sample.txt"
    And I fill in "Description" with "Changed."
    And I save the document
    Then the document "sample.txt" should have the description "Changed."

  Scenario: User deletes a document
    Given I have uploaded a document "sample.txt"
    When I delete the document "sample.txt"
    Then there should not be a document "sample.txt"

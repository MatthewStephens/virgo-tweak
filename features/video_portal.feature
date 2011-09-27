Feature: Video Portal
  In order to get only the relevant information about videos
  As a user
  I want to see accurate information
  
  Scenario:  Display featured items on the video portal homepage
    Given I am on the homepage
    And I follow "Video Search"
    Then I should see "Recently Added Items"
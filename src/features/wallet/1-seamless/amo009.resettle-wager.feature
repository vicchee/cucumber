Feature: AMO009 Seamless Resettle Wager
  As APISYS
  I want to call the merchant resettle wager API
  So that I can apply corrected settlement amounts

  Background:
    Given a merchant member exists

  Scenario: Resettlement increases the wallet balance
    Given I record the current wallet balance in "<currency>"
    When APISYS resettles a wager with:
      | field          | value                |
      | transaction_no | <transaction_no>     |
      | currency       | <currency>           |
      | amount         | 12.5                 |
    Then the AMO009 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 12.5

  Scenario: Resettlement decreases the wallet balance
    Given I record the current wallet balance in "<currency>"
    When APISYS resettles a wager with:
      | field          | value                |
      | transaction_no | <transaction_no>     |
      | currency       | <currency>           |
      | amount         | -4.25                |
    Then the AMO009 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should decrease by 4.25
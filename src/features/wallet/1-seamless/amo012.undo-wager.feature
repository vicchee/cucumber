Feature: AMO012 Seamless Undo Wager
  As APISYS
  I want to call the merchant undo wager API
  So that I can reverse a previous wager wallet effect

  Background:
    Given a merchant member exists

  Scenario: Undo wager increases wallet balance
    Given I record the current wallet balance in "<currency>"
    When APISYS undoes a wager with:
      | field          | value                |
      | transaction_no | <transaction_no>     |
      | currency       | <currency>           |
      | amount         | 15                   |
    Then the AMO012 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 15

  Scenario: Undo wager decreases wallet balance
    Given I record the current wallet balance in "<currency>"
    When APISYS undoes a wager with:
      | field          | value                |
      | transaction_no | <transaction_no>     |
      | currency       | <currency>           |
      | amount         | -7                   |
    Then the AMO012 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should decrease by 7
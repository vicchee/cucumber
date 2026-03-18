Feature: AMO007 Seamless Settle Wager
  As APISYS
  I want to call the merchant settle wager API
  So that I can apply wager settlement results to the member wallet

  Background:
    Given a merchant member exists

  Scenario: Full settlement credits the wallet
    Given I record the current wallet balance in "<currency>"
    When APISYS settles a wager with:
      | field                 | value                |
      | transaction_no        | <transaction_no>     |
      | currency              | <currency>           |
      | amount                | 25.75                |
      | is_partial_settlement | false                |
    Then the AMO007 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 25.75

  Scenario: Full settlement applies main amount and partial history together
    Given I record the current wallet balance in "<currency>"
    When APISYS settles a wager with:
      | field                 | value                |
      | transaction_no        | <transaction_no>     |
      | currency              | <currency>           |
      | amount                | 10                   |
      | is_partial_settlement | false                |
    And partial settlement history contains:
      | field          | value                      |
      | transaction_no | <partial_transaction_no_1> |
      | amount         | 2.5                        |
      | transaction_no | <partial_transaction_no_2> |
      | amount         | -1                         |
    Then the AMO007 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 11.5

  Scenario: Partial settlement does not update the wallet
    Given I record the current wallet balance in "<currency>"
    When APISYS settles a wager with:
      | field                 | value                |
      | transaction_no        | <transaction_no>     |
      | currency              | <currency>           |
      | amount                | 99                   |
      | is_partial_settlement | true                 |
    Then the AMO007 response should be successful
    And the response should contain:
      | field        | value                |
      | reference_id | <transaction_no>     |
    And the wallet balance in "<currency>" should remain unchanged

  Scenario: Validation fails when amount has more than 6 decimal places
    When APISYS settles a wager with:
      | field                 | value                |
      | transaction_no        | <transaction_no>     |
      | currency              | <currency>           |
      | amount                | 1.1234567            |
      | is_partial_settlement | false                |
    Then the AMO007 response should fail validation
Feature: AMO004 Seamless Notify Payment Failed
  As APISYS
  I want to notify the merchant that a payment failed

  Background:
    Given a merchant member exists

  Scenario: Refund restores deducted amount
    Given I record the current wallet balance in "<currency>"
    And a prepared request payment fixture exists for:
      | field            | value              |
      | parent_wager_no  | <parent_wager_no>  |
      | payment_order_no | <payment_order_no> |
      | currency         | <currency>         |
      | amount           | -45                |
    When APISYS notifies payment failed with:
      | field           | value                |
      | transaction_no  | <transaction_no>     |
      | parent_wager_no | <parent_wager_no>    |
    Then the AMO004 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 45

  Scenario: Validation fails when transaction number is not UUIDv4
    When APISYS notifies payment failed with:
      | field           | value             |
      | transaction_no  | not-a-uuid        |
      | parent_wager_no | <parent_wager_no> |
    Then the AMO004 response should fail validation
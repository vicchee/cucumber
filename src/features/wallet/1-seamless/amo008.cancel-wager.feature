Feature: AMO008 Seamless Cancel Wager
  As APISYS
  I want to call the merchant cancel wager API
  So that I can refund a previously paid wager

  Background:
    Given a merchant member exists

  Scenario: Cancel wager refunds a prepared paid wager
    Given I record the current wallet balance in "<currency>"
    And a prepared paid wager fixture exists for:
      | field            | value              |
      | wager_no         | <wager_no>         |
      | parent_wager_no  | <parent_wager_no>  |
      | payment_order_no | <payment_order_no> |
      | currency         | <currency>         |
      | payment_amount   | 30                 |
    When APISYS cancels a wager with:
      | field          | value                |
      | transaction_no | <transaction_no>     |
      | wager_no       | <wager_no>           |
    Then the AMO008 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 30
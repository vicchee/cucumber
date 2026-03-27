Feature: AMO004 Seamless Notify Payment Failed
  As APISYS
  I want to notify the merchant when a payment fails

  Background:
    Given a merchant member exists

  Scenario: Payment failed notification refunds deducted amount
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    And I prepare a deduction amount of 45

    When APISYS requests payment with:
      | field             | value               |
      | transaction_no    | <transaction_no>    |
      | game_key          | <game_key_seamless> |
      | parent_wager_no   | <parent_wager_no>   |
      | platform_username | <platform_username> |
      | currency          | <currency>          |
      | amount            | -45                 |
      | orders            | [{ "wager_no": "<wager_no_1>", "ticket_no": "<ticket_no>", "type": <wager_type.normal_wager>, "amount": 45, "payment_amount": 45, "effective_amount": 45, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": <is_system_reward> }] |
    Then the AMO003 response should be successful
    And the wallet balance in "<currency>" should decrease by 45

    When APISYS notifies payment failed with:
      | field             | value               |
      | transaction_no    | <transaction_no>    |
      | game_key          | <game_key_seamless> |
      | parent_wager_no   | <parent_wager_no>   |
      | platform_username | <platform_username> |
    Then the AMO004 response should be successful 
    And the response should contain: 
      | field             | value               |
      | reference_id      | any non-empty value |
    And the wallet balance in "<currency>" should increase by 45
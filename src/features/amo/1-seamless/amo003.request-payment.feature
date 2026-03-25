Feature: AMO003 Seamless Request Payment
  As APISYS
  I want to call the merchant request payment API
  So that I can deduct wager payment from the member wallet

  Background:
    Given a merchant member exists

  Scenario: Successful request payment deducts wallet balance for a single wager
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    And I prepare a deduction amount of 10
    When APISYS requests payment with:
      | field             | value               |
      | transaction_no    | <transaction_no>    |
      | game_key          | <game_key_seamless> |
      | parent_wager_no   | <parent_wager_no>   |
      | platform_username | <platform_username> |
      | currency          | <currency>          |
      | amount            | -<deduction_amount> |
      | orders            | [{ "wager_no": "<wager_no_1>", "ticket_no": "<ticket_no_1>", "type": <wager_type.normal_wager>, "amount": <deduction_amount>, "payment_amount": <deduction_amount>, "effective_amount": <deduction_amount>, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": <is_system_reward> }] |
    Then the AMO003 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | status       | 1                   |
    And the wallet balance in "<currency>" should decrease by "<deduction_amount>"

  Scenario: Successful request payment deducts the summed payment amount for multiple wagers
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When APISYS requests payment with:
      | field             | value               |
      | transaction_no    | <transaction_no>    |
      | game_key          | <game_key_seamless> |
      | parent_wager_no   | <parent_wager_no>   |
      | platform_username | <platform_username> |
      | currency          | <currency>          |
      | amount            | -10                |
      | orders            | [{ "wager_no": "<wager_no_1>", "ticket_no": "<ticket_no_1>", "type": <wager_type.normal_wager>, "amount": 5, "payment_amount": 5, "effective_amount": 5, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": true }, { "wager_no": "<wager_no_2>", "ticket_no": "<ticket_no_2>", "type": <wager_type.free_bet>, "amount": 5, "payment_amount": 5, "effective_amount": 5, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": false }] |
    Then the AMO003 response should be successful
    And the response should contain:
      | field              | value               |
      | reference_id       | any non-empty value |
      | status             | 1                   |
    And the wallet balance in "<currency>" should decrease by 10

  Scenario: Insufficient balance returns failed status without changing wallet balance
    Given I record the current wallet balance in "<currency>"
    And I prepare an amount exceeding the balance by 10
    When APISYS requests payment with:
      | field             | value                       |
      | transaction_no    | <transaction_no>            |
      | game_key          | <game_key_seamless>         |
      | parent_wager_no   | <parent_wager_no>           |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | -<amount_exceeding_balance> |
      | orders            | [{ "wager_no": "<wager_no_1>", "ticket_no": "<ticket_no_1>", "type": <wager_type.normal_wager>, "amount": <amount_exceeding_balance>, "payment_amount": <amount_exceeding_balance>, "effective_amount": <amount_exceeding_balance>, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": <is_system_reward> }] |
    Then the AMO003 response should be successful
    And the response should contain:
      | field             | value               |
      | reference_id      | <transaction_no>    |
      | status            | 2                   |
      | fail_reason       | 3                   |
    And the wallet balance in "<currency>" should remain unchanged

  Scenario: Zero amount request payment is allowed
    Given I record the current wallet balance in "<currency>"
    When APISYS requests payment with:
      | field             | value               |
      | transaction_no    | <transaction_no>    |
      | game_key          | <game_key_seamless> |
      | parent_wager_no   | <parent_wager_no>   |
      | platform_username | <platform_username> |
      | currency          | <currency>          |
      | amount            | 0                   |
      | orders            | [{ "wager_no": "<wager_no_1>", "ticket_no": "<ticket_no_1>", "type": <wager_type.normal_wager>, "amount": 0, "payment_amount": 0, "effective_amount": 0, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": <is_system_reward> }] |
    Then the AMO003 response should be successful
    And the response should contain:
      | field             | value               |
      | reference_id      | any non-empty value |
      | status            | 1                   |
    And the wallet balance in "<currency>" should remain unchanged

  Scenario: Validation fails when amount is positive
    When APISYS requests payment with:
      | field             | value               |
      | transaction_no    | <transaction_no>    |
      | game_key          | <game_key_seamless> |
      | parent_wager_no   | <parent_wager_no>   |
      | platform_username | <platform_username> |
      | currency          | <currency>          |
      | amount            | 5                   |
      | orders            | [{ "wager_no": "<wager_no_1>", "ticket_no": "<ticket_no_1>", "type": <wager_type.normal_wager>, "amount": 5, "payment_amount": 5, "effective_amount": 5, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": <is_system_reward> }] |
    Then the AMO003 response should fail validation

  Scenario: Validation fails when amount has more than 6 decimal places
    When APISYS requests payment with:
      | field             | value               |
      | transaction_no    | <transaction_no>    |
      | game_key          | <game_key_seamless> |
      | parent_wager_no   | <parent_wager_no>   |
      | platform_username | <platform_username> |
      | currency          | <currency>          |
      | amount            | -1.1234567          |
      | orders            | [{ "wager_no": "<wager_no_1>", "ticket_no": "<ticket_no_1>", "type": <wager_type.normal_wager>, "amount": 1.1234567, "payment_amount": 1.1234567, "effective_amount": 1.1234567, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": <is_system_reward> }] |
    Then the AMO003 response should fail validation
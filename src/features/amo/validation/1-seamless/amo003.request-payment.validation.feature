Feature: Validation: AMO003 Seamless Request Payment
  As APISYS
  I want to call the merchant request payment API
  So that I can deduct wager payment from the member wallet correctly according to business rules

  Background:
    Given a merchant member exists

  Scenario: Successful request payment deducts wallet balance for a single wager
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    And I prepare a deduction amount of 10
    When I call AMO003 API with:
      | field             | value                |
      | transaction_no    | <transaction_no>     |
      | game_key          | <game_key_seamless>  |
      | parent_wager_no   | <parent_wager_no>    |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | -<deduction_amount>  |
      | orders            | [{ "wager_no": <wager_no_1>, "ticket_no": <ticket_no_1>, "type": <wager_type.normal_wager>, "amount": <deduction_amount>, "payment_amount": <deduction_amount>, "effective_amount": <deduction_amount>, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": <is_system_reward> }] |
    Then the response should be successful
    And the response should contain:
      | field             | value                |
      | reference_id      | any non-empty value  |
      | status            | 1                    |
    And the wallet balance in "<currency>" should decrease by "<deduction_amount>"

  Scenario: Successful request payment deducts the summed payment amount for multiple wagers
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I call AMO003 API with:
      | field             | value                |
      | transaction_no    | <transaction_no>     |
      | game_key          | <game_key_seamless>  |
      | parent_wager_no   | <parent_wager_no>    |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | -10                  |
      | orders            | [{ "wager_no": <wager_no_1>, "ticket_no": <ticket_no_1>, "type": <wager_type.normal_wager>, "amount": 5, "payment_amount": 5, "effective_amount": 5, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": true }, { "wager_no": <wager_no_2>, "ticket_no": <ticket_no_2>, "type": <wager_type.free_bet>, "amount": 5, "payment_amount": 5, "effective_amount": 5, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": false }] |
    Then the response should be successful
    And the response should contain:
      | field             | value                |
      | reference_id      | any non-empty value  |
      | status            | 1                    |
    And the wallet balance in "<currency>" should decrease by 10

  Scenario: Validation fails when amount has more than 6 decimal places
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I call AMO003 API with:
      | field             | value                |
      | transaction_no    | <transaction_no>     |
      | game_key          | <game_key_seamless>  |
      | parent_wager_no   | <parent_wager_no>    |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | -1.1234567            |
      | orders            | [{ "wager_no": <wager_no_1>, "ticket_no": <ticket_no_1>, "type": <wager_type.normal_wager>, "amount": 1.1234567, "payment_amount": 1.1234567, "effective_amount": 1.1234567, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": <is_system_reward> }] |
    Then the response should fail validation


  Scenario Outline: Validation fails when required field "<required_field>" is missing
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I prepare a request payload with:
      | field             | value                |
      | transaction_no    | <transaction_no>     |
      | game_key          | <game_key_seamless>  |
      | parent_wager_no   | <parent_wager_no>    |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | -5                   |
      | orders            | [{ "wager_no": <wager_no_1>, "ticket_no": <ticket_no_1>, "type": <wager_type.normal_wager>, "amount": 5, "payment_amount": 5, "effective_amount": 5, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": true }]  |
    And I remove "<required_field>" from the request payload
    When I call AMO003 API
    Then the response should fail validation
    And the wallet balance in "<currency>" should remain unchanged

    Examples:
      | required_field    |
      | transaction_no    |
      | game_key          |
      | parent_wager_no   |
      | platform_username |
      | currency          |
      | amount            |
      | orders            |
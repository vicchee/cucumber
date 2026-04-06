@seamless
Feature: AMO003 Request Payment
  As APISYS
  I want to call the merchant request payment API
  So that I can deduct wager payment from the member wallet correctly according to business rules

  Background:
    Given a merchant member exists

  @success
  Scenario: Deduct balance for single wager
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    And I prepare a deduction amount of 10
    When I call AMO003 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -<deduction_amount>,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": <deduction_amount>,
            "payment_amount": <deduction_amount>,
            "effective_amount": <deduction_amount>,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the response should be successful
    And the response should contain:
      | field             | value                |
      | reference_id      | any non-empty value  |
      | status            | 1                    |
    And the wallet balance in "<currency>" should decrease by "<deduction_amount>"

  @success
  Scenario: Deduct summed amount for multiple wagers
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I call AMO003 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -10,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": 5,
            "payment_amount": 5,
            "effective_amount": 5,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": true
          },
          {
            "wager_no": <wager_no_2>,
            "ticket_no": <ticket_no_2>,
            "type": <wager_type.system_reward>,
            "amount": 5,
            "payment_amount": 5,
            "effective_amount": 5,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": false
          }
        ]
      }
      """
    Then the response should be successful
    And the response should contain:
      | field             | value                |
      | reference_id      | any non-empty value  |
      | status            | 1                    |
    And the wallet balance in "<currency>" should decrease by 10

  @business
  Scenario: Return failure for insufficient balance without balance change
    Given I record the current wallet balance in "<currency>"
    And I prepare an amount exceeding the balance by 10
    When I call AMO003 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -<amount_exceeding_balance>,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": <amount_exceeding_balance>,
            "payment_amount": <amount_exceeding_balance>,
            "effective_amount": <amount_exceeding_balance>,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the response should be successful
    And the response should contain:
      | field             | value                      |
      | reference_id      | <transaction_no>           |
      | status            | 2                          |
      | fail_reason       | 3                          |
    And the wallet balance in "<currency>" should remain unchanged

  @business
  Scenario: Allow zero amount without balance change
    Given I record the current wallet balance in "<currency>"
    When I call AMO003 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": 0,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": 0,
            "payment_amount": 0,
            "effective_amount": 0,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the response should be successful
    And the response should contain:
      | field             | value                |
      | reference_id      | any non-empty value  |
      | status            | 1                    |
    And the wallet balance in "<currency>" should remain unchanged

  @edge
  Scenario: Support up to 6 decimal places
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I call AMO003 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -1.123456,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": 1.123456,
            "payment_amount": 1.123456,
            "effective_amount": 1.123456,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the response should be successful
    And the response should contain:
      | field             | value                |
      | reference_id      | any non-empty value  |
      | status            | 1                    |
    And the wallet balance in "<currency>" should decrease by 1.123456

  @idempotency
  Scenario: Handle idempotent request payment
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    And I prepare a deduction amount of 10
    When I call AMO003 "Request Payment" API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -<deduction_amount>,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": <deduction_amount>,
            "payment_amount": <deduction_amount>,
            "effective_amount": <deduction_amount>,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the response should be successful
    And I store the full response as "first_response"
    And the wallet balance in "<currency>" should decrease by "<deduction_amount>"

    Given I record the current wallet balance in "<currency>"
    When I call AMO003 "Request Payment - Duplicate transaction_no" API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -<deduction_amount>,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": <deduction_amount>,
            "payment_amount": <deduction_amount>,
            "effective_amount": <deduction_amount>,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the response should be the same as stored response "first_response"
    And the wallet balance in "<currency>" should remain unchanged

  @validation
  Scenario: Fail validation - positive amount
    When I call AMO003 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": 5,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": 5,
            "payment_amount": 5,
            "effective_amount": 5,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the response should fail validation

  @validation @optional
  Scenario: Fail validation - amount exceeds 6 decimal places
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I call AMO003 API with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -1.1234567,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": 1.1234567,
            "payment_amount": 1.1234567,
            "effective_amount": 1.1234567,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the response should fail validation

  @validation @optional
  Scenario Outline: Fail validation - missing required field "<required_field>"
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When I prepare a request payload with:
      """
      {
        "transaction_no": <transaction_no>,
        "game_key": <game_key_seamless>,
        "parent_wager_no": <parent_wager_no>,
        "platform_username": <platform_username>,
        "currency": <currency>,
        "amount": -5,
        "orders": [
          {
            "wager_no": <wager_no_1>,
            "ticket_no": <ticket_no_1>,
            "type": <wager_type.normal_wager>,
            "amount": 5,
            "payment_amount": 5,
            "effective_amount": 5,
            "metadata": <metadata>,
            "metadata_type": <metadata_type>,
            "wager_time": <wager_time>,
            "is_system_reward": true
          }
        ]
      }
      """
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
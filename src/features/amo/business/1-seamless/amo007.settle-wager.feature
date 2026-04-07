@seamless
Feature: AMO007 Settle Wager
  As APISYS
  I want to call the merchant settle wager API
  So that I can apply wager settlement results to the member wallet
  Update a Pending (0) wager to Partial Settled (12) / Settled (2) state
  Support partial settlement and final settlement for the same wager_no
  Wallet balance changes only by settlement amounts not already processed

  Background:
    # create a pending wager before each settlement scenario
    Given the member has positive wallet balance in "<currency>"
    And I prepare a deduction amount of 100
    When I call AMO003 "Request Payment - Create pending wager" API with:
      """
      {
        "transaction_no": <transaction_no_1>,
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

  @success
  Scenario: Support settlement for a wager without partial settlement history
    Process settlement for a pending wager
    Validate settlement can be completed without partial settlement history
    Wallet balance increases by the settlement amount

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Full settlement" API with:
      """
      {
        "transaction_no": <transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 150,
        "effective_amount": 100,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 150

  @success
  Scenario: Support partial settlement for a wager
    Process partial settlement for a pending wager
    Validate the same wager_no can be settled in parts before final settlement
    Wallet balance increases by the partial settlement amount

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Partial settlement" API with:
      """
      {
        "transaction_no": <transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 40,
        "effective_amount": 100,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": true
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 40

  @success @business
  Scenario: Process final settlement without partial settlements that have already occurred
    Process final settlement with partial settlement history
    Validate only unprocessed partial settlement amounts are applied
    Wallet balance increases by net remaining settlement amount

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Partial settlement 1" API with:
      """
      {
        "transaction_no": <partial_transaction_no_1>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 20,
        "effective_amount": 20,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": true
      }
      """
    Then the response should be successful
    And the wallet balance in "<currency>" should increase by 20

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Partial settlement 2" API with:
      """
      {
        "transaction_no": <partial_transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 15,
        "effective_amount": 15,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": true
      }
      """
    Then the response should be successful
    And the wallet balance in "<currency>" should increase by 15

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Final settlement with partial history" API with:
      """
      {
        "transaction_no": <transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 80,
        "effective_amount": 80,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false,
        "partial_settlement_history": [
          {
            "transaction_no": <partial_transaction_no_1>,
            "amount": 20,
            "settlement_time": <settlement_time>
          },
          {
            "transaction_no": <partial_transaction_no_2>,
            "amount": 15,
            "settlement_time": <settlement_time>
          },
          {
            "transaction_no": <partial_transaction_no_3>,
            "amount": 5,
            "settlement_time": <settlement_time>
          }
        ]
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 85

  @business
  Scenario: Support multiple partial settlements for the same wager_no
    Process multiple partial settlements for the same wager_no
    Validate repeated partial settlements are allowed before final settlement
    Wallet balance increases by each partial settlement amount when processed

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Partial settlement 1" API with:
      """
      {
        "transaction_no": <partial_transaction_no_1>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 30,
        "effective_amount": 100,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": true
      }
      """
    Then the response should be successful
    And the wallet balance in "<currency>" should increase by 30

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Partial settlement 2" API with:
      """
      {
        "transaction_no": <partial_transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 25,
        "effective_amount": 100,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": true
      }
      """
    Then the response should be successful
    And the wallet balance in "<currency>" should increase by 25

  @business
  Scenario: Allow zero amount without balance change
    Process settlement with zero amount
    Validate zero amount is accepted as a valid settlement result
    Wallet balance remains unchanged

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Zero amount - Lose" API with:
      """
      {
        "transaction_no": <transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 0,
        "effective_amount": 100,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should remain unchanged

  @edge
  Scenario: Support up to 6 decimal places
    Process settlement amount with up to 6 decimal places
    Validate decimal precision up to 6 places is supported
    Wallet balance updates without rounding errors

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - 6 decimal places" API with:
      """
      {
        "transaction_no": <transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 1.123456,
        "effective_amount": 100,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 1.123456

  @idempotency
  Scenario: Handle idempotent full settlement
    Process duplicate full settlement request with the same transaction_no
    Validate same reference_id is returned
    Wallet balance is updated only once

    Given I record the current wallet balance in "<currency>"
    When I prepare a request payload with:
      """
      {
        "transaction_no": <transaction_no_2>,
        "game_key": <game_key_seamless>,
        "wager_no": <wager_no_1>,
        "platform_username": <platform_username>,
        "type": <wager_type.normal_wager>,
        "currency": <currency>,
        "amount": 150,
        "effective_amount": 100,
        "settlement_time": <settlement_time>,
        "metadata": <metadata>,
        "metadata_type": <metadata_type>,
        "is_system_reward": <is_system_reward>,
        "is_partial_settlement": false
      }
      """
    And I call AMO007 "Settle Wager - First request" API
    Then the response should be successful
    And I store the full response as "first_response"
    And the wallet balance in "<currency>" should increase by 150

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Duplicate transaction_no" API
    Then the response should be the same as stored response "first_response"
    And the wallet balance in "<currency>" should remain unchanged
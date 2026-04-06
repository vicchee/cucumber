@seamless
Feature: AMO007 Settle Wager
  As APISYS
  I want to call the merchant settle wager API
  So that I can apply wager settlement results to the member wallet

  Background:
    Given a merchant member exists
    # create a pending wager before each settlement scenario
    And the member has positive wallet balance in "<currency>"
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
  Scenario: Increase balance for full settlement without partial settlement history
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Full Settlement" API with:
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
  Scenario: Increase balance for partial settlement
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Partial Settlement" API with:
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
  Scenario: Increase balance for final settlement including only unprocessed partial settlement history
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Partial Settlement 1" API with:
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
    When I call AMO007 "Settle Wager - Partial Settlement 2" API with:
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
    When I call AMO007 "Settle Wager - Final Settlement With Partial History" API with:
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
  Scenario: Increase balance for multiple partial settlements on the same wager_no
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Partial Settlement 1" API with:
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
    When I call AMO007 "Settle Wager - Partial Settlement 2" API with:
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
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Zero Amount" API with:
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
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - 6 Decimal Places" API with:
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
    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Full Settlement" API with:
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
    And I store the full response as "first_response"
    And the wallet balance in "<currency>" should increase by 150

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Duplicate transaction_no" API with:
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
    Then the response should be the same as stored response "first_response"
    And the wallet balance in "<currency>" should remain unchanged
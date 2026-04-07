@seamless
Feature: AMO004 Notify Payment Failed
  As APISYS
  I want to notify the merchant when a payment fails
  So that I can reverse the wallet effect of an unsuccessful request payment
  Fail all wagers under the same parent_wager_no
  Update a Creating (-1) wager to Creation Failed (7) state
  Wallet balance is restored only when a prior request payment exists

  Background:
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"

  @success
  Scenario: Notify payment failure for an existing request payment
    Process payment failure for an existing request payment
    Validate all wagers under the same parent_wager_no are failed together
    Wallet balance increases by the previously deducted amount

    Given I prepare a deduction amount of 100
    When I call AMO003 "Request Payment" API with:
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
    And the wallet balance in "<currency>" should decrease by 100

    Given I record the current wallet balance in "<currency>"
    When I call AMO004 "Notify Payment Failed" API with:
      | field             | value               |
      | transaction_no    | <transaction_no_2>  |
      | game_key          | <game_key_seamless> |
      | parent_wager_no   | <parent_wager_no>   |
      | platform_username | <platform_username> |
    Then the response should be successful
    And the response should contain: 
      | field             | value               |
      | reference_id      | any non-empty value |
    And the wallet balance in "<currency>" should increase by 100

  @business
  Scenario: Return success when no existing request payment is found
    Process payment failure without an existing request payment
    Validate request is accepted when no matching parent_wager_no exists
    Wallet balance remains unchanged

    When I call AMO004 "Notify Payment Failed" API with:
      | field             | value               |
      | transaction_no    | <transaction_no>    |
      | game_key          | <game_key_seamless> |
      | parent_wager_no   | <parent_wager_no>   |
      | platform_username | <platform_username> |

    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should remain unchanged
@seamless
Feature: AMO008 Cancel Wager
  As APISYS
  I want to call the merchant cancel wager API
  So that the merchant can cancel a wager and refund the member when necessary

  Background:
    Given a merchant member exists
    And the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    And I prepare a deduction amount of 10
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
    And the response should contain:
      | field             | value               |
      | reference_id      | any non-empty value |
      | status            | 1                   |
    And the wallet balance in "<currency>" should decrease by "<deduction_amount>"

  @success @idempotency
  Scenario: Refund on cancel then handle idempotent cancel

    # cancel wager to refund payment
    Given I record the current wallet balance in "<currency>"
    When I prepare a request payload with:
      | field             | value                 |
      | transaction_no    | <transaction_no_2>    |
      | game_key          | <game_key_seamless>   |
      | wager_no          | <wager_no_1>          |
      | platform_username | <platform_username>   |
      | metadata          | <metadata>            |
      | metadata_type     | <metadata_type>       |
    And I call AMO008 "Cancel Wager - First request" API
    Then the response should be successful
    And the response should contain:
      | field             | value                 |
      | reference_id      | any non-empty value   |
    And I store the response field "reference_id" as "amo008_reference_id"
    And the wallet balance in "<currency>" should increase by "<deduction_amount>"

    # cancel wager again to verify idempotency
    Given I record the current wallet balance in "<currency>"
    When I call AMO008 "Cancel Wager - Duplicate transaction_no" API
    Then the response should be successful
    And the response should contain:
      | field             | value                 |
      | reference_id      | <amo008_reference_id> |
    And the wallet balance in "<currency>" should remain unchanged
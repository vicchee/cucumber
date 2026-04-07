@seamless
Feature: AMO012 Undo Wager
  As APISYS
  I want to call the merchant undo wager API
  So that I can correct the wallet effect of a completed wager
  Only allowed for terminal state wagers (Settled (2) or Cancelled (9))
  Creates a new Undone (11) state wager referencing origin_wager_no

  Background:
    # Create the original wager W1 in pending state before each scenario.
    # Any terminal-state preparation (settle/cancel) is done inside the scenario.
    Given the member has positive wallet balance in "<currency>"
    And I prepare a deduction amount of 100
    When I call AMO003 "Request Payment - Create pending wager" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_1>        |
      | game_key          | <game_key_seamless>       |
      | parent_wager_no   | <parent_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | -<deduction_amount>       |
      | orders            | <orders_payload>          |
    Then the response should be successful

  @success @business
  Scenario: Undo the entire wager after settlement
    Reverse entire settled wager
    Validate both bet deduction and settlement payout are negated
    Final wallet balance returns to pre-wager state

    # Flow:
    # W1 request payment    -> wallet -100
    # W1 settle to win      -> wallet +150
    # W2 undo entire wager  -> wallet -150

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Full settlement - Win" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <origin_wager_no>         |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 150                       |
      | effective_amount      | 100                       |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | <is_system_reward>        |
      | is_partial_settlement | false                     |
    Then the response should be successful
    And the wallet balance in "<currency>" should increase by 150

    Given I record the current wallet balance in "<currency>"
    When I call AMO012 "Undo Wager - Entire wager" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <undo_wager_no_1>         |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | type              | <wager_type.normal_wager> |
      | currency          | <currency>                |
      | amount            | -150                      |
      | effective_amount  | 0                         |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should decrease by 150

  @business
  Scenario: Undo the settlement result only
    Reverse settlement result only
    Validate original wager deduction is retained
    Final wallet balance reflects only the bet amount

    # Flow:
    # W1 request payment     -> wallet -100
    # W1 settle to win       -> wallet +150
    # W2 undo settlement     -> wallet -50

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Full settlement - Win" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <origin_wager_no>         |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 150                       |
      | effective_amount      | 100                       |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | <is_system_reward>        |
      | is_partial_settlement | false                     |
    Then the response should be successful
    And the wallet balance in "<currency>" should increase by 150

    Given I record the current wallet balance in "<currency>"
    When I call AMO012 "Undo Wager - Settlement only" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_4>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <undo_wager_no_2>         |
      | ticket_no         | <ticket_no_3>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | type              | <wager_type.normal_wager> |
      | currency          | <currency>                |
      | amount            | -50                       |
      | effective_amount  | 0                         |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should decrease by 50

  @business
  Scenario: Undo the cancellation of a wager
    Reverse cancellation effect
    Validate refunded wager amount is deducted again
    Final wallet balance reflects original bet deduction

    # Flow:
    # W1 request payment  -> wallet -100
    # W1 cancel wager     -> wallet +100
    # W2 undo cancel      -> wallet -100
    #
    # This restores the original wager effect after the cancellation is reversed.
    Given I record the current wallet balance in "<currency>"
    When I call AMO008 "Cancel Wager" API with:
      | field             | value                 |
      | transaction_no    | <transaction_no_2>    |
      | game_key          | <game_key_seamless>   |
      | wager_no          | <origin_wager_no>     |
      | platform_username | <platform_username>   |
      | metadata          | <metadata>            |
      | metadata_type     | <metadata_type>       |
    Then the response should be successful
    And the wallet balance in "<currency>" should increase by 100

    Given I record the current wallet balance in "<currency>"
    When I call AMO012 "Undo Wager - Cancellation" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <undo_wager_no_1>         |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | type              | <wager_type.normal_wager> |
      | currency          | <currency>                |
      | amount            | -100                      |
      | effective_amount  | 0                         |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should decrease by 100

  @business
  Scenario: Allow zero amount without balance change
    Process undo with zero amount
    Validate flexible amount handling by game side
    Wallet balance remains unchanged

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Full settlement - Win" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <origin_wager_no>         |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 150                       |
      | effective_amount      | 100                       |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | <is_system_reward>        |
      | is_partial_settlement | false                     |
    Then the response should be successful

    Given I record the current wallet balance in "<currency>"
    When I call AMO012 "Undo Wager - Zero amount" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <undo_wager_no_1>         |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | type              | <wager_type.normal_wager> |
      | currency          | <currency>                |
      | amount            | 0                         |
      | effective_amount  | 0                         |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should remain unchanged

  @edge
  Scenario: Support up to 6 decimal places
    Process undo with decimal amount up to 6 places
    Validate decimal precision up to 6 places is supported
    Wallet balance updates without rounding errors

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Full settlement - Win" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <origin_wager_no>         |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 150                       |
      | effective_amount      | 100                       |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | <is_system_reward>        |
      | is_partial_settlement | false                     |
    Then the response should be successful

    Given I record the current wallet balance in "<currency>"
    When I call AMO012 "Undo Wager - 6 decimal places" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <undo_wager_no_1>         |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | type              | <wager_type.normal_wager> |
      | currency          | <currency>                |
      | amount            | -149.999999               |
      | effective_amount  | 0                         |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should decrease by 149.999999

  @idempotency
  Scenario: Handle idempotent undo wager
    Process duplicate undo request with same transaction_no
    Validate same reference_id is returned
    Wallet balance is updated only once

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager - Full settlement - Win" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <origin_wager_no>         |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 150                       |
      | effective_amount      | 100                       |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | <is_system_reward>        |
      | is_partial_settlement | false                     |
    Then the response should be successful

    Given I record the current wallet balance in "<currency>"
    When I prepare a request payload with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <undo_wager_no_1>         |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | type              | <wager_type.normal_wager> |
      | currency          | <currency>                |
      | amount            | -150                      |
      | effective_amount  | 0                         |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | is_system_reward  | <is_system_reward>        |
    And I call AMO012 "Undo Wager - First request" API
    Then the response should be successful
    And I store the full response as "first_response"
    And the wallet balance in "<currency>" should decrease by 150

    Given I record the current wallet balance in "<currency>"
    When I call AMO012 "Undo Wager - Duplicate transaction_no" API
    Then the response should be the same as stored response "first_response"
    And the wallet balance in "<currency>" should remain unchanged
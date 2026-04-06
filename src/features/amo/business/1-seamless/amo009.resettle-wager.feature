@seamless
Feature: AMO009 Resettle Wager
  As APISYS
  I want to call the merchant resettle wager API
  So that I can apply corrected settlement amounts to the member wallet

  Background:
    Given a merchant member exists
    # create a pending wager and settle it before each resettlement scenario
    And the member has positive wallet balance in "<currency>"
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

    When I call AMO007 "Settle Wager - Full settlement - Win" API with:
      | field                  | value                     |
      | transaction_no         | <transaction_no_2>        |
      | game_key               | <game_key_seamless>       |
      | wager_no               | <origin_wager_no>         |
      | platform_username      | <platform_username>       |
      | type                   | <wager_type.normal_wager> |
      | currency               | <currency>                |
      | amount                 | 150                       |
      | effective_amount       | 100                       |
      | settlement_time        | <settlement_time>         |
      | metadata               | <metadata>                |
      | metadata_type          | <metadata_type>           |
      | is_system_reward       | <is_system_reward>        |
      | is_partial_settlement  | false                     |
    Then the response should be successful

  @success @business
  Scenario: Resettle from win to lose to win
    Given I record the current wallet balance in "<currency>"
    When I call AMO009 "Resettle Wager - Lose" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <resettle_wager_no_1>     |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | -150                      |
      | effective_amount  | 0                         |
      | type              | <wager_type.normal_wager> |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | settlement_time   | <settlement_time>         |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should decrease by 150

    Given I record the current wallet balance in "<currency>"
    When I call AMO009 "Resettle Wager - Win" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_4>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <resettle_wager_no_2>     |
      | ticket_no         | <ticket_no_3>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | 150                       |
      | effective_amount  | 0                         |
      | type              | <wager_type.normal_wager> |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | settlement_time   | <settlement_time>         |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 150

  @business
  Scenario: Allow zero amount without balance change
    Given I record the current wallet balance in "<currency>"
    When I call AMO009 "Resettle Wager - Zero amount" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <resettle_wager_no_1>     |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | 0                         |
      | effective_amount  | 0                         |
      | type              | <wager_type.normal_wager> |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | settlement_time   | <settlement_time>         |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should remain unchanged

  @edge
  Scenario: Support up to 6 decimal places
    Given I record the current wallet balance in "<currency>"
    When I call AMO009 "Resettle Wager - 6 decimal places" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <resettle_wager_no_1>     |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | -149.999999               |
      | effective_amount  | 0                         |
      | type              | <wager_type.normal_wager> |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | settlement_time   | <settlement_time>         |
      | is_system_reward  | <is_system_reward>        |
    Then the response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should decrease by 149.999999

  @idempotency
  Scenario: Handle idempotent resettlement
    Given I record the current wallet balance in "<currency>"
    When I prepare a request payload with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <resettle_wager_no_1>     |
      | ticket_no         | <ticket_no_2>             |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | -150                      |
      | effective_amount  | 0                         |
      | type              | <wager_type.normal_wager> |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | settlement_time   | <settlement_time>         |
      | is_system_reward  | <is_system_reward>        |
    And I call AMO009 "Resettle Wager - First request" API
    Then the response should be successful
    And I store the full response as "first_response"
    And the wallet balance in "<currency>" should decrease by 150

    Given I record the current wallet balance in "<currency>"
    When I call AMO009 "Resettle Wager - Duplicate transaction_no" API
    Then the response should be the same as stored response "first_response"
    And the wallet balance in "<currency>" should remain unchanged
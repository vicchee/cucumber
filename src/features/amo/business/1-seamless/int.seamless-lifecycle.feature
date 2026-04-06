@seamless @integration 
Feature: Integration: Seamless Wager Lifecycle
  As APISYS
  I want seamless wager lifecycle APIs to apply the correct wallet adjustments
  So that request payment, settlement, resettlement, and undo produce the expected final balance

  Background:
    Given a merchant member exists
    And the member has positive wallet balance in "<currency>"

  Scenario: Request payment then settle wager as win
    Given I record the current wallet balance in "<currency>"
    When I call AMO003 "Request Payment" API with:
      | field             | value               |
      | transaction_no    | <transaction_no_1>  |
      | game_key          | <game_key_seamless> |
      | parent_wager_no   | <parent_wager_no>   |
      | platform_username | <platform_username> |
      | currency          | <currency>          |
      | amount            | -100                |
      | orders            | [{ "wager_no": <wager_no_1>, "ticket_no": <ticket_no>, "type": <wager_type.normal_wager>, "amount": 100, "payment_amount": 100, "effective_amount": 100, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": false }] |
    Then the response should be successful
    And the response should contain:
      | field             | value               |
      | reference_id      | any non-empty value |
      | status            | 1                   |
    And the wallet balance in "<currency>" should decrease by 100

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <wager_no_1>              |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 150                       |
      | effective_amount      | 100                       |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | false                     |
      | is_partial_settlement | false                     |
    Then the response should be successful
    And the response should contain:
      | field                 | value                     |
      | reference_id          | any non-empty value       |
    And the wallet balance in "<currency>" should increase by 150

  Scenario: Resettle a settled winning wager to lose
    Given I record the current wallet balance in "<currency>"
    When I call AMO003 "Request Payment" API with:
      | field             | value               |
      | transaction_no    | <transaction_no_1>  |
      | game_key          | <game_key_seamless> |
      | parent_wager_no   | <parent_wager_no>   |
      | platform_username | <platform_username> |
      | currency          | <currency>          |
      | amount            | -100                |
      | orders            | [{ "wager_no": <wager_no_1>, "ticket_no": <ticket_no>, "type": <wager_type.normal_wager>, "amount": 100, "payment_amount": 100, "effective_amount": 100, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": false }] |
    Then the response should be successful
    And the wallet balance in "<currency>" should decrease by 100

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <wager_no_1>              |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 150                       |
      | effective_amount      | 100                       |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | false                     |
      | is_partial_settlement | false                     |
    Then the response should be successful
    And the wallet balance in "<currency>" should increase by 150

    Given I record the current wallet balance in "<currency>"
    When I call AMO009 "Resettle Wager" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <wager_no_2>              |
      | ticket_no         | <ticket_no>               |
      | origin_wager_no   | <wager_no_1>              |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | -150                      |
      | effective_amount  | 100                       |
      | type              | <wager_type.normal_wager> |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | settlement_time   | <settlement_time>         |
      | is_system_reward  | false                     |
    Then the response should be successful
    And the response should contain:
      | field             | value                     |
      | reference_id      | any non-empty value       |
    And the wallet balance in "<currency>" should decrease by 150

  Scenario: Resettle a settled losing wager to win
    Given I record the current wallet balance in "<currency>"
    When I call AMO003 "Request Payment" API with:
      | field             | value               |
      | transaction_no    | <transaction_no_1>  |
      | game_key          | <game_key_seamless> |
      | parent_wager_no   | <parent_wager_no>   |
      | platform_username | <platform_username> |
      | currency          | <currency>          |
      | amount            | -100                |
      | orders            | [{ "wager_no": <wager_no_1>, "ticket_no": <ticket_no>, "type": <wager_type.normal_wager>, "amount": 100, "payment_amount": 100, "effective_amount": 100, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": false }] |
    Then the response should be successful
    And the wallet balance in "<currency>" should decrease by 100

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <wager_no_1>              |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 0                         |
      | effective_amount      | 100                       |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | false                     |
      | is_partial_settlement | false                     |
    Then the response should be successful
    And the wallet balance in "<currency>" should remain unchanged

    Given I record the current wallet balance in "<currency>"
    When I call AMO009 "Resettle Wager" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_3>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <wager_no_2>              |
      | ticket_no         | <ticket_no>               |
      | origin_wager_no   | <wager_no_1>              |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | 150                       |
      | effective_amount  | 100                       |
      | type              | <wager_type.normal_wager> |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | settlement_time   | <settlement_time>         |
      | is_system_reward  | false                     |
    Then the response should be successful
    And the response should contain:
      | field             | value                     |
      | reference_id      | any non-empty value       |
    And the wallet balance in "<currency>" should increase by 150

  Scenario: Undo a previously settled winning wager
    Given I record the current wallet balance in "<currency>"
    When I call AMO003 "Request Payment" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_1>        |
      | game_key          | <game_key_seamless>       |
      | parent_wager_no   | <parent_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | -100                      |
      | orders            | [{ "wager_no": <wager_no_1>, "ticket_no": <ticket_no>, "type": <wager_type.normal_wager>, "amount": 100, "payment_amount": 100, "effective_amount": 100, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": false }] |
    Then the response should be successful
    And the wallet balance in "<currency>" should decrease by 100

    Given I record the current wallet balance in "<currency>"
    When I call AMO007 "Settle Wager" API with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <wager_no_1>              |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 150                       |
      | effective_amount      | 100                       |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | false                     |
      | is_partial_settlement | false                     |
    Then the response should be successful
    And the wallet balance in "<currency>" should increase by 150

    Given I record the current wallet balance in "<currency>"
    When I call AMO012 "Undo Wager" API with:
      | field             | value                     |
      | transaction_no    | <transaction_no_4>        |
      | game_key          | <game_key_seamless>       |
      | wager_no          | <wager_no_2>              |
      | ticket_no         | <ticket_no>               |
      | origin_wager_no   | <wager_no_1>              |
      | platform_username | <platform_username>       |
      | type              | <wager_type.normal_wager> |
      | currency          | <currency>                |
      | amount            | -150                      |
      | effective_amount  | 100                       |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | is_system_reward  | false                     |
    Then the response should be successful
    And the response should contain:
      | field             | value                     |
      | reference_id      | any non-empty value       |
    And the wallet balance in "<currency>" should decrease by 150
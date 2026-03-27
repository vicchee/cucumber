Feature: AMO007 Seamless Settle Wager
  As APISYS
  I want to call the merchant settle wager API
  So that I can apply wager settlement results to the member wallet

  Background:
    Given a merchant member exists

  Scenario: Full settlement increases wallet balance
    Given I record the current wallet balance in "<currency>"
    When APISYS settles a wager with:
      | field                 | value                     |
      | transaction_no        | <transaction_no>          |
      | game_key              | <game_key>                |
      | wager_no              | <wager_no>                |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 25.75                     |
      | effective_amount      | 25.75                     |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | <is_system_reward>        |
      | is_partial_settlement | false                     |
    Then the AMO007 response should be successful
    And the response should contain:
      | field                 | value                     |
      | reference_id          | any non-empty value       |
    And the wallet balance in "<currency>" should increase by 25.75

  Scenario: Final settlement increases wallet balance with partial settlement history
    Given I record the current wallet balance in "<currency>"
    When APISYS settles a wager with:
      | field                      | value                     |
      | transaction_no             | <transaction_no>          |
      | game_key                   | <game_key>                |
      | wager_no                   | <wager_no>                |
      | platform_username          | <platform_username>       |
      | type                       | <wager_type.normal_wager> |
      | currency                   | <currency>                |
      | amount                     | 10                        |
      | effective_amount           | 10                        |
      | settlement_time            | <settlement_time>         |
      | metadata                   | <metadata>                |
      | metadata_type              | <metadata_type>           |
      | is_system_reward           | <is_system_reward>        |
      | is_partial_settlement      | false                     |
      | partial_settlement_history | [{ "transaction_no": <partial_transaction_no_1>, "amount": 2.5, "settlement_time": <settlement_time> }, { "transaction_no": <partial_transaction_no_2>, "amount": 1, "settlement_time": <settlement_time> }] |
    Then the AMO007 response should be successful
    And the response should contain:
      | field                      | value                     |
      | reference_id               | any non-empty value       |
    And the wallet balance in "<currency>" should increase by 13.5

  Scenario: Partial settlement does not change wallet balance
    Given I record the current wallet balance in "<currency>"
    When APISYS settles a wager with:
      | field                 | value                     |
      | transaction_no        | <transaction_no>          |
      | game_key              | <game_key>                |
      | wager_no              | <wager_no>                |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 99                        |
      | effective_amount      | 99                        |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | <is_system_reward>        |
      | is_partial_settlement | true                      |
    Then the AMO007 response should be successful
    And the response should contain:
      | field                 | value                     |
      | reference_id          | <transaction_no>          |
    And the wallet balance in "<currency>" should remain unchanged

  Scenario: Final settlement applies prior partial settlement for the same wager
    Given I record the current wallet balance in "<currency>"

    When APISYS settles a wager with:
      | field                 | value                      |
      | transaction_no        | <partial_transaction_no_1> |
      | game_key              | <game_key>                 |
      | wager_no              | <wager_no>                 |
      | platform_username     | <platform_username>        |
      | type                  | <wager_type.normal_wager>  |
      | currency              | <currency>                 |
      | amount                | 5                          |
      | effective_amount      | 5                          |
      | settlement_time       | <settlement_time>          |
      | metadata              | <metadata>                 |
      | metadata_type         | <metadata_type>            |
      | is_system_reward      | <is_system_reward>         |
      | is_partial_settlement | true                       |
    Then the AMO007 response should be successful
    And the response should contain:
      | field                 | value                      |
      | reference_id          | <partial_transaction_no_1> |
    And the wallet balance in "<currency>" should remain unchanged

    Given I record the current wallet balance in "<currency>"
    When APISYS settles a wager with:
      | field                      | value                     |
      | transaction_no             | <transaction_no>          |
      | game_key                   | <game_key>                |
      | wager_no                   | <wager_no>                |
      | platform_username          | <platform_username>       |
      | type                       | <wager_type.normal_wager> |
      | currency                   | <currency>                |
      | amount                     | 10                        |
      | effective_amount           | 10                        |
      | settlement_time            | <settlement_time>         |
      | metadata                   | <metadata>                |
      | metadata_type              | <metadata_type>           |
      | is_system_reward           | <is_system_reward>        |
      | is_partial_settlement      | false                     |
      | partial_settlement_history | [{ "transaction_no": <partial_transaction_no_1>, "amount": 5, "settlement_time": <settlement_time> }] |
    Then the AMO007 response should be successful
    And the response should contain:
      | field                      | value                     |
      | reference_id               | any non-empty value       |
    And the wallet balance in "<currency>" should increase by 15

  Scenario: Reject settlement when amount precision exceeds 6 decimal places
    When APISYS settles a wager with:
      | field                 | value                     |
      | transaction_no        | <transaction_no>          |
      | game_key              | <game_key>                |
      | wager_no              | <wager_no>                |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 1.1234567                 |
      | effective_amount      | 1.1234567                 |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | <is_system_reward>        |
      | is_partial_settlement | false                     |
    Then the AMO007 response should fail validation
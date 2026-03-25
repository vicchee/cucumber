Feature: Integration Flow - Seamless wager lifecycle
  As APISYS
  I want to call seamless wager APIs in sequence
  So that I can verify wallet balance changes across payment, settlement, resettlement, and undo end to end

  Background:
    Given a merchant member exists

  Scenario: Request payment, settle, resettle, and undo wager

    # request payment
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When APISYS requests payment with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_1>        |
      | game_key              | <game_key_seamless>       |
      | parent_wager_no       | <parent_wager_no>         |
      | platform_username     | <platform_username>       |
      | currency              | <currency>                |
      | amount                | -10                       |
      | orders                | [{ "wager_no": "<wager_no>", "ticket_no": "<ticket_no>", "type": <wager_type.normal_wager>, "amount": 10, "payment_amount": 10, "effective_amount": 10, "metadata": <metadata>, "metadata_type": <metadata_type>, "wager_time": <wager_time>, "is_system_reward": false }]                        |
    Then the AMO003 response should be successful
    And the response should contain:
      | field                 | value                     |
      | reference_id          | any non-empty value       |
      | status                | 1                         |
    And the wallet balance in "<currency>" should decrease by 10

    # settle wager
    Given I record the current wallet balance in "<currency>"
    When APISYS settles a wager with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_2>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <wager_no>                |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 25                        |
      | effective_amount      | 25                        |
      | settlement_time       | <settlement_time>         |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | is_system_reward      | false                     |
      | is_partial_settlement | false                     |
    Then the AMO007 response should be successful
    And the response should contain:
      | field                 | value                     |
      | reference_id          | any non-empty value       |
    And the wallet balance in "<currency>" should increase by 25

    # resettle wager downward
    Given I record the current wallet balance in "<currency>"
    When APISYS resettles a wager with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_3>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <wager_no>                |
      | ticket_no             | <ticket_no>               |
      | origin_wager_no       | <origin_wager_no>         |
      | platform_username     | <platform_username>       |
      | currency              | <currency>                |
      | amount                | -5                        |
      | effective_amount      | 10                        |
      | type                  | <wager_type.normal_wager> |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | wager_time            | <wager_time>              |
      | settlement_time       | <settlement_time>         |
      | is_system_reward      | false                     |
    Then the AMO009 response should be successful
    And the response should contain:
      | field                 | value                     |
      | reference_id          | any non-empty value       |
    And the wallet balance in "<currency>" should decrease by 5

    # undo wager
    Given I record the current wallet balance in "<currency>"
    When APISYS undoes a wager with:
      | field                 | value                     |
      | transaction_no        | <transaction_no_4>        |
      | game_key              | <game_key_seamless>       |
      | wager_no              | <wager_no>                |
      | ticket_no             | <ticket_no>               |
      | origin_wager_no       | <origin_wager_no>         |
      | platform_username     | <platform_username>       |
      | type                  | <wager_type.normal_wager> |
      | currency              | <currency>                |
      | amount                | 10                        |
      | effective_amount      | 10                        |
      | metadata              | <metadata>                |
      | metadata_type         | <metadata_type>           |
      | wager_time            | <wager_time>              |
      | is_system_reward      | false                     |
    Then the AMO012 response should be successful
    And the response should contain:
      | field                 | value                     |
      | reference_id          | any non-empty value       |
    And the wallet balance in "<currency>" should increase by 10
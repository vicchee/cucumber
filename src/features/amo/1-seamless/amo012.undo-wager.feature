Feature: AMO012 Seamless Undo Wager
  As APISYS
  I want to call the merchant undo wager API
  So that the merchant can reverse the wallet effect of a previous wager

  Background:
    Given a merchant member exists

  Scenario: Undo wager increases wallet balance
    Given I record the current wallet balance in "<currency>"
    When APISYS undoes a wager with:
      | field             | value                     |
      | transaction_no    | <transaction_no>          |
      | game_key          | <game_key>                |
      | wager_no          | <wager_no>                |
      | ticket_no         | <ticket_no>               |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | type              | <wager_type.normal_wager> |
      | currency          | <currency>                |
      | amount            | 15                        |
      | effective_amount  | 15                        |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | is_system_reward  | <is_system_reward>        |
    Then the AMO012 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 15

  Scenario: Undo wager with zero amount does not change wallet balance
    Given I record the current wallet balance in "<currency>"
    When APISYS undoes a wager with:
      | field             | value                     |
      | transaction_no    | <transaction_no>          |
      | game_key          | <game_key>                |
      | wager_no          | <wager_no>                |
      | ticket_no         | <ticket_no>               |
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
    Then the AMO012 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should remain unchanged
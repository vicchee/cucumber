Feature: AMO009 Seamless Resettle Wager
  As APISYS
  I want to call the merchant resettle wager API
  So that I can apply corrected settlement amounts

  Background:
    Given a merchant member exists

  Scenario: Resettlement increases the wallet balance
    Given I record the current wallet balance in "<currency>"
    When APISYS resettles a wager with:
      | field             | value                     |
      | transaction_no    | <transaction_no>          |
      | game_key          | <game_key>                |
      | wager_no          | <wager_no>                |
      | ticket_no         | <ticket_no>               |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | 12.5                      |
      | effective_amount  | <effective_amount>        |
      | type              | <wager_type.normal_wager> |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | settlement_time   | <settlement_time>         |
      | is_system_reward  | <is_system_reward>        |
    Then the AMO009 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should increase by 12.5

  Scenario: Resettlement decreases the wallet balance
    Given I record the current wallet balance in "<currency>"
    When APISYS resettles a wager with:
      | field             | value                     |
      | transaction_no    | <transaction_no>          |
      | game_key          | <game_key>                |
      | wager_no          | <wager_no>                |
      | ticket_no         | <ticket_no>               |
      | origin_wager_no   | <origin_wager_no>         |
      | platform_username | <platform_username>       |
      | currency          | <currency>                |
      | amount            | -4.25                     |
      | effective_amount  | <effective_amount>        |
      | type              | <wager_type.normal_wager> |
      | metadata          | <metadata>                |
      | metadata_type     | <metadata_type>           |
      | wager_time        | <wager_time>              |
      | settlement_time   | <settlement_time>         |
      | is_system_reward  | <is_system_reward>        |
    Then the AMO009 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And the wallet balance in "<currency>" should decrease by 4.25
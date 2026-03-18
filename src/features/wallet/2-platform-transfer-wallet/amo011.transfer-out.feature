Feature: AMO011 Request Transfer Out
  As APISYS
  I want to call the merchant transfer out API
  So that I can debit funds from the member wallet

  Background:
    Given a merchant member exists

  Scenario: Transfer out decreases wallet balance
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When APISYS requests transfer out with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | -20.5                |
      | session_id        | <session_id>         |
    Then the AMO011 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | amount       | -20.5               |
      | status       | 1                   |
    And the wallet balance in "<currency>" should decrease by 20.5

  Scenario: Repeating the same transfer_no is idempotent
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    When APISYS requests transfer out with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | -15                  |
      | session_id        | <session_id>         |
    Then the AMO011 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | amount       | -15                 |
      | status       | 1                   |
    And I store the response field "reference_id" as "amo011_reference_id"
    And the wallet balance in "<currency>" should decrease by 15

    Given I record the current wallet balance in "<currency>"
    When APISYS requests transfer out with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | -15                  |
      | session_id        | <session_id>         |
    Then the AMO011 response should be successful
    And the response should contain:
      | field        | value                 |
      | reference_id | <amo011_reference_id> |
      | amount       | -15                   |
      | status       | 1                     |
    And the wallet balance in "<currency>" should remain unchanged

  Scenario: Insufficient balance returns failed status
    Given I record the current wallet balance in "<currency>"
    And I prepare an amount exceeding the balance by 10
    When APISYS requests transfer out with:
      | field             | value                          |
      | transfer_no       | <transfer_no>                  |
      | game_type         | <game_type>                    |
      | platform_username | <platform_username>            |
      | currency          | <currency>                     |
      | amount            | <amount_exceeding_balance>     |
      | session_id        | <session_id>                   |
    Then the AMO011 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | status       | 2                   |
    And the wallet balance in "<currency>" should remain unchanged

Scenario: Not providing amount transfers out all integer wallet balance
  Given the member has positive wallet balance in "<currency>"
  And I record the current wallet balance in "<currency>"
  When APISYS requests transfer out with:
    | field             | value                |
    | transfer_no       | <transfer_no>        |
    | game_type         | <game_type>          |
    | platform_username | <platform_username>  |
    | currency          | <currency>           |
    | session_id        | <session_id>         |
  Then the AMO011 response should be successful
  And the response should contain:
    | field        | value               |
    | reference_id | any non-empty value |
    | status       | 1                   |
  And the response amount should equal the integer part of the recorded wallet balance in "<currency>"
  And the wallet balance in "<currency>" should equal the remaining decimal balance

  Scenario: Validation fails when amount precision is invalid
    When APISYS requests transfer out with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | -1.1234567           |
      | session_id        | <session_id>         |
    Then the AMO011 response should fail validation

  Scenario: Validation fails when amount is positive
    When APISYS requests transfer out with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | 1                    |
      | session_id        | <session_id>         |
    Then the AMO011 response should fail validation

  Scenario: Validation fails when transfer_no is missing
    When APISYS requests transfer out with:
      | field             | value                |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | -10                  |
      | session_id        | <session_id>         |
    Then the AMO011 response should fail validation

  Scenario: Validation fails when game_type is missing
    When APISYS requests transfer out with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | -10                  |
      | session_id        | <session_id>         |
    Then the AMO011 response should fail validation

  Scenario: Validation fails when platform_username is missing
    When APISYS requests transfer out with:
      | field       | value           |
      | transfer_no | <transfer_no>   |
      | game_type   | <game_type>     |
      | currency    | <currency>      |
      | amount      | -10             |
      | session_id  | <session_id>    |
    Then the AMO011 response should fail validation

  Scenario: Validation fails when currency is missing
    When APISYS requests transfer out with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | amount            | -10                  |
      | session_id        | <session_id>         |
    Then the AMO011 response should fail validation

  Scenario: Validation fails when session_id is missing
    When APISYS requests transfer out with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | -10                  |
    Then the AMO011 response should fail validation
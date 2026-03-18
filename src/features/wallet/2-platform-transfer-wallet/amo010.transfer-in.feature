Feature: AMO010 Request Transfer In
  As APISYS
  I want to call the merchant transfer in API
  So that I can credit funds into the member wallet

  Background:
    Given a merchant member exists

  Scenario: Transfer in increases wallet balance
    Given I record the current wallet balance in "<currency>"
    When APISYS requests transfer in with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | 75.125               |
      | session_id        | <session_id>         |
    Then the AMO010 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | status       | 1                   |
    And the wallet balance in "<currency>" should increase by 75.125

  Scenario: Repeating the same transfer_no is idempotent
    Given I record the current wallet balance in "<currency>"
    When APISYS requests transfer in with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | 50                   |
      | session_id        | <session_id>         |
    Then the AMO010 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | status       | 1                   |
    And I store the response field "reference_id" as "amo010_reference_id"
    And the wallet balance in "<currency>" should increase by 50

    Given I record the current wallet balance in "<currency>"
    When APISYS requests transfer in with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | 50                   |
      | session_id        | <session_id>         |
    Then the AMO010 response should be successful
    And the response should contain:
      | field        | value                 |
      | reference_id | <amo010_reference_id> |
      | status       | 1                     |
    And the wallet balance in "<currency>" should remain unchanged

  Scenario: Zero amount transfer does not change balance
    Given I record the current wallet balance in "<currency>"
    When APISYS requests transfer in with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | 0                    |
      | session_id        | <session_id>         |
    Then the AMO010 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | status       | 1                   |
    And the wallet balance in "<currency>" should remain unchanged

  Scenario: Validation fails when amount precision is invalid
    When APISYS requests transfer in with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | 1.1234567            |
      | session_id        | <session_id>         |
    Then the AMO010 response should fail validation

  Scenario: Validation fails when amount is negative
    When APISYS requests transfer in with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | -1                   |
      | session_id        | <session_id>         |
    Then the AMO010 response should fail validation

  Scenario: Validation fails when transfer_no is missing
    When APISYS requests transfer in with:
      | field             | value                |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | 10                   |
      | session_id        | <session_id>         |
    Then the AMO010 response should fail validation

  Scenario: Validation fails when platform_username is missing
    When APISYS requests transfer in with:
      | field       | value           |
      | transfer_no | <transfer_no>   |
      | game_type   | <game_type>     |
      | currency    | <currency>      |
      | amount      | 10              |
      | session_id  | <session_id>    |
    Then the AMO010 response should fail validation

  Scenario: Validation fails when currency is missing
    When APISYS requests transfer in with:
      | field             | value                |
      | transfer_no       | <transfer_no>        |
      | game_type         | <game_type>          |
      | platform_username | <platform_username>  |
      | amount            | 10                   |
      | session_id        | <session_id>         |
    Then the AMO010 response should fail validation

  Scenario: Validation fails when game_type is missing
    When APISYS requests transfer in with:
      | field             | value               |
      | transfer_no       | <transfer_no>       |
      | platform_username | <platform_username> |
      | currency          | <currency>          |
      | amount            | 10                  |
      | session_id        | <session_id>        |
    Then the AMO010 response should fail validation

  Scenario: Validation fails when session_id is missing
    When APISYS requests transfer in with:
      | field             | value               |
      | transfer_no       | <transfer_no>       |
      | game_type         | <game_type>         |
      | platform_username | <platform_username> |
      | currency          | <currency>          |
      | amount            | 10                  |
    Then the AMO010 response should fail validation
Feature: AMO014 Request Cancel Transfer
  As APISYS
  I want to call the merchant cancel transfer API
  So that I can reverse a previous transfer ledger

  Background:
    Given a merchant member exists

  Scenario: Cancel transfer returns reference_id for an existing transfer in and is idempotent
    Given a successful transfer in exists for:
      | field             | value                 |
      | transfer_no       | <transfer_no>         |
      | game_type         | <game_type>           |
      | platform_username | <platform_username>   |
      | currency          | <currency>            |
      | amount            | 20                    |
      | session_id        | <session_id>          |
    When APISYS requests cancel transfer with:
      | field       | value           |
      | transfer_no | <transfer_no>   |
    Then the AMO014 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And I store the response field "reference_id" as "cancel_reference_id"

    When APISYS requests cancel transfer with:
      | field       | value           |
      | transfer_no | <transfer_no>   |
    Then the AMO014 response should be successful
    And the response should contain:
      | field        | value                  |
      | reference_id | <cancel_reference_id>  |

  Scenario: Cancel transfer returns reference_id for an existing transfer out and is idempotent
    Given the member has positive wallet balance in "<currency>"
    And a successful transfer out exists for:
      | field             | value                 |
      | transfer_no       | <transfer_no>         |
      | game_type         | <game_type>           |
      | platform_username | <platform_username>   |
      | currency          | <currency>            |
      | amount            | -20                   |
      | session_id        | <session_id>          |
    When APISYS requests cancel transfer with:
      | field       | value           |
      | transfer_no | <transfer_no>   |
    Then the AMO014 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And I store the response field "reference_id" as "cancel_reference_id"

    When APISYS requests cancel transfer with:
      | field       | value           |
      | transfer_no | <transfer_no>   |
    Then the AMO014 response should be successful
    And the response should contain:
      | field        | value                  |
      | reference_id | <cancel_reference_id>  |

  Scenario: Cancel transfer returns reference_id when transfer does not exist and is idempotent
    When APISYS requests cancel transfer with:
      | field       | value           |
      | transfer_no | <transfer_no>   |
    Then the AMO014 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And I store the response field "reference_id" as "cancel_reference_id"

    When APISYS requests cancel transfer with:
      | field       | value           |
      | transfer_no | <transfer_no>   |
    Then the AMO014 response should be successful
    And the response should contain:
      | field        | value                  |
      | reference_id | <cancel_reference_id>  |
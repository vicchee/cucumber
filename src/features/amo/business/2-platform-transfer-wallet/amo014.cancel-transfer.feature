Feature: AMO014 Request Cancel Transfer
  As APISYS
  I want to call the merchant cancel transfer API
  So that I can reverse a previous transfer ledger

  Background:
    Given a merchant member exists

  Scenario: Cancel transfer returns reference_id for an existing transfer in and is idempotent
    # request transfer in
    When I call AMO010 API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | 20                          |
      | session_id        | <session_id>                |
    Then the response should be successful
    
    # cancel transfer
    When I call AMO011 API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
    Then the response should be successful
    And the response should contain:
      | field             | value                       |
      | reference_id      | any non-empty value         |
    And I store the response field "reference_id" as "amo014_reference_id"

    # cancel transfer again to verify idempotency
    When I call AMO014 API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
    Then the response should be successful
    And the response should contain:
      | field             | value                       |
      | reference_id      | <amo014_reference_id>       |

  Scenario: Cancel transfer returns reference_id for an existing transfer out and is idempotent
    Given the member has positive wallet balance in "<currency>"
    
    # request transfer out
    When I call AMO011 API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | -20                         |
      | session_id        | <session_id>                |
    Then the response should be successful

    # cancel transfer
    When I call AMO014 API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
    Then the response should be successful
    And the response should contain:
      | field             | value                       |
      | reference_id      | any non-empty value         |
    And I store the response field "reference_id" as "amo014_reference_id"

    # cancel transfer again to verify idempotency
    When I call AMO014 API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
    Then the response should be successful
    And the response should contain:
      | field             | value                       |
      | reference_id      | <amo014_reference_id>       |

  Scenario: Cancel transfer returns reference_id when transfer does not exist and is idempotent
    When I call AMO014 API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
    Then the response should be successful
    And the response should contain:
      | field             | value                       |
      | reference_id      | any non-empty value         |
    And I store the response field "reference_id" as "amo014_reference_id"

    # cancel transfer again to verify idempotency
    When I call AMO014 API with:
      | field             | value                       |
      | transfer_no       | <transfer_no>               |
    Then the response should be successful
    And the response should contain:
      | field             | value                       |
      | reference_id      | <amo014_reference_id>       |
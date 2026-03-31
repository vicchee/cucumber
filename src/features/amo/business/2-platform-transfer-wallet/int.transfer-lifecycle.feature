Feature: Integration: Transfer Wallet Lifecycle
  As APISYS
  I want to call transfer APIs in sequence
  So that I can verify wallet balance changes and transfer reversal end to end

  Background:
    Given a merchant member exists

  Scenario: Transfer in, transfer out, cancel transfer, and idempotent cancel

    # transfer in
    Given I record the current wallet balance in "<currency>"
    When I call AMO010 "Request Transfer In" API with:
      | field             | value                       |
      | transfer_no       | <transfer_no_1>             |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | 100000.123456               |
    Then the response should be successful
    And the wallet balance in "<currency>" should increase by 100000.123456 

    # transfer out
    Given I record the current wallet balance in "<currency>"
    When I call AMO011 "Request Transfer Out" API with:
      | field             | value                       |
      | transfer_no       | <transfer_no_2>             |
      | game_type         | <game_type_transfer_wallet> |
      | platform_username | <platform_username>         |
      | currency          | <currency>                  |
      | amount            | -35                         |
      | session_id        | <session_id>                |
    Then the response should be successful
    And the wallet balance in "<currency>" should decrease by 35

    # cancel transfer
    Given I record the current wallet balance in "<currency>"
    When I call AMO014 "Cancel Transfer" API with:
      | field             | value                       |
      | transfer_no       | <transfer_no_2>             |
    Then the response should be successful
    And the response should contain:
      | field             | value                       |
      | reference_id      | any non-empty value         |
    And I store the response field "reference_id" as "amo014_reference_id"
    And the wallet balance in "<currency>" should increase by 35

    # idempotent cancel
    Given I record the current wallet balance in "<currency>"
    When I call AMO014 "Duplicate Cancel Transfer" API with:
      | field             | value                       |
      | transfer_no       | <transfer_no_2>             |
    Then the response should be successful
    And the response should contain:
      | field             | value                       |
      | reference_id      | <amo014_reference_id>       |
    And the wallet balance in "<currency>" should remain unchanged
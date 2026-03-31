Feature: AMO001 Get Member Wallet Balance
  As APISYS
  I want to call the merchant wallet balance API
  So that I can retrieve the member wallet balance for one or more currencies

  Background:
    Given a merchant member exists

  Scenario: Get balances for requested currencies
    When I call AMO001 API with:
      | field             | value               |
      | platform_username | <platform_username> |
      | currencies        | [<currency>]        |
    Then the response should be successful
    And the response should contain balances for:
      | field             | value               |
      | platform_username | <platform_username> |
      | currencies        | [<currency>]        |

  Scenario: Get balances for all supported currencies
    When I call AMO001 API with:
      | field             | value               |
      | platform_username | <platform_username> |
      | currencies        | <currencies>        |
    Then the response should be successful
    And the response should contain balances for:
      | field             | value               |
      | platform_username | <platform_username> |
      | currencies        | <currencies>        |
      
  Scenario: Validation fails when platform username is invalid
    When I call AMO001 API with:
      | field             | value                   |
      | platform_username | invalid_username        |
      | currencies        | ["CNY","THB"]           |
    Then the response should fail validation

  Scenario: Validation fails when currencies array is empty
    When I call AMO001 API with:
      | field             | value                   |
      | platform_username | <platform_username>     |
      | currencies        | []                      |
    Then the response should fail validation
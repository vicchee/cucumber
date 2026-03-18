Feature: AMO001 Get Member Wallet Balance
  As APISYS
  I want to call the merchant wallet balance API
  So that I can retrieve the member wallet balance for one or more currencies

  Background:
    Given a merchant member exists

  Scenario: Get balances for requested currencies
    When APISYS requests member wallet balances with:
      | field             | value                   |
      | platform_username | <platform_username>     |
      | currencies        | ["CNY","THB"]           |
    Then the AMO001 response should be successful
    And the response should contain balances for:
      | field             | value                   |
      | platform_username | <platform_username>     |
      | currencies        | ["CNY","THB"]           |
      
  Scenario: Validation fails when platform username is empty
    When APISYS requests member wallet balances with:
      | field             | value                   |
      | platform_username |                         |
      | currencies        | ["CNY","THB"]           |
    Then the AMO001 response should fail validation
      
  Scenario: Validation fails when platform username is invalid
    When APISYS requests member wallet balances with:
      | field             | value                   |
      | platform_username | invalid_username        |
      | currencies        | ["CNY","THB"]           |
    Then the AMO001 response should fail validation

  Scenario: Validation fails when currencies array is empty
    When APISYS requests member wallet balances with:
      | field             | value                   |
      | platform_username | <platform_username>     |
      | currencies        | []                      |
    Then the AMO001 response should fail validation

  Scenario: Validation fails when a currency in the array is invalid
    When APISYS requests member wallet balances with:
      | field             | value                   |
      | platform_username | <platform_username>     |
      | currencies        | ["USD","MYR","INVALID"] |
    Then the AMO001 response should fail validation
Feature: Validation: AMO001 Get Member Wallet Balance
  As APISYS
  I want to call the merchant wallet balance API
  So that I can retrieve the member wallet balance for one or more currencies

  Background:
    Given a merchant member exists

  Scenario: Validation fails when a currency in the array is invalid
    When APISYS requests member wallet balances with:
      | field             | value                   |
      | platform_username | <platform_username>     |
      | currencies        | ["USD","MYR","INVALID"] |
    Then the AMO001 response should fail validation

  Scenario Outline: Validation fails when required field "<required_field>" is missing
    When I prepare a request with:
      | field             | value               |
      | platform_username | <platform_username> |
      | currencies        | [<currency>]        |
    And I remove "<required_field>" from the request payload
    When APISYS requests member wallet balances
    Then the AMO001 response should fail validation

    Examples:
      | required_field    |
      | platform_username |
      | currencies        |
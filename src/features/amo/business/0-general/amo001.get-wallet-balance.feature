@general
Feature: AMO001 Get Member Wallet Balance
  As APISYS
  I want to call the merchant wallet balance API
  So that I can retrieve the member wallet balance for one or more currencies

  Background:
    Given a merchant member exists

  @success
  Scenario: Retrieve balances for requested currencies
    When I call AMO001 API with:
      | field             | value               |
      | platform_username | <platform_username> |
      | currencies        | [<currency>]        |
    Then the response should be successful
    And the response should contain:
      | field             | value               |
      | platform_username | <platform_username> |
    And the response should contain balances for "<currency>"

  @success
  Scenario: Retrieve balances for all supported currencies
    When I call AMO001 API with:
      | field             | value               |
      | platform_username | <platform_username> |
      | currencies        | <currencies>        |
    Then the response should be successful
    And the response should contain:
      | field             | value               |
      | platform_username | <platform_username> |
    And the response should contain balances for "<currencies>"
  
  @validation
  Scenario: Fail validation - invalid platform_username
    When I call AMO001 API with:
      | field             | value                   |
      | platform_username | invalid_username        |
      | currencies        | [<currency>]           |
    Then the response should fail validation

  @validation
  Scenario: Fail validation - empty currencies array
    When I call AMO001 API with:
      | field             | value                   |
      | platform_username | <platform_username>     |
      | currencies        | []                      |
    Then the response should fail validation

  @validation @optional
  Scenario: Fail validation - invalid currency in array
    When I call AMO001 API with:
      | field             | value                   |
      | platform_username | <platform_username>     |
      | currencies        | [<currency>,"INVALID"] |
    Then the response should fail validation

  @validation @optional
  Scenario Outline: Fail validation - missing required field "<required_field>"
    When I prepare a request payload with:
      | field             | value               |
      | platform_username | <platform_username> |
      | currencies        | [<currency>]        |
    And I remove "<required_field>" from the request payload
    And I call AMO001 API
    Then the response should fail validation

    Examples:
      | required_field    |
      | platform_username |
      | currencies        |
@general
Feature: AMO001 Get Member Wallet Balance
  As APISYS
  I want to call the merchant wallet balance API
  So that I can retrieve the member wallet balance for one or more currencies

  @success
  Scenario: Retrieve balances for requested currencies
    Process balance retrieval for requested currencies
    Validate only requested currencies are returned

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
    Process balance retrieval for all supported currencies
    Validate each requested supported currency is returned

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
  Scenario: Reject invalid platform_username
    Reject request with invalid platform_username
    Validate member lookup is required before returning balances

    When I call AMO001 API with:
      | field             | value               |
      | platform_username | invalid_username    |
      | currencies        | [<currency>]        |
    Then the response should fail validation

  @validation
  Scenario: Reject request with empty currencies array
    Reject request with empty currencies array
    Validate at least one currency is required

    When I call AMO001 API with:
      | field             | value               |
      | platform_username | <platform_username> |
      | currencies        | []                  |
    Then the response should fail validation

  @validation @optional
  Scenario: Reject request with invalid currency in array
    Reject request with invalid currency in array
    Validate request fails when any requested currency is unsupported

    When I call AMO001 API with:
      | field             | value                  |
      | platform_username | <platform_username>    |
      | currencies        | [<currency>,"INVALID"] |
    Then the response should fail validation

  @validation @optional
  Scenario Outline: Reject request with missing required field "<required_field>"
    Reject request with missing required field
    Validate request is rejected when required payload is incomplete

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
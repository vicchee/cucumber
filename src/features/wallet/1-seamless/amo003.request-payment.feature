Feature: AMO003 Seamless Request Payment
  As APISYS
  I want to call the merchant request payment API
  So that I can deduct wager payment from the member wallet

  Background:
    Given a merchant member exists
    
  Scenario: Successful request payment deducts wallet balance
    Given the member has positive wallet balance in "<currency>"
    And I record the current wallet balance in "<currency>"
    And I prepare a valid amount less than the balance by 10
    When APISYS requests payment with:
      | field             | value                       |
      | platform_username | <platform_username>         |
      | transaction_no    | <transaction_no>            |
      | currency          | <currency>                  |
      | amount            | -<deduction_amount>         |
    Then the AMO003 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
      | status       | 1                   |
    And the wallet balance in "<currency>" should decrease by "<deduction_amount>"

  Scenario: Insufficient balance returns failed status
    Given I record the current wallet balance in "<currency>"
    And I prepare an amount exceeding the balance by 10
    When APISYS requests payment with:
      | field             | value                          |
      | platform_username | <platform_username>            |
      | transaction_no    | <transaction_no>               |          
      | currency          | <currency>                     |
      | amount            | <amount_exceeding_balance>     |
    Then the AMO003 response should be successful
    And the response should contain:
      | field        | value                |
      | reference_id | <transaction_no>     |
      | status       | 2                    |
      | fail_reason  | 3                    |
    And the wallet balance in "<currency>" should remain unchanged

  Scenario: Zero amount request payment is allowed
    Given I record the current wallet balance in "<currency>"
    When APISYS requests payment with:
      | field             | value                |
      | platform_username | <platform_username>  |
      | transaction_no    | <transaction_no>     |
      | currency          | <currency>           |
      | amount            | 0                    |
    Then the AMO003 response should be successful
    And the response should contain:
      | field  | value |
      | status | 1     |
    And the wallet balance in "<currency>" should remain unchanged

  Scenario: Validation fails when amount is positive
    When APISYS requests payment with:
      | field             | value                |
      | platform_username | <platform_username>  |
      | transaction_no    | <transaction_no>     |
      | currency          | <currency>           |
      | amount            | 5                    |
    Then the AMO003 response should fail validation

  Scenario: Validation fails when amount has more than 6 decimal places
    When APISYS requests payment with:
      | field             | value                |
      | platform_username | <platform_username>  |
      | transaction_no    | <transaction_no>     |
      | currency          | <currency>           |
      | amount            | -1.1234567           |
    Then the AMO003 response should fail validation
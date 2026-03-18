Feature: Integration Flow - Request payment then cancel wager
  As APISYS
  I want to call the merchant wallet APIs in sequence
  So that I can verify paid wager cancellation refund flow end to end

  Background:
    Given a merchant member exists with platform username "<platform_username>"
    And the member wallet has balances:
      | currency   | balance |
      | <currency> | 100     |

  Scenario: Request payment 30 then cancel wager refunds the same 30
    Given a bet exists with:
      | wager_no        | <wager_no>        |
      | parent_wager_no | <parent_wager_no> |
    When APISYS requests payment with:
      | transaction_no    | <transaction_no>     |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | -30                  |
    Then the response should be successful
    And the wallet balance for "<platform_username>" in "<currency>" should become 70

    And a request payment transaction exists with:
      | wager_no | <parent_wager_no>    |
      | order_no | <transaction_uuid_1> |
      | currency | <currency>           |
      | amount   | -30                  |
    And the request payment transaction payload includes wager:
      | wager_no       | <wager_no> |
      | payment_amount | 30         |

    When APISYS cancels a wager with:
      | transaction_no    | <transaction_uuid_2> |
      | platform_username | <platform_username>  |
      | wager_no          | <wager_no>           |
    Then the response should be successful
    And the wallet balance for "<platform_username>" in "<currency>" should become 100
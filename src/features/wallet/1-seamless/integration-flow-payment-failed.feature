Feature: Integration Flow - Request payment then notify payment failed
  As APISYS
  I want to call the merchant wallet APIs in sequence
  So that I can verify failed payment refund flow end to end

  Background:
    Given a merchant member exists with platform username "<platform_username>"
    And the member wallet has balances:
      | currency   | balance |
      | <currency> | 90      |

  Scenario: Request payment 40 then notify payment failed restores balance to 90
    Given a request payment transaction mapping will be created for parent wager "<parent_wager_no>"
    When APISYS requests payment with:
      | transaction_no    | <transaction_no>     |
      | platform_username | <platform_username>  |
      | currency          | <currency>           |
      | amount            | -40                  |
    Then the response should be successful
    And the wallet balance for "<platform_username>" in "<currency>" should become 50

    When APISYS notifies payment failed with:
      | transaction_no    | <uuidv4_transaction_1> |
      | parent_wager_no   | <parent_wager_no>      |
      | platform_username | <platform_username>    |
    Then the response should be successful
    And the wallet balance for "<platform_username>" in "<currency>" should become 90
Feature: AMO014 Cancel transfer integration flow
  As APISYS
  I want to cancel an actual existing transfer
  So that repeated cancel calls behave consistently

  Background:
    Given a merchant member exists

  Scenario: Transfer in then cancel twice returns the same reference_id
    Given I record the current wallet balance in "<currency>"
    When APISYS requests transfer in with:
      | field             | value               |
      | platform_username | <platform_username> |
      | transfer_no       | <transfer_no>       |
      | currency          | <currency>          |
      | amount            | 30                  |
    Then the AMO010 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |

    When APISYS requests cancel transfer with:
      | field       | value           |
      | transfer_no | <transfer_no> |
    Then the AMO014 response should be successful
    And the response should contain:
      | field        | value               |
      | reference_id | any non-empty value |
    And I store the response field "reference_id" as "cancel_reference_id_1"

    When APISYS requests cancel transfer with:
      | field       | value           |
      | transfer_no | <transfer_no>     |
    Then the AMO014 response should be successful
    And the response should contain:
      | field        | value                    |
      | reference_id | <cancel_reference_id>    |

    And the wallet balance in "<currency>" should remain unchanged
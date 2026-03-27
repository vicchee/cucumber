Feature: AMO013 Notify Wager Update
  As APISYS
  I want to notify the merchant of wager updates
  So that the merchant can receive wager update events for supported wallet modes

  Background:
    Given a merchant member exists

  Scenario: Notify merchant with a single wager update
    When APISYS notifies wager update with payload:
      """
      {
        "notification_type": <notification_type>,
        "notifications": [
          {
            "game_type": <game_type_transfer_wallet>,
            "game_key": <game_key_transfer_wallet>,
            "wager_no": <wager_no>,
            "origin_wager_no": null,
            "ticket_no": <ticket_no>,
            "platform_username": <platform_username>,
            "type": <wager_type.normal_wager>,
            "status": <wager_status.settled>,
            "currency": <currency>,
            "amount": 10.1,
            "payment_amount": 10.1,
            "effective_amount": 10,
            "profit_and_loss": 5.1,
            "wager_time": <wager_time>,
            "settlement_time": <settlement_time>,
            "is_system_reward": <is_system_reward>
          }
        ]
      }
      """
    Then the AMO013 response should be successful

  Scenario: Notify merchant with multiple wager updates across wallet modes
    When APISYS notifies wager update with payload:
      """
      {
        "notification_type": <notification_type>,
        "notifications": [
          {
            "game_type": <game_type_transfer_wallet>,
            "game_key": <game_key_transfer_wallet>,
            "wager_no": <wager_no>,
            "origin_wager_no": <origin_wager_no>,
            "ticket_no": <ticket_no>,
            "platform_username": <platform_username>,
            "type": <wager_type.normal_wager>,
            "status": <wager_status.resettled>,
            "currency": <currency>,
            "amount": 10.1,
            "payment_amount": 10.1,
            "effective_amount": 10,
            "profit_and_loss": 5.1,
            "wager_time": <wager_time>,
            "settlement_time": <settlement_time>,
            "is_system_reward": <is_system_reward>
          },
          {
            "game_type": <game_type_seamless>,
            "game_key": <game_key_seamless>,
            "wager_no": <wager_no>,
            "origin_wager_no": null,
            "ticket_no": null,
            "platform_username": <platform_username>,
            "type": <wager_type.normal_wager>,
            "status": <wager_status.settled>,
            "currency": <currency>,
            "amount": 5.1,
            "payment_amount": 5.1,
            "effective_amount": 5,
            "profit_and_loss": 0,
            "wager_time": <wager_time>,
            "settlement_time": null,
            "is_system_reward": false
          }
        ]
      }
      """
    Then the AMO013 response should be successful

  Scenario: Notify merchant with nullable origin wager and settlement time
    When APISYS notifies wager update with payload:
      """
      {
        "notification_type": <notification_type>,
        "notifications": [
          {
            "game_type": <game_type_seamless>,
            "game_key": <game_key_seamless>,
            "wager_no": <wager_no>,
            "origin_wager_no": null,
            "ticket_no": null,
            "platform_username": <platform_username>,
            "type": <wager_type.normal_wager>,
            "status": <wager_status.pending>,
            "currency": <currency>,
            "amount": 5.1,
            "payment_amount": 5.1,
            "effective_amount": 5,
            "profit_and_loss": 0,
            "wager_time": <wager_time>,
            "settlement_time": null,
            "is_system_reward": false
          }
        ]
      }
      """
    Then the AMO013 response should be successful
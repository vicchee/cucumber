@seamless
Feature: AMO013 Notify Wager Update
  As APISYS
  I want to notify the merchant of wager updates
  So that I can provide corrected wager details after earlier wallet actions
  Support wager update notifications for seamless games
  Use this notification when wager details such as effective_amount become available later
  Wallet balance is not changed by this notification

  Background:
    Given a merchant member exists

  @success
  Scenario: Notify updated wager details after request payment
    Process wager update notification after request payment
    Validate merchant receives corrected wager details after the initial payment request

    When I call AMO013 API with:
      """
      {
        "notification_type": "WAGER_UPDATE",
        "notifications": [
          {
            "game_type": <game_type_seamless>,
            "game_key": <game_key_seamless>,
            "wager_no": <wager_no_1>,
            "origin_wager_no": null,
            "ticket_no": <ticket_no_1>,
            "platform_username": <platform_username>,
            "type": <wager_type.normal_wager>,
            "status": <wager_status.pending>,
            "currency": <currency>,
            "amount": 10.1,
            "payment_amount": 10.1,
            "effective_amount": 10,
            "profit_and_loss": 0,
            "wager_time": <wager_time>,
            "settlement_time": null,
            "is_system_reward": false
          }
        ]
      }
      """
    Then the response should be successful

  @success
  Scenario: Notify updated wager details after settlement
    Process wager update notification after settlement
    Validate merchant receives corrected wager details after the initial settlement request

    When I call AMO013 API with:
      """
      {
        "notification_type": "WAGER_UPDATE",
        "notifications": [
          {
            "game_type": <game_type_seamless>,
            "game_key": <game_key_seamless>,
            "wager_no": <wager_no_1>,
            "origin_wager_no": null,
            "ticket_no": <ticket_no_1>,
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
            "is_system_reward": false
          }
        ]
      }
      """
    Then the response should be successful
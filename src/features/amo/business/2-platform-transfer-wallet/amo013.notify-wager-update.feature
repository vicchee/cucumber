@transfer
Feature: AMO013 Notify Wager Update
  As APISYS
  I want to notify the merchant of wager updates
  So that I can report transfer wallet wager activity during a game session
  Support wager update notifications after transfer out
  One transfer wallet session may contain one or more wagers
  Wallet balance is not changed by this notification

  Background:
    Given a merchant member exists

  @success
  Scenario: Notify wager update for a single wager in a transfer wallet session
    Process wager update notification for one transfer wallet wager
    Validate merchant receives wager activity after transfer out and before transfer in

    When I call AMO013 API with:
      """
      {
        "notification_type": "WAGER_UPDATE",
        "notifications": [
          {
            "game_type": <game_type_transfer_wallet>,
            "game_key": <game_key_transfer_wallet>,
            "wager_no": <wager_no_1>,
            "origin_wager_no": null,
            "ticket_no": <ticket_no_1>,
            "platform_username": <platform_username>,
            "type": <wager_type.normal_wager>,
            "status": <wager_status.settled>,
            "currency": <currency>,
            "amount": 10,
            "payment_amount": 10,
            "effective_amount": 10,
            "profit_and_loss": 0,
            "wager_time": <wager_time>,
            "settlement_time": <settlement_time>,
            "is_system_reward": false
          }
        ]
      }
      """
    Then the response should be successful

  @success
  Scenario: Notify wager updates for multiple wagers in a transfer wallet session
    Process wager update notification for multiple transfer wallet wagers
    Validate one transfer wallet session can contain multiple wager updates

    When I call AMO013 API with:
      """
      {
        "notification_type": "WAGER_UPDATE",
        "notifications": [
          {
            "game_type": <game_type_transfer_wallet>,
            "game_key": <game_key_transfer_wallet>,
            "wager_no": <wager_no_1>,
            "origin_wager_no": null,
            "ticket_no": <ticket_no_1>,
            "platform_username": <platform_username>,
            "type": <wager_type.normal_wager>,
            "status": <wager_status.settled>,
            "currency": <currency>,
            "amount": 10,
            "payment_amount": 10,
            "effective_amount": 10,
            "profit_and_loss": 0,
            "wager_time": <wager_time>,
            "settlement_time": <settlement_time>,
            "is_system_reward": false
          },
          {
            "game_type": <game_type_transfer_wallet>,
            "game_key": <game_key_transfer_wallet>,
            "wager_no": <wager_no_2>,
            "origin_wager_no": null,
            "ticket_no": <ticket_no_2>,
            "platform_username": <platform_username>,
            "type": <wager_type.normal_wager>,
            "status": <wager_status.settled>,
            "currency": <currency>,
            "amount": 10,
            "payment_amount": 10,
            "effective_amount": 10,
            "profit_and_loss": 0,
            "wager_time": <wager_time>,
            "settlement_time": <settlement_time>,
            "is_system_reward": false
          }
        ]
      }
      """
    Then the response should be successful
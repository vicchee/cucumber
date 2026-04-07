@general
Feature: AMO013 Notify Wager Metadata Update
  As APISYS
  I want to notify the merchant of wager metadata updates
  So that the merchant can retrieve the latest wager details
  Support metadata update notifications for general wallet games
  Merchant should call AGI004 Get List of Wagers API after the notification
  Wallet balance is not changed by this notification

  Background:
    Given a merchant member exists

  @success
  Scenario: Notify metadata update for a single wager
    Process metadata update notification for one wager
    Validate merchant can retrieve updated wager metadata after the notification

    When I call AMO013 API with:
      """
      {
        "notification_type": "WAGER_METADATA_UPDATE",
        "notifications": [
          {
            "game_type": <game_type>,
            "game_key": <game_key>,
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
            "is_system_reward": <is_system_reward>,
            "metadata": <metadata_updated>,
            "metadata_type": <metadata_type>
          }
        ]
      }
      """
    Then the response should be successful

  @success
  Scenario: Notify metadata update for multiple wagers
    Process metadata update notification for multiple wagers
    Validate one notification can include multiple updated wager records

    When I call AMO013 API with:
      """
      {
        "notification_type": "WAGER_METADATA_UPDATE",
        "notifications": [
          {
            "game_type": <game_type>,
            "game_key": <game_key>,
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
            "is_system_reward": false,
            "metadata": <metadata_updated_1>,
            "metadata_type": <metadata_type>
          },
          {
            "game_type": <game_type_seamless>,
            "game_key": <game_key_seamless>,
            "wager_no": <wager_no_2>,
            "origin_wager_no": null,
            "ticket_no": <ticket_no_2>,
            "platform_username": <platform_username>,
            "type": <wager_type.normal_wager>,
            "status": <wager_status.pending>,
            "currency": <currency>,
            "amount": 20,
            "payment_amount": 20,
            "effective_amount": 20,
            "profit_and_loss": 0,
            "wager_time": <wager_time>,
            "settlement_time": null,
            "is_system_reward": false,
            "metadata": <metadata_updated_2>,
            "metadata_type": <metadata_type>
          }
        ]
      }
      """
    Then the response should be successful

  @validation @optional
  Scenario: Notify wager update with nullable fields
    When I call AMO013 API with:
      """
      {
        "notification_type": <notification_type.metadata_update>,
        "notifications": [
          {
            "game_type": <game_type>,
            "game_key": <game_key>,
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
    Then the response should be successful
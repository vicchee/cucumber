const { Given, When, Then } = require("@cucumber/cucumber");
const Decimal = require("decimal.js");

Given("a successful transfer in exists for:", async function (table) {
  const payload = this.tablePayload(table);

  await this.request(
    "POST",
    this.config.merchant_settings.deposit_payment_api,
    payload,
  );

  if (!this.isApiSuccess()) {
    throw this.error("Failed to create transfer in");
  }
});

Given("a successful transfer out exists for:", async function (table) {
  const payload = this.tablePayload(table);

  await this.request(
    "POST",
    this.config.merchant_settings.withdraw_payment_api,
    payload,
  );

  if (!this.isApiSuccess()) {
    throw this.error("Failed to create transfer out");
  }
});

When("APISYS requests cancel transfer with:", async function (table) {
  const payload = this.tablePayload(table);

  await this.request(
    "POST",
    this.config.merchant_settings.cancel_transfer_api,
    payload,
  );
});

Then("the AMO014 response should be successful", function () {
  if (!this.isApiSuccess()) {
    throw this.error("Expected successful response but got failure");
  }
});

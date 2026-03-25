const { When, Then } = require("@cucumber/cucumber");

When("APISYS cancels a wager with:", async function (table) {
  const payload = this.tablePayload(table);

  await this.request(
    "POST",
    this.config.merchant_settings.cancel_order_api,
    payload,
  );
});

Then("the AMO008 response should be successful", function () {
  if (!this.isApiSuccess()) {
    throw this.error("Expected AMO008 response to be successful");
  }
});

Then("the AMO008 response should fail validation", function () {
  if (this.isApiSuccess()) {
    throw this.error("Expected AMO008 response to fail validation");
  }
});

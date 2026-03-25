const { When, Then } = require("@cucumber/cucumber");

When("APISYS notifies payment failed with:", async function (table) {
  const payload = this.tablePayload(table);

  await this.request(
    "POST",
    this.config.merchant_settings.notify_payment_failed_api,
    payload,
  );
});

Then("the AMO004 response should be successful", function () {
  if (!this.isApiSuccess()) {
    throw this.error("Expected AMO004 response to be successful");
  }
});

Then("the AMO004 response should fail validation", function () {
  if (this.isApiSuccess()) {
    throw this.error("Expected AMO004 response to fail validation");
  }
});

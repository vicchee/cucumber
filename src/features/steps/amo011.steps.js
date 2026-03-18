const { When, Then } = require("@cucumber/cucumber");

When("APISYS requests transfer out with:", async function (table) {
  const payload = this.tablePayload(table);

  await this.request(
    "POST",
    this.config.merchant_settings.withdraw_payment_api,
    payload,
  );
});

Then("the AMO011 response should be successful", function () {
  if (!this.isApiSuccess()) {
    throw this.error("Expected AMO011 response to be successful");
  }
});

Then("the AMO011 response should fail validation", function () {
  if (this.isApiSuccess()) {
    throw this.error("Expected AMO011 response to fail validation");
  }
});

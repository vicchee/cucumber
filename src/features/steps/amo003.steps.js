const { When, Then } = require("@cucumber/cucumber");

When("APISYS requests payment with:", async function (table) {
  const payload = this.tablePayload(table);

  await this.request(
    "POST",
    this.config.merchant_settings.request_payment_api,
    payload,
  );
});

When("APISYS requests payment", async function () {
  this.response = await this.request(
    "POST",
    this.config.merchant_settings.request_payment_api,
    this.requestPayload,
  );
});

Then("the AMO003 response should be successful", function () {
  if (!this.isApiSuccess()) {
    throw this.error("Expected AMO003 response to be successful");
  }
});

Then("the AMO003 response should fail validation", function () {
  if (this.isApiSuccess()) {
    throw this.error("Expected AMO003 response to fail validation");
  }
});

const { Given, When, Then } = require("@cucumber/cucumber");

When("APISYS requests payment with:", async function (table) {
  const payload = this.tablePayload(table);

  await this.request(
    "POST",
    this.config.merchant_settings.request_payment_api,
    {
      transaction_no: payload.transaction_no,
      platform_username: payload.platform_username,
      currency: payload.currency,
      amount: Number(payload.amount),
    },
  );
});

Then("the AMO003 response should be successful", function () {
  if (!this.isApiSuccess()) {
    throw this.error("Expected successful response but got failure");
  }
});

Then("the AMO003 response should fail validation", function () {
  if (this.isApiSuccess()) {
    throw this.error("Expected validation error but got success response");
  }
});

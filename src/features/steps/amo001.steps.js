const { When, Then } = require("@cucumber/cucumber");

When("APISYS requests member wallet balances with:", async function (table) {
  const payload = this.tablePayload(table);

  await this.request(
    "GET",
    this.config.merchant_settings.get_payment_api,
    payload,
  );
});

When("APISYS requests member wallet balances", async function () {
  this.response = await this.request(
    "GET",
    this.config.merchant_settings.get_payment_api,
    this.requestPayload,
  );
});

Then("the AMO001 response should be successful", function () {
  if (!this.isApiSuccess()) {
    throw this.error("Expected AMO001 response to be successful");
  }
});

Then("the response should contain balances for:", function (table) {
  const { currencies } = this.tablePayload(table);
  const data = this.responseData(this.lastResponse);
  const balances = data?.balances;

  if (!balances || typeof balances !== "object") {
    throw this.error("No balances object in response");
  }

  const missing = currencies.filter((currency) => !(currency in balances));
  if (missing.length) {
    throw this.error(`Missing balances for: ${missing.join(", ")}`);
  }
});

Then("the AMO001 response should fail validation", function () {
  if (this.isApiSuccess()) {
    throw this.error("Expected AMO001 response to fail validation");
  }
});

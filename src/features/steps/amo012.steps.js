const { When, Then } = require("@cucumber/cucumber");

When("APISYS undoes a wager with:", async function (table) {
  const payload = this.tablePayload(table);

  await this.request(
    "POST",
    this.config.merchant_settings.undo_wager_api,
    payload,
  );
});

Then("the AMO012 response should be successful", function () {
  if (!this.isApiSuccess()) {
    throw this.error("Expected AMO012 response to be successful");
  }
});

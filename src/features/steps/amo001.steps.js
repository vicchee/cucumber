const { Then } = require("@cucumber/cucumber");

Then("the response should contain balances for:", function (table) {
  const { currencies } = this.parsePayload(table);
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

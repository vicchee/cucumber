const { Given, Then } = require("@cucumber/cucumber");
const { matchesExpected } = require("../support/utils");

Given("a merchant member exists", async function () {
  const username = this.vars.platform_username;

  if (!username) {
    throw this.error("No platform_username provided in test context");
  }

  await this.attachInfo("Setup", { platform_username: username });
});

Then("the response should contain:", function (table) {
  const data = this.responseData(this.lastResponse);
  const expectedPayload = this.tablePayload(table);

  Object.entries(expectedPayload).forEach(([field, expected]) => {
    const actual = data?.[field];

    if (!matchesExpected(actual, expected)) {
      throw this.error("Response field assertion failed", {
        field,
        expected,
        actual,
      });
    }
  });
});

Then(
  "I store the response field {string} as {string}",
  function (field, varName) {
    const value = this.responseData()?.[field];

    if (value === undefined) {
      throw this.error(`Field "${field}" not found in response`);
    }

    this.vars[varName] = value;

    this.attachInfo("Stored", { [varName]: value });
  },
);

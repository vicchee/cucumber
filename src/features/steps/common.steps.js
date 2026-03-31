const { Given } = require("@cucumber/cucumber");

Given("a merchant member exists", async function () {
  const username = this.vars.platform_username;

  if (!username) {
    throw this.error("No platform_username provided in test context");
  }

  await this.attachInfo("Setup", { platform_username: username });
});

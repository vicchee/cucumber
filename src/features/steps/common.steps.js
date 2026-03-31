const { Given, Then, When } = require("@cucumber/cucumber");
const { matchesExpected } = require("../support/utils");

Given("a merchant member exists", async function () {
  const username = this.vars.platform_username;

  if (!username) {
    throw this.error("No platform_username provided in test context");
  }

  await this.attachInfo("Setup", { platform_username: username });
});

When("I prepare a request with:", function (table) {
  const payload = this.tablePayload(table);

  this.requestPayload = payload;
  this.attachInfo("Request", {
    Payload: this.requestPayload,
  });
});

When("I remove {string} from the request payload", function (field) {
  delete this.requestPayload[field];
  this.attachInfo(`Request (missing '${field}')`, {
    Payload: this.requestPayload,
  });
});

Then("the response should contain:", function (table) {
  const data = this.responseData(this.lastResponse);
  const expectedPayload = this.tablePayload(table);

  const failReasonMap = {
    1: "Timeout",
    2: "Cancelled",
    3: "Insufficient balance",
    4: "Password-free limit exceeded",
    5: "Single bet limit exceeded",
    6: "Single event limit exceeded",
    99: "Other",
  };

  for (const [field, expected] of Object.entries(expectedPayload)) {
    const actual = data?.[field];

    if (!matchesExpected(actual, expected)) {
      throw this.error("Response field assertion failed", {
        field,
        expected,
        actual,
        ...(data?.status === 2 &&
          data?.fail_reason && {
            fail_reason: `${data.fail_reason} (${failReasonMap[data.fail_reason]})`,
            ...(data.fail_reason === 99 && { fail_message: data.fail_message }),
          }),
      });
    }
  }
});

Then("I store the full response as {string}", function (varName) {
  const data = this.responseData(this.lastResponse);

  if (data === undefined) {
    throw this.error("No response data available to store");
  }

  this.vars[varName] = JSON.parse(JSON.stringify(data));

  this.attachInfo("Stored response", {
    [varName]: this.vars[varName],
  });
});

Then(
  "the response should be the same as stored response {string}",
  function (varName) {
    const actual = this.responseData(this.lastResponse);
    const expected = this.vars[varName];

    if (expected === undefined) {
      throw this.error(`Stored response "${varName}" not found`);
    }

    if (actual === undefined) {
      throw this.error("No response data available for comparison");
    }

    const actualJson = JSON.stringify(actual);
    const expectedJson = JSON.stringify(expected);

    if (actualJson !== expectedJson) {
      throw this.error("Response mismatch", {
        stored_as: varName,
        expected,
        actual,
      });
    }
  },
);

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

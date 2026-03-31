const { When } = require("@cucumber/cucumber");

When("I prepare a request payload with:", function (table) {
  const payload = this.parsePayload(table);

  this.requestPayload = payload;
  this.attachInfo("Request", { Payload: this.requestPayload });
});

When("I remove {string} from the request payload", function (field) {
  delete this.requestPayload[field];
  this.attachInfo(`Request (missing '${field}')`, {
    Payload: this.requestPayload,
  });
});

/**
 * Call API by <api_code> using prepared request payload (optional "description")
 */
When(
  /^I call (\w+)(?: "([^"]+)")? API$/,
  async function (apiCode, description) {
    const apiDetails = this.apiMap[apiCode];

    if (!apiDetails) {
      throw this.error(`Unknown api_code: ${apiCode}`);
    }

    const { method, url } = apiDetails;

    await this.request(method.toUpperCase(), url, this.requestPayload);
  },
);

/**
 * Call API by <api_code> with inline request payload (table or JSON, optional "description")
 *
 * Table:
 * When I call AMO001 API with:
 *   | field | value |
 *
 * JSON:
 * When I call AMO003 "description" API with:
 * """
 * { ... }
 * """
 */
When(
  /^I call (\w+)(?: "([^"]+)")? API with:$/,
  async function (apiCode, description, arg) {
    const apiDetails = this.apiMap[apiCode];

    if (!apiDetails) {
      throw this.error(`Unknown api_code: ${apiCode}`);
    }

    const { method, url } = apiDetails;

    const payload = this.parsePayload(arg);

    await this.request(method.toUpperCase(), url, payload);
  },
);

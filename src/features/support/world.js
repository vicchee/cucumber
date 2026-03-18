const { setWorldConstructor } = require("@cucumber/cucumber");
const apiService = require("../../services/api.service");
const WorldError = require("./world.error");
const {
  DEFAULT_CURRENCY,
  decodeCtx,
  normalizeResponse,
  normalizeError,
  indent,
  createUUIDVars,
  parseJsonLike,
} = require("./utils");

class World {
  constructor({ attach }) {
    const ctx = decodeCtx();

    this.attach = attach;
    this.lastRequest = null;
    this.lastResponse = null;

    this.config = {
      merchant_settings: ctx.world?.merchant_settings ?? {},
    };

    this.vars = {
      platform_username: ctx.world?.user?.platform_username,
      currency: ctx.world?.defaults?.currency ?? DEFAULT_CURRENCY,
      transaction_no: crypto.randomUUID(),
      transfer_no: crypto.randomUUID(),
      session_id: crypto.randomUUID(),
      ...createUUIDVars("partial_transaction_no_"),
    };
  }

  isApiSuccess(response = this.lastResponse) {
    const status = response?.status ?? response?.code;
    return typeof status === "number" && status < 400;
  }

  responseData(response = this.lastResponse) {
    return response?.body?.data ?? response;
  }

  tablePayload(table) {
    return Object.fromEntries(
      table
        .raw()
        .slice(1) // skip header row: ["field", "value"]
        .map(([key, value]) => [key, this.resolve(value)]),
    );
  }

  error(message, context = {}) {
    return new WorldError(message, {
      ...context,
      request: this.lastRequest,
      response: this.lastResponse,
    });
  }

  async attachInfo(title, ...parts) {
    const lines = [];

    lines.push(`${title}:`);

    for (const part of parts) {
      if (typeof part === "string") {
        lines.push(indent(part, 2));
      } else {
        for (const [key, value] of Object.entries(part || {})) {
          if (value == null) continue;
          lines.push(indent(`${key}:`, 2));
          lines.push(indent(value, 4));
        }
      }
    }

    await this.attach(lines.join("\n"), "text/plain");
  }

  resolve(value) {
    if (typeof value === "string") {
      const resolved = value.replace(
        /<([^>]+)>/g,
        (_, key) => this.vars[key] ?? `<${key}>`,
      );

      return parseJsonLike(resolved);
    }

    if (Array.isArray(value)) {
      return value.map((item) => this.resolve(item));
    }

    if (value && typeof value === "object") {
      return Object.fromEntries(
        Object.entries(value).map(([key, item]) => [key, this.resolve(item)]),
      );
    }

    return value;
  }

  async request(method, url, payload = {}) {
    if (!url) {
      throw this.error("API not set in merchant settings");
    }

    const requestBody = this.resolve(payload);
    this.lastRequest = requestBody;

    try {
      const response = await apiService.call(method, url, requestBody);
      this.lastResponse = normalizeResponse(response);
    } catch (err) {
      this.lastResponse = normalizeError(error);
    }

    await this.attachInfo("Request", {
      API: `${method} ${url}`,
      Payload: this.lastRequest,
      Response: this.lastResponse,
    });

    return this.lastResponse;
  }
}

setWorldConstructor(World);

module.exports = World;

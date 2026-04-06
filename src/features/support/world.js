const { setWorldConstructor, DataTable } = require("@cucumber/cucumber");
const apiService = require("../../services/api.service");
const WorldError = require("./world.error");
const {
  normalizeResponse,
  normalizeError,
  indent,
  createUUIDVars,
  parseJsonLike,
  isJsonLike,
  getValueByPath,
  parseLiteral,
  formatTimestamp,
  shortUUID,
} = require("./utils");
const { CURRENCIES } = require("./constants");

class World {
  constructor(options) {
    const params = options.parameters ?? {};
    this.attach = options.attach;
    this.log = options.log;
    this.requestPayload = undefined;
    this.lastRequest = undefined;
    this.lastResponse = undefined;

    const now = Math.floor(Date.now() / 1000);

    const gameServiceCode = params.game_service_code ?? "0001";
    const parentWagerNo = `${gameServiceCode}-${formatTimestamp()}-${shortUUID()}`;

    this.apiMap = params.apiMap ?? {};

    this.vars = {
      platform_username: params.user?.platform_username,
      currency: params.defaults?.currency ?? "CNY",
      currencies: params.currencies ?? Object.values(CURRENCIES),

      game_type_seamless: params.game_type_seamless ?? "GGL",
      game_type_transfer_wallet: params.game_type_transfer_wallet ?? "PT_SLOT",

      game_key_seamless: params.game_key_seamless ?? "GGL",
      game_key_transfer_wallet: params.game_key_transfer_wallet ?? "PT_SLOT",

      transaction_no: crypto.randomUUID(),
      transfer_no: crypto.randomUUID(),
      session_id: crypto.randomUUID(),

      notification_type: params.notification_type ?? "typeA",

      parent_wager_no: parentWagerNo,

      // for request payment - orders array only
      wager_no: `${parentWagerNo}-1`,
      origin_wager_no: `${parentWagerNo}-1`, // first wager in the settle / resettle flow
      wager_no_1: `${parentWagerNo}-1`,
      wager_no_2: `${parentWagerNo}-2`,
      wager_no_3: `${parentWagerNo}-3`,

      // for resettle wager - unrelated to request payment's order[i].wager_no / parent_wager_no
      resettle_wager_no_1: `${gameServiceCode}-${formatTimestamp()}-${shortUUID()}`,
      resettle_wager_no_2: `${gameServiceCode}-${formatTimestamp()}-${shortUUID()}`,

      // ticket_no = 3rd party game's wager_no
      ticket_no: `ticket-${crypto.randomUUID()}`,
      ticket_no_1: `ticket-${crypto.randomUUID()}`,
      ticket_no_2: `ticket-${crypto.randomUUID()}`,
      ticket_no_3: `ticket-${crypto.randomUUID()}`,

      wager_time: params.wager_time ?? now,
      settlement_time: params.settlement_time ?? now,

      wager_type: {
        normal_wager: 1,
        player_tip: 2,
        system_reward: 3,
      },

      wager_status: {
        creating: -1,
        creation_failed: 7,
        creation_failed_cancelled: 13,
        pending: 0,
        cancelled: 9,
        partial_settled: 12,
        unsettled: 1,
        settled: 2,
        resettled: 6,
        undone: 11,
      },

      metadata_type: params.metadata_type ?? "ggl-settle-wager",

      metadata:
        params.metadata ??
        JSON.stringify({
          order_no: crypto.randomUUID(),
          origin_order_no: crypto.randomUUID(),
          origin_sub_order_no: crypto.randomUUID(),
        }), // metadata should be a JSON string

      is_system_reward: params.is_system_reward ?? false,

      ...createUUIDVars("ticket_no_"),
      ...createUUIDVars("transaction_no_"),
      ...createUUIDVars("transfer_no_"),
      ...createUUIDVars("partial_transaction_no_"),
    };
  }

  resolve(value) {
    if (typeof value === "string") {
      const trimmed = value.trim();
      const fullMatch = trimmed.match(/^<([^>]+)>$/);

      if (fullMatch) {
        const resolved = getValueByPath(this.vars, fullMatch[1]);
        return resolved ?? value;
      }

      if (isJsonLike(trimmed)) {
        const replaced = trimmed.replace(/<([^>]+)>/g, (_, path) => {
          const resolved = getValueByPath(this.vars, path);

          if (resolved === undefined) {
            return `<${path}>`;
          }

          if (
            typeof resolved === "number" ||
            typeof resolved === "boolean" ||
            (!isNaN(resolved) && resolved !== "")
          ) {
            return String(resolved);
          }

          return JSON.stringify(resolved);
        });

        return parseJsonLike(replaced);
      }

      const replaced = value.replace(/<([^>]+)>/g, (_, path) => {
        const resolved = getValueByPath(this.vars, path);
        return resolved === undefined ? `<${path}>` : String(resolved);
      });

      return parseLiteral(replaced);
    }

    if (Array.isArray(value)) {
      return value.map((v) => this.resolve(v));
    }

    if (value && typeof value === "object") {
      return Object.fromEntries(
        Object.entries(value).map(([k, v]) => [k, this.resolve(v)]),
      );
    }

    return value;
  }

  parsePayload(arg) {
    if (!arg) {
      return undefined;
    }

    if (arg instanceof DataTable) {
      return Object.fromEntries(
        arg
          .raw()
          .slice(1) // skip header row: ["field", "value"]
          .map(([key, value]) => [key, this.resolve(value)]),
      );
    }

    if (typeof arg === "string") {
      return this.resolve(arg);
    }

    throw this.error("Unsupported payload argument type", {
      type: typeof arg,
      value: arg,
    });
  }

  async request(method, url, payload = {}) {
    const requestBody = this.resolve(payload);
    this.lastRequest = requestBody;

    try {
      const response = await apiService.call(method, url, requestBody);
      this.lastResponse = normalizeResponse(response);
    } catch (err) {
      this.lastResponse = normalizeError(err);
    }

    await this.attachInfo("Request", {
      API: `${method} ${url}`,
      Payload: this.lastRequest,
      Response: this.lastResponse,
    });

    return this.lastResponse;
  }

  isApiSuccess(response = this.lastResponse) {
    const status = response?.status ?? response?.code;
    return typeof status === "number" && status < 400;
  }

  responseData(response = this.lastResponse) {
    return response?.body?.data ?? response;
  }

  error(message, params = {}) {
    return new WorldError(message, {
      ...params,
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
}

setWorldConstructor(World);

module.exports = World;

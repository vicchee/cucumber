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
  isJsonLike,
  getValueByPath,
} = require("./utils");
const { CURRENCIES } = require("./constants");

class World {
  constructor({ attach }) {
    const ctx = decodeCtx();
    const context = ctx.world ?? {};
    const now = Math.floor(Date.now() / 1000);

    this.attach = attach;
    this.lastRequest = null;
    this.lastResponse = null;

    this.config = { merchant_settings: context.merchant_settings ?? {} };

    // helpers
    const formatTimestamp = (date = new Date()) => {
      const pad = (n) => n.toString().padStart(2, "0");
      return (
        date.getFullYear().toString() +
        pad(date.getMonth() + 1) +
        pad(date.getDate()) +
        pad(date.getHours()) +
        pad(date.getMinutes()) +
        pad(date.getSeconds())
      );
    };

    const shortUUID = () => crypto.randomUUID().replace(/-/g, "").slice(0, 12);

    const gameServiceCode = context.game_service_code ?? "0001";

    const parentWagerNo = `${gameServiceCode}-${formatTimestamp()}-${shortUUID()}`;

    this.vars = {
      platform_username: context.user?.platform_username,
      currency: context.defaults?.currency ?? DEFAULT_CURRENCY,
      currencies: context.currencies ?? Object.values(CURRENCIES),

      game_type_seamless: context.game_type_seamless ?? "GGL",
      game_type_transfer_wallet: context.game_type_transfer_wallet ?? "PT_SLOT",

      game_key_seamless: context.game_key_seamless ?? "GGL",
      game_key_transfer_wallet: context.game_key_transfer_wallet ?? "PT_SLOT",

      transaction_no: crypto.randomUUID(),
      transfer_no: crypto.randomUUID(),
      session_id: crypto.randomUUID(),

      notification_type: context.notification_type ?? "typeA",

      parent_wager_no: parentWagerNo,
      origin_wager_no: parentWagerNo,

      wager_no: `${parentWagerNo}-1`,
      wager_no_1: `${parentWagerNo}-1`,
      wager_no_2: `${parentWagerNo}-2`,

      ticket_no: `ticket-${crypto.randomUUID()}`,

      wager_time: context.wager_time ?? now,
      settlement_time: context.settlement_time ?? now,

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

      metadata_type: context.metadata_type ?? "ggl-settle-wager",

      metadata:
        context.metadata ??
        JSON.stringify({
          order_no: crypto.randomUUID(),
          origin_order_no: crypto.randomUUID(),
          origin_sub_order_no: crypto.randomUUID(),
        }),

      is_system_reward: context.is_system_reward ?? false,

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

      // replace placeholders e.g. '<type.b>' -> this.vars['type']?.['b']
      const replaced = value.replace(/<([^>]+)>/g, (_, path) => {
        const resolved = getValueByPath(this.vars, path);

        if (resolved === undefined) {
          return `<${path}>`;
        }

        // JSON-like ("[]" / "{}"): stringify values to keep valid JSON
        if (isJsonLike(value)) {
          return JSON.stringify(resolved);
        }

        return resolved;
      });

      return parseJsonLike(replaced);
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

  tablePayload(table) {
    return Object.fromEntries(
      table
        .raw()
        .slice(1) // skip header row: ["field", "value"]
        .map(([key, value]) => [key, this.resolve(value)]),
    );
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

  isApiSuccess(response = this.lastResponse) {
    const status = response?.status ?? response?.code;
    return typeof status === "number" && status < 400;
  }

  responseData(response = this.lastResponse) {
    return response?.body?.data ?? response;
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
}

setWorldConstructor(World);

module.exports = World;

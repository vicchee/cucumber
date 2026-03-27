const crypto = require("crypto");

const CTX_ENV = "CUCUMBER_WORLD_CONTEXT_B64";
const DEFAULT_CURRENCY = "CNY";
const GENERATED_UUID_COUNT = 10;
const INDENT = "  ";

function decodeCtx() {
  const raw = process.env[CTX_ENV];

  if (!raw) {
    throw new Error(`${CTX_ENV} environment variable missing`);
  }

  try {
    return JSON.parse(Buffer.from(raw, "base64").toString("utf8"));
  } catch {
    throw new Error(`Invalid ${CTX_ENV} payload`);
  }
}

function normalizeResponse(response) {
  return {
    status: response?.status ?? response?.code ?? 200,
    body: response?.body ?? response?.data ?? response ?? {},
  };
}

function normalizeError(error) {
  if (error?.response?.data) {
    return normalizeResponse(error.response.data);
  }

  return {
    status: "failed",
    error: error?.message ?? "Unknown error",
  };
}

function createUUIDVars(prefix, count = GENERATED_UUID_COUNT) {
  return Object.fromEntries(
    Array.from({ length: count }, (_, index) => [
      `${prefix}${index + 1}`,
      crypto.randomUUID(),
    ]),
  );
}

function pretty(value) {
  return typeof value === "string" ? value : JSON.stringify(value, null, 2);
}

function indent(value, level = 1) {
  const prefix = INDENT.repeat(level);

  return pretty(value)
    .split("\n")
    .map((line) => `${prefix}${line}`)
    .join("\n");
}

function normalizeExpected(expected) {
  if (expected === "true") return true;
  if (expected === "false") return false;
  if (expected === "null") return null;
  if (expected !== "" && !Number.isNaN(Number(expected)))
    return Number(expected);
  return expected;
}

function matchesExpected(actual, expected) {
  if (expected === "any non-empty value") {
    return actual !== null && actual !== undefined && actual !== "";
  }

  if (expected === "any value") {
    return actual !== undefined;
  }

  return actual === normalizeExpected(expected);
}

// safely resolve nested paths like 'a.b.c'
function getValueByPath(obj, path) {
  if (path in obj) return obj[path];
  return path.split(".").reduce((acc, key) => acc?.[key], obj);
}

function isJsonLike(value) {
  const trimmed = value.trim();
  return (
    (trimmed.startsWith("[") && trimmed.endsWith("]")) ||
    (trimmed.startsWith("{") && trimmed.endsWith("}"))
  );
}

function parseJsonLike(value) {
  const trimmed = value.trim();

  if (isJsonLike(value)) {
    try {
      return JSON.parse(trimmed);
    } catch {
      return value;
    }
  }

  return value;
}

module.exports = {
  DEFAULT_CURRENCY,
  decodeCtx,
  normalizeResponse,
  normalizeError,
  createUUIDVars,
  pretty,
  indent,
  matchesExpected,
  getValueByPath,
  parseJsonLike,
  isJsonLike,
};

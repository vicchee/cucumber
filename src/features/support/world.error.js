const { indent } = require("./utils");

class WorldError extends Error {
  constructor(message, context = {}) {
    super(message);
    this.name = "ScenarioError";
    this.context = context;

    Error.captureStackTrace?.(this, WorldError);

    this.originalMessage = message;
    this.message = this.formatMessage();
  }

  formatMessage() {
    const lines = [`${this.name}: ${this.originalMessage}`];

    const contextEntries = Object.entries(this.context ?? {}).filter(
      ([, value]) => value != null,
    );

    if (contextEntries.length > 0) {
      lines.push(" Context:");

      for (const [key, value] of contextEntries) {
        lines.push(indent(`${key}:`, 2));
        lines.push(indent(value, 4));
      }
    }

    const stackLines = this.stack
      ?.split("\n")
      .slice(1)
      .map((line) => line.trim())
      .filter(Boolean);

    if (stackLines?.length) {
      lines.push(" Traceback:");

      for (const line of stackLines) {
        lines.push(indent(line, 2));
      }
    }

    return lines.join("\n");
  }
}

module.exports = WorldError;

const { spawn } = require("child_process");
const path = require("path");
const fs = require("fs");
const { logger } = require("../utils/logger");
const { jsonDir } = require("../config/report.config");

exports.run = async (timestamp, ctx = {}) => {
  const runDir = path.join(jsonDir, String(timestamp));
  fs.mkdirSync(runDir, { recursive: true });

  const featurePaths = ctx.featurePaths?.length
    ? ctx.featurePaths
    : ["src/features/**/*.feature"];

  const jsonFile = path.join(runDir, "report.json");

  const args = [
    "cucumber-js",
    ...featurePaths,
    "--require",
    "src/features/steps/**/*.js",
    "--require",
    "src/features/support/**/*.js",
    "--format",
    "progress",
    "--format",
    `json:${jsonFile}`,
  ];

  // Encode world context for Cucumber
  const encodedCtx = Buffer.from(JSON.stringify(ctx)).toString("base64");

  return new Promise((resolve, reject) => {
    const proc = spawn("npx", args, {
      stdio: "pipe",
      env: {
        ...process.env,
        CUCUMBER_WORLD_CONTEXT_B64: encodedCtx,
      },
    });

    logger.info("CUCUMBER_CMD", { command: "npx", args });

    proc.stdout.on("data", (d) => logger.info(d.toString()));
    proc.stderr.on("data", (d) => logger.error(d.toString()));

    proc.on("close", (code) => {
      if (code !== 0) {
        logger.warn("CUCUMBER_EXIT_NON_ZERO", { code });
      }
      resolve(jsonFile);
    });

    proc.on("error", reject);
  });
};

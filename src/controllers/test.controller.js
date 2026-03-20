const queue = require("../queues/test.queue");
const { v4: uuid } = require("uuid");
const config = require("../config/client.config");

exports.runTests = async (req, res) => {
  const {
    format = "html",
    platform_username = "supermerchant1user",
    currency = "CNY",
  } = req.body;

  const domain = config.baseURL;
  const mockApiDomain = config.mockApiDomain;

  const merchantSettings = {
    request_payment_api: `${domain}/api/v1/transfer-wallet/request-payment`,
    notify_payment_failed_api: `${domain}/api/v1/transfer-wallet/notify-payment-failed`,
    settle_order_api: `${domain}/api/v1/transfer-wallet/settle-wager`,
    cancel_order_api: `${domain}/api/v1/transfer-wallet/cancel-wager`,
    resettle_wager_api: `${domain}/api/v1/transfer-wallet/resettle-wager`,
    undo_wager_api: `${domain}/api/v1/transfer-wallet/undo-wager`,
    get_payment_api: `${domain}/api/v1/transfer-wallet/balance`,
    withdraw_payment_api: `${domain}/api/v1/transfer-wallet/request-transfer-out`,
    deposit_payment_api: `${domain}/api/v1/transfer-wallet/request-transfer-in`,
    cancel_transfer_api: `${domain}/api/v1/transfer-wallet/cancel-transfer`,
    notify_wager_api: `${mockApiDomain}/wager/notify`,
  };

  const world = {
    user: {
      platform_username,
    },
    merchant_settings: merchantSettings,
    defaults: { currency },
  };

  const games = generateMockGames(2);
  const featurePaths = resolveFeaturePaths(games);

  const job = await queue.add(
    "run-tests",
    {
      runId: uuid(),
      format,
      world,
      featurePaths,
    },
    {
      removeOnComplete: 20,
      removeOnFail: 50,
    },
  );

  return res.json({
    jobId: job.id,
    status: "queued",
  });
};

exports.getStatus = async (req, res) => {
  const job = await queue.getJob(req.params.id);

  if (!job) {
    return res.status(404).json({ error: "job not found" });
  }

  const state = await job.getState();

  res.json({
    id: job.id,
    state,
    progress: job.progress || 0,
    result: job.returnvalue || null,
  });
};

exports.cancel = async (req, res) => {
  const job = await queue.getJob(req.params.id);

  if (!job) return res.status(404).json({ error: "job not found" });

  await job.remove();

  res.json({ status: "cancelled" });
};

function generateMockGames(mode) {
  switch (mode) {
    case 1:
      return [
        {
          game_key: "game_1",
          game_type: { key: "type_1", wallet_integration_mode: 1 },
        },
      ];

    case 2:
      return [
        {
          game_key: "game_2",
          game_type: { key: "type_2", wallet_integration_mode: 2 },
        },
      ];

    default:
    case "both":
      return [
        {
          game_key: "game_2",
          game_type: { key: "type_2", wallet_integration_mode: 2 },
        },
        {
          game_key: "game_2",
          game_type: { key: "type_2", wallet_integration_mode: null },
        },
        {
          game_key: "game_1",
          game_type: { key: "type_1", wallet_integration_mode: 1 },
        },
      ];
  }
}

function resolveFeaturePaths(games) {
  const modes = games.flatMap((g) => {
    const m = g?.game_type?.wallet_integration_mode;
    return Array.isArray(m) ? m : [m];
  });

  const hasMode1 = modes.includes(1);
  const hasMode2 = modes.includes(2);
  const hasNull = modes.includes(null);

  const all = "src/features/**/*.feature";
  const amoAll = "src/features/amo/**/*.feature";
  const amoGeneral = "src/features/amo/0-general/*.feature";
  const amoSeamless = "src/features/amo/1-seamless/*.feature";
  const amoPlatformTransferWallet =
    "src/features/amo/2-platform-transfer-wallet/*.feature";

  if (hasNull) {
    return [amoAll];
  }

  if (hasMode2 && !hasMode1) {
    return [amoGeneral, amoPlatformTransferWallet];
  }

  if (hasMode1 && !hasMode2) {
    return [amoGeneral, amoSeamless];
  }

  return [all];
}

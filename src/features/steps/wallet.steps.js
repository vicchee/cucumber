const { Given, Then } = require("@cucumber/cucumber");
const assert = require("assert");
const Decimal = require("decimal.js");

// AMO001 - Get one specific member wallet balance
async function getWalletBalance(world) {
  const currency = world.vars.currency;
  const platformUsername = world.vars.platform_username;
  const apiDetails = world.apiMap["AMO001"];
  await world.request(apiDetails.method, apiDetails.url, {
    platform_username: platformUsername,
    currencies: [currency],
  });

  const data = world.responseData();
  const balance = data?.balances?.[currency];

  if (balance !== 0 && !balance) {
    throw world.error("Failed to get wallet balance", {
      response: world.responseData(),
    });
  }

  return new Decimal(balance);
}

Given(
  "the member has positive wallet balance in {string}",
  async function (currencyPlaceholder) {
    const currency = this.resolve(currencyPlaceholder);
    const balance = await getWalletBalance(this);

    if (balance.lte(0)) {
      throw this.error("Wallet balance must be positive for this scenario", {
        currency,
        balance: balance.toString(),
      });
    }

    await this.attachInfo("Balance", { [currency]: balance.toString() });
  },
);

Given(
  "I record the current wallet balance in {string}",
  async function (currencyPlaceholder) {
    const currency = this.resolve(currencyPlaceholder);
    const balance = await getWalletBalance(this);

    this.vars.beforeBalances ??= {};
    this.vars.beforeBalances[currency] = balance;

    await this.attachInfo("Balance", { [currency]: balance.toString() });
  },
);

Given(
  "I prepare an amount exceeding the balance by {float}",
  async function (extra) {
    const currency = this.vars.currency;

    const balance =
      this.vars.beforeBalances?.[currency] ?? (await getWalletBalance(this));

    const available = balance.greaterThan(0) ? balance : balance.constructor(0);

    const amount = available.plus(extra);

    this.vars.amount_exceeding_balance = amount.toString();

    await this.attachInfo(`Amount to deduct: ${amount.toString()}`, {
      currency,
      balance: balance.toString(),
      available: available.toString(),
      extra,
    });
  },
);

Given("I prepare a deduction amount of {float}", async function (inputAmount) {
  const currency = this.vars.currency;

  const balance =
    this.vars.beforeBalances?.[currency] ?? (await getWalletBalance(this));

  const amount = new Decimal(inputAmount);

  if (amount.lte(0)) {
    throw this.error(`Deduction amount must be positive`, {
      amount: amount.toString(),
    });
  }

  if (balance.lte(0) || amount.gte(balance)) {
    throw this.error(`Deduction amount exceeds available balance`, {
      balance: balance.toString(),
      amount: amount.toString(),
    });
  }

  this.vars.deduction_amount = amount.toString();

  await this.attachInfo(`Amount to deduct: ${amount.toString()}`, {
    currency,
    balance: balance.toString(),
    amount: amount.toString(),
  });
});

async function assertWalletBalanceDecrease(
  world,
  currencyPlaceholder,
  amountPlaceholder,
) {
  const currency = world.resolve(currencyPlaceholder);
  const amount = new Decimal(world.resolve(amountPlaceholder));
  const before = world.vars.beforeBalances?.[currency];
  const after = await getWalletBalance(world);
  const expected = before.minus(amount);

  assert(
    after.equals(expected),
    [
      `Wallet balance assertion failed`,
      `  Check             : decrease`,
      `  Currency          : ${currency}`,
      `  Decrease amount   : ${amount.toString()}`,
      `  Balance before    : ${before.toString()}`,
      `  Expected balance  : ${expected.toString()}`,
      `  Actual balance    : ${after.toString()}`,
    ].join("\n"),
  );

  await world.attachInfo("Wallet balance check", {
    Currency: currency,
    Before: before.toString(),
    After: after.toString(),
    "Expected decrease": amount.toString(),
    Expected: expected.toString(),
  });
}

Then(
  "the wallet balance in {string} should decrease by {string}",
  async function (currencyPlaceholder, amountPlaceholder) {
    await assertWalletBalanceDecrease(
      this,
      currencyPlaceholder,
      amountPlaceholder,
    );
  },
);

Then(
  "the wallet balance in {string} should decrease by {float}",
  async function (currencyPlaceholder, amount) {
    await assertWalletBalanceDecrease(this, currencyPlaceholder, amount);
  },
);

async function assertWalletBalanceIncrease(
  world,
  currencyPlaceholder,
  amountPlaceholder,
) {
  const currency = world.resolve(currencyPlaceholder);
  const amount = new Decimal(world.resolve(amountPlaceholder));
  const before = world.vars.beforeBalances?.[currency];
  const after = await getWalletBalance(world);
  const expected = before.plus(amount);

  assert(
    after.equals(expected),
    [
      `Wallet balance assertion failed`,
      `  Check             : decrease`,
      `  Currency          : ${currency}`,
      `  Increase amount   : ${amount.toString()}`,
      `  Balance before    : ${before.toString()}`,
      `  Expected balance  : ${expected.toString()}`,
      `  Actual balance    : ${after.toString()}`,
    ].join("\n"),
  );

  await world.attachInfo("Wallet balance check", {
    Currency: currency,
    Before: before.toString(),
    After: after.toString(),
    "Expected increase": amount.toString(),
    Expected: expected.toString(),
  });
}

Then(
  "the wallet balance in {string} should increase by {float}",
  async function (currencyPlaceholder, amount) {
    await assertWalletBalanceIncrease(this, currencyPlaceholder, amount);
  },
);

Then(
  "the wallet balance in {string} should increase by {string}",
  async function (currencyPlaceholder, amount) {
    await assertWalletBalanceIncrease(this, currencyPlaceholder, amount);
  },
);

Then(
  "the wallet balance in {string} should remain unchanged",
  async function (currencyPlaceholder) {
    const currency = this.resolve(currencyPlaceholder);
    const before = this.vars.beforeBalances?.[currency];
    const after = await getWalletBalance(this);

    assert(
      after.equals(before),
      [
        `Wallet balance assertion failed`,
        `  Check             : unchanged`,
        `  Currency          : ${currency}`,
        `  Balance before    : ${before.toString()}`,
        `  Expected balance  : ${before.toString()}`,
        `  Actual balance    : ${after.toString()}`,
      ].join("\n"),
    );

    await this.attachInfo("Wallet balance check (unchanged)", {
      Currency: currency,
      Before: before.toString(),
      After: after.toString(),
      Expected: before.toString(),
    });
  },
);

Then(
  "the response amount should equal the integer part of the recorded wallet balance in {string}",
  function (currencyPlaceholder) {
    const currency = this.resolve(currencyPlaceholder);

    const before = this.vars.beforeBalances?.[currency];
    const actual = new Decimal(this.responseData()?.amount);

    if (!before) {
      throw this.error("No recorded balance found for comparison", {
        currency,
      });
    }

    const expected = new Decimal(before).floor().negated();

    if (!actual.equals(expected)) {
      throw this.error(
        [
          `Integer transfer assertion failed`,
          `  Currency          : ${currency}`,
          `  Balance before    : ${before.toString()}`,
          `  Expected amount   : ${expected.toString()}`,
          `  Actual amount     : ${actual.toString()}`,
        ].join("\n"),
      );
    }
  },
);

Then(
  "the wallet balance in {string} should equal the remaining decimal balance",
  async function (currencyPlaceholder) {
    const currency = this.resolve(currencyPlaceholder);

    const before = this.vars.beforeBalances?.[currency];
    const after = await getWalletBalance(this);

    if (!before) {
      throw this.error("No recorded balance found for comparison", {
        currency,
      });
    }

    const expected = new Decimal(before).minus(new Decimal(before).floor());

    if (!after.equals(expected)) {
      throw this.error(
        [
          `Remaining decimal assertion failed`,
          `  Currency          : ${currency}`,
          `  Balance before    : ${before.toString()}`,
          `  Expected balance  : ${expected.toString()}`,
          `  Actual balance    : ${after.toString()}`,
        ].join("\n"),
      );
    }

    await this.attachInfo("Remaining decimal check", {
      Currency: currency,
      Before: before.toString(),
      After: after.toString(),
      Expected: expected.toString(),
    });
  },
);

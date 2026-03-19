const { Given, Then } = require("@cucumber/cucumber");
const assert = require("assert");
const Decimal = require("decimal.js");

// AMO001 - Get one specific member wallet balance
async function getWalletBalance(world) {
  const currency = world.vars.currency;
  await world.request("GET", world.config.merchant_settings.get_payment_api, {
    platform_username: world.vars.platform_username,
    currencies: [currency],
  });

  const data = world.responseData();
  const balance = data?.balances?.[currency];

  if (!balance) throw this.error("Failed to get wallet balance");

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

    const amount = balance.abs().plus(extra).negated();
    this.vars.amount_exceeding_balance = amount.toString();

    await this.attachInfo(`Amount to deduct: ${amount.toString()}`, {
      currency,
      balance: balance.toString(),
      extra,
    });
  },
);

Given(
  "I prepare a valid amount less than the balance by {float}",
  async function (extra) {
    const currency = this.vars.currency;

    const balance =
      this.vars.beforeBalances?.[currency] ?? (await getWalletBalance(this));

    const amount = new Decimal(balance).minus(extra); // ensure positive deduction amount

    if (amount.lte(0)) {
      throw this.error(`Invalid amount for deduction`, {
        balance: `${balance.toString()}`,
        extra: `${extra}`,
        deduction_amount: `${amount.toString()}`,
      });
    }

    this.vars.deduction_amount = amount.toString();

    await this.attachInfo(`Amount to deduct: ${amount.toString()}`, {
      currency,
      balance: balance.toString(),
      extra,
    });
  },
);

Then(
  "the wallet balance in {string} should decrease by {string}",
  async function (currencyPlaceholder, amountPlaceholder) {
    const currency = this.resolve(currencyPlaceholder);
    const amount = this.resolve(amountPlaceholder);
    const before = this.vars.beforeBalances?.[currency];
    const after = await getWalletBalance(this);
    const expected = before.minus(amount);

    assert(
      after.equals(expected),
      `Expected wallet ${currency} to decrease by ${amount}, before=${before.toString()}, after=${after.toString()}, expected=${expected.toString()}`,
    );

    await this.attachInfo("Wallet balance check", {
      Currency: `${currency}`,
      Before: `${before.toString()}`,
      After: `${after.toString()}`,
      "Expected decrease": `${new Decimal(amount).toString()}`,
    });
  },
);

Then(
  "the wallet balance in {string} should decrease by {float}",
  async function (currencyPlaceholder, amountPlaceholder) {
    const currency = this.resolve(currencyPlaceholder);
    const amount = this.resolve(amountPlaceholder);
    const before = this.vars.beforeBalances?.[currency];
    const after = await getWalletBalance(this);
    const expected = before.minus(amount);

    assert(
      after.equals(expected),
      `Expected wallet ${currency} to decrease by ${amount}, before=${before.toString()}, after=${after.toString()}, expected=${expected.toString()}`,
    );

    await this.attachInfo("Wallet balance check", {
      Currency: `${currency}`,
      Before: `${before.toString()}`,
      After: `${after.toString()}`,
      "Expected decrease": `${new Decimal(amount).toString()}`,
    });
  },
);

Then(
  "the wallet balance in {string} should increase by {float}",
  async function (currencyPlaceholder, amount) {
    const currency = this.resolve(currencyPlaceholder);
    const before = this.vars.beforeBalances?.[currency];
    const after = await getWalletBalance(this);
    const expected = before.plus(amount);

    assert(
      after.equals(expected),
      `Expected wallet ${currency} to increase by ${amount}, before=${before.toString()}, after=${after.toString()}, expected=${expected.toString()}`,
    );

    await this.attachInfo("Wallet balance check", {
      Currency: `${currency}`,
      Before: `${before.toString()}`,
      After: `${after.toString()}`,
      "Expected increase": `${new Decimal(amount).toString()}`,
    });
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
      `Expected wallet ${currency} to remain unchanged, before=${before.toString()}, after=${after.toString()}`,
    );

    await this.attachInfo("Wallet balance check (unchanged):", {
      Currency: `${currency}`,
      Before: `${before.toString()}`,
      After: `${after.toString()}`,
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

    // Use Decimal to handle integer truncation
    const expected = new Decimal(before).floor().negated();

    if (!actual.equals(expected)) {
      throw this.error("Integer transfer mismatch", {
        currency,
        before: before.toString(),
        expected: expected.toString(),
        actual: actual.toString(),
      });
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

    // Decimal subtraction to get the fractional remainder
    const expected = new Decimal(before).minus(new Decimal(before).floor());

    if (!after.equals(expected)) {
      throw this.error("Remaining decimal mismatch", {
        currency,
        before: before.toString(),
        after: after.toString(),
        expected: expected.toString(),
      });
    }

    await this.attachInfo("Remaining decimal check", {
      Currency: currency,
      Before: before.toString(),
      After: after.toString(),
      Expected: expected.toString(),
    });
  },
);

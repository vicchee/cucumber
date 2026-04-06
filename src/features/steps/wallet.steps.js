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

    await this.attachInfo("Balance", {
      Context: currency,
      BalanceFlow: `Before ${balance} → After ${balance}`,
      Delta: `Actual 0 / Expected 0`,
    });
  },
);

Given(
  "I record the current wallet balance in {string}",
  async function (currencyPlaceholder) {
    const currency = this.resolve(currencyPlaceholder);
    const balance = await getWalletBalance(this);

    this.vars.beforeBalances ??= {};
    this.vars.beforeBalances[currency] = balance;

    await this.attachInfo("Balance recorded", {
      Context: currency,
      BalanceFlow: `Before ${balance} → After ${balance}`,
      Delta: `Actual 0 / Expected 0`,
    });
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

    await this.attachInfo("Amount prepared (exceeding)", {
      Context: currency,
      BalanceFlow: `Before ${balance} → After ${available}`,
      Delta: `Actual +${extra} / Expected ${amount}`,
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

  await this.attachInfo("Amount prepared (deduction)", {
    Context: currency,
    BalanceFlow: `Before ${balance} → After ${balance.minus(amount)}`,
    Delta: `Actual -${amount} / Expected -${amount}`,
  });
});

async function assertWalletBalance(
  world,
  currencyPlaceholder,
  amountPlaceholder,
  operation,
) {
  const currency = world.resolve(currencyPlaceholder);
  const before = world.vars.beforeBalances?.[currency];
  const after = await getWalletBalance(world);

  const amount =
    operation === "unchanged"
      ? new Decimal(0)
      : new Decimal(world.resolve(amountPlaceholder));

  const expectedChange =
    operation === "increase"
      ? amount
      : operation === "decrease"
        ? amount.negated()
        : new Decimal(0);

  const expected = before.plus(expectedChange);
  const actualChange = after.minus(before);

  assert(
    after.equals(expected),
    [
      `Wallet balance assertion failed`,
      `  Context         : ${operation} | ${currency}`,
      `  BalanceFlow     : Before ${before} → After ${after}`,
      `  Delta           : Actual ${actualChange} / Expected ${expectedChange}`,
      `  ExpectedBalance : ${expected}`,
    ].join("\n"),
  );

  await world.attachInfo("Wallet balance check", {
    Context: `${operation} | ${currency}`,
    BalanceFlow: `Before ${before} → After ${after}`,
    Delta: `Actual ${actualChange} / Expected ${expectedChange}`,
    Expected: expected.toString(),
  });
}

Then(
  /^the wallet balance in "([^"]+)" should (increase|decrease) by "?([^"]+)"?$/,
  async function (currencyPlaceholder, operation, amountPlaceholder) {
    await assertWalletBalance(
      this,
      currencyPlaceholder,
      amountPlaceholder,
      operation,
    );
  },
);

Then(
  "the wallet balance in {string} should remain unchanged",
  async function (currencyPlaceholder) {
    await assertWalletBalance(this, currencyPlaceholder, 0, "unchanged");
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
          `  Context     : ${currency}`,
          `  BalanceFlow : Before ${before} → After N/A`,
          `  Delta       : Actual ${actual} / Expected ${expected}`,
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
          `  Context     : ${currency}`,
          `  BalanceFlow : Before ${before} → After ${after}`,
          `  Delta       : Actual ${after.minus(before)} / Expected ${expected}`,
        ].join("\n"),
      );
    }

    await this.attachInfo("Remaining decimal check", {
      Context: currency,
      BalanceFlow: `Before ${before} → After ${after}`,
      Delta: `Actual ${after.minus(before)} / Expected ${expected}`,
    });
  },
);
// amo001 - verify balances in response
Then("the response should contain balances for {string}", function (input) {
  const data = this.responseData(this.lastResponse);
  const balances = data?.balances;

  if (!balances || typeof balances !== "object") {
    throw this.error("No balances object in response");
  }

  const resolved = this.resolve(input);
  const currencies = Array.isArray(resolved) ? resolved : [resolved];

  const missing = currencies.filter((c) => !(c in balances));

  if (missing.length) {
    throw this.error("Missing balances", {
      Context: Object.keys(balances).join(", "),
      Missing: missing.join(", "),
    });
  }

  this.attachInfo("Balances check", {
    Context: Object.keys(balances).join(", "),
    Result: "All present",
  });
});

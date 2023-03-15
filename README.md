# Euler Finance Hack PoC

A documented PoC of the Euler Finance hack, which ocurred Monday 13, March, 2023. See the replicated transaction on [ETHTX.info](https://ethtx.info/mainnet/0xc310a0affe2169d1f6feec1c63dbc7f7c62a887fa48795d327d4d2da2d6b111d)

In short, the vulnerability was a business logic bug which let the attacker make his position artificially underwater, triggering a profitable liquidation. With the help of a flashloan, all the vulnerable pools could be drained.

## Running the simulation

Make sure you have Foundry installed, and run:

```
forge t -vvvv
```

If you only wanna see the logs related to how the eDAI/dDAI balance increases or decreases, just run:

```
forge t
```

The [NumenCyber PoC](https://github.com/numencyber/SmartContractHack_PoC/blob/main/EulerfinanceHack/EulerHackPoc.sol) was helpful in getting this PoC over the line.

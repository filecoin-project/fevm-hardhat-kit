# solidity-cborutils [![GitHub workflow changelog](https://img.shields.io/github/workflow/status/smartcontractkit/solidity-cborutils/CI?style=flat-square&label=github-actions)](https://github.com/smartcontractkit/solidity-cborutils/actions?query=workflow%3ACI)
Utilities for encoding [CBOR](http://cbor.io/) data in solidity

## Install

```bash
$ git clone https://github.com/smartcontractkit/solidity-cborutils.git
$ cd solidity-cborutils
$ yarn install
```
## Usage

The Buffer library is not intended to be moved to storage.
In order to persist a Buffer in storage from memory,
   you must manually copy each of its attributes to storage,
   and back out when moving it back to memory.

## Test

```bash
$ yarn test
```
# Buffer

[![Build Status](https://travis-ci.com/ensdomains/buffer.svg?branch=master)](https://travis-ci.com/ensdomains/buffer) [![License](https://img.shields.io/badge/License-BSD--2--Clause-blue.svg)](LICENSE)

A library for working with mutable byte buffers in Solidity.

Byte buffers are mutable and expandable, and provide a variety of primitives for writing to them. At any time you can fetch a bytes object containing the current contents of the buffer. The bytes object should not be stored between operations, as it may change due to resizing of the buffer.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Installing

Buffer uses npm to manage dependencies, therefore the installation process is kept simple:

```
npm install
```

### Running tests

Buffer uses truffle for its ethereum development environment. All tests can be run using truffle:

```
truffle test
```

To run linting, use solium:

```
solium --dir ./contracts
```

## Including Buffer in your project

### Installation

```
npm install buffer --save
```

## Built With
* [Truffle](https://github.com/trufflesuite/truffle) - Ethereum development environment 


## Authors

* **Nick Johnson** - [Arachnid](https://github.com/Arachnid)

See also the list of [contributors](https://github.com/ensdomains/buffer/contributors) who participated in this project.

## License

This project is licensed under the BSD 2-clause "Simplified" License - see the [LICENSE](LICENSE) file for details

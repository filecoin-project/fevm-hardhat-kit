// SPDX-License-Identifier: BSD-2-Clause
pragma solidity >=0.8.4;

import "./../contracts/Buffer.sol";

contract TestBuffer {
    using Buffer for Buffer.buffer;

    function checkBufferInitOverflow() public pure {
        Buffer.buffer memory buf;
        buf.init(256);
        buf.init(2**256-1);
    }

    function testBufferAppend() public pure {
        Buffer.buffer memory buf;
        buf.init(256);
        buf.append("Hello");
        buf.append(", ");
        buf.append("world!");
        require(
          keccak256(abi.encodePacked(string(buf.buf))) == keccak256(abi.encodePacked("Hello, world!")),
          "Unexpected buffer contents."
        );
    }

    function testBufferAppendUint8() public pure {
        Buffer.buffer memory buf;
        Buffer.init(buf, 256);
        buf.append("Hello,");
        buf.appendUint8(0x20);
        buf.append("world!");
        require(
          keccak256(abi.encodePacked(string(buf.buf))) == keccak256(abi.encodePacked("Hello, world!")),
          "Unexpected buffer contents."
        );
    }

    function testBufferResizeAppendUint8() public pure {
        Buffer.buffer memory buf;
        Buffer.init(buf, 32);
        buf.append("01234567890123456789012345678901");
        buf.appendUint8(0x20);
        require(buf.capacity == 96, "Expected buffer capacity to be 96");
        require(buf.buf.length == 33, "Expected buffer length to be 33");
        require(
          keccak256(abi.encodePacked(string(buf.buf))) == keccak256(abi.encodePacked("01234567890123456789012345678901 ")),
          "Unexpected buffer contents."
        );
    }

    function testBufferResizeAppendBytes() public pure {
      Buffer.buffer memory buf;
      Buffer.init(buf, 32);
      buf.append("01234567890123456789012345678901");
      buf.append("23");
      require(buf.capacity == 96, "Expected buffer capacity to be 96");
      require(buf.buf.length == 34, "Expected buffer length to be 33");
      require(
        keccak256(abi.encodePacked(string(buf.buf))) == keccak256(abi.encodePacked("0123456789012345678901234567890123")),
        "Unexpected buffer contents."
      );
    }

    function testBufferResizeAppendManyBytes() public pure {
      Buffer.buffer memory buf;
      Buffer.init(buf, 32);
      buf.append("01234567890123456789012345678901");
      buf.append("0123456789012345678901234567890101234567890123456789012345678901");
      require(buf.capacity == 192, "Expected buffer capacity to be 192");
      require(buf.buf.length == 96, "Expected buffer length to be 96");
      require(
        keccak256(abi.encodePacked(string(buf.buf))) == keccak256(abi.encodePacked("012345678901234567890123456789010123456789012345678901234567890101234567890123456789012345678901")),
        "Unexpected buffer contents."
      );
    }

    function testBufferZeroSized() public pure {
      Buffer.buffer memory buf;
      Buffer.init(buf, 0);
      buf.append("first");
      require(buf.capacity == 32, "Expected buffer capacity to be 32");
      require(buf.buf.length == 5, "Expected buffer length to be 5");
      require(
        keccak256(abi.encodePacked(string(buf.buf))) == keccak256(abi.encodePacked("first")),
        "Unexpected buffer contents."
      );
    }

    function testBufferAppendInt() public pure {
      Buffer.buffer memory buf;
      Buffer.init(buf, 256);
      buf.append("Hello");
      buf.appendInt(0x2c20, 2);
      buf.append("world!");
      require(
        keccak256(abi.encodePacked(string(buf.buf))) == keccak256(abi.encodePacked("Hello, world!")),
        "Unexpected buffer contents."
      );
    }

    function testBufferResizeAppendInt() public pure {
      Buffer.buffer memory buf;
      Buffer.init(buf, 32);
      buf.append("01234567890123456789012345678901");
      buf.appendInt(0x2020, 2);
      require(buf.capacity == 96, "Expected buffer capacity to be 96");
      require(buf.buf.length ==  34, "Expected buffer length to be 34");
      require(
        keccak256(abi.encodePacked(string(buf.buf))) == keccak256(abi.encodePacked("01234567890123456789012345678901  ")),
        "Unexpected buffer contents."
      );
    }
}

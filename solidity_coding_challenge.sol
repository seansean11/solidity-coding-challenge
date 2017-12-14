pragma solidity ^0.4.9;

// This document is part of the Lunyr coding challenge. If you would like to participate
// please email support át lunyr döt cōm with a description of any bugs you find in this contract
// including what the function should do, what it actually does, what are the consequences
// of the bug (how to abuse it), and how to fix it. Happy Hacking
// RTFM: https://solidity.readthedocs.io/en/develop/

// (ʘ‿ʘ)(ʘ‿ʘ)(ʘ‿ʘ)

// THIS CONTRACT CONTAINS BUGS - DO NOT USE
contract InsecureAndMessy {


   /// Mapping of ether shares of the contract.
   mapping(address => uint) shares;
   address owner;
   address[] shareholders;
   event FailedSend(address, uint);

   function InseceureAndMessy() {
      owner = msg.sender;
   }

   function () payable {
      shares[msg.sender] = msg.value;
   }

   function addShareholder(address shareholder) {
      require(tx.origin == owner);
      shareholders.push(shareholder);
   }

   /// Withdraw your share.
   function withdraw() {
     if (msg.sender.send(shares[msg.sender])) {
         shares[msg.sender] = 0;
      } else {
         FailedSend(msg.sender, shares[msg.sender]);
      }
   }

   function dispense() {
      require(msg.sender == owner);
      address shareholder;
      for (var i = 0; i < shareholders.length; i++) {
         shareholder = shareholders[i];
         uint sh = shares[shareholder];
         shares[shareholder] = 0;
         shareholder.send(sh);
      }
   }

}

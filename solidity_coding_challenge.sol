pragma solidity ^0.4.9;

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

# Solidity Coding Challenge

## Contract Notes
- Prefer 4 space indents (Solidity style guide)
- Prefer more explicit types ex: `uint` -> `uint256`
- Specify visibility on functions
- Added `destroy` function.  This may come in handy especially if the the contract is deployed with bugs or undesired behavior
- `FailedSend` event did not specify names for the 2 parameters that it takes.
- Added more events for successful actions and removed the `FailedSend` event.  Prefering events that are emmited for important state changes, not failures.
- Prefer `.transfer` over `.send` so that failed sends will be reverted automatically.
- Create a `Shareholder` struct in order to support the `onlyShareholder` modifier.
- Don't include whitespace between function (`function () payable`) and parenthesis (Solidity style guide)

## Functions

### `function InsecureAndMessy()` -> `function SecureAndTidy()`
Constructor function of the contract. The constructor function is optional and is only run once when the contract is created.

**Bugs:**
- Constructor spelling error `InseceureAndMessy`
  - *Consequence:* Constructor would not be invoked when contract is created.  It would leave the function exposed to malicious parties.
  - *Solution:* Rename the constructor to match the contract name.

### `function()`
Fallback function of the contract.  The contract can only have one unnamed function that does not take arguments or return anything.

**Bugs:**
- `shares[msg.sender] = msg.value` resets the value of shares on every payment
  - *Consequence:* If a shareholder sends multiple payments, the record of their payments will be reset every time instead of accumulating.
  - *Solution:* Change the operator from `=` to `+=` to make sure payments are accumulated.
- No access restriction
  - *Consequence:* Any address can send payments to this contract, even if they aren't in the `shareholders` array or `shares`mapping.
  - *Solution:* Use the `onlyShareholder` modifier to protect the function.

### `addShareholder(address _shareholder)`
Function that allows the contract owner to add and enable new address to be shareholders

**Bugs:**
- Use `msg.sender` instead of `tx.origin` for authorization
  - *Consequence:* `tx.origin` carries the original address that started the transaction. Meaning that if you're the `owner` address and you send a transaction through a malicious wallet, it would still authorize with your address.
  - *Solution:* Use `msg.sender` instead.  `msg.sender` will carry the address of the immediate sender.  In the case of a transaction being sent through a malicious wallet, it would fail authorization because the wallet contract address is not the `owner`.
- Not checking if shareholder exist before adding them.
  - *Consequence:* This could result in repeat shareholder entries and potential loss of funds.
  - *Solution:* Check if the shareholder `isAuthorized` before running the function
- Not adding the new shareholder to the `shares` mapping, but adding them to the `shareholders` array
  - *Consequence:* This could result in mismatched shareholder entries and inability for shareholders to deposit or withdraw.
  - *Solution:* Add an new item to the `shares` mapping, matching the new `shareholders` address.

### `withdraw()`
Function that allows an authorized shareholder to withdraw their funds from the contract

**Bugs:**
- This function in vulnerable to a re-entrancy attack
  - *Consequence:*  The recipient of the transfer could be a contract that calls back into this function.  This would allow the attacker to get multiple withdrawals until the gas runs out.
  - *Solution:*  Make sure the sender has sufficient funds and discount the tokens before the transfer is called.  This way, any re-entrency will fail to pull out more tokens than the shareholder has contributed.

### `dispense()`
Function that allows the contract owner to dispense all of the shares (funds) back to the shareholders.

**Bugs:**
- The for loop uses `var` type deduction, which could potentially cause an infinite loop.
  - *Consequence:* Since the type of `i` will be deduced to type uint8 on the first iteration and if `shareholders.length` is greater than 255, the loop would become infinite.  In this case, the loop would consume all of the gas and the transaction would be terminated.
  - *Solution:* Set `i` to a type of uint256
- The success and failure cases of `shareholder.send(sh);` need to be handled properly.
  - *Consequence:* Since `shares[shareholder]` always gets set to 0, failures to send will still reset the shareholders shares to 0.
  - *Solution:* Set up success and failure handling, checking to make sure the `shareAmount` is greater than 0 and that the `_shareholder.send(shareAmount)` was successful.

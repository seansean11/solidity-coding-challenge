pragma solidity ^0.4.11;

contract SecureAndTidy {
    struct ShareData {
        uint256 amount;
        bool isAuthorized;
    }
    address owner;
    address[] shareholders;
    mapping(address => ShareData) shares;

    event SharesAdded(address shareholder, uint256 amountAdded);
    event ShareholderAdded(address newShareholder);
    event SharesWithdrawn(address shareholder, uint256 amountWithdrawn);
    event SharesDispensed(address shareholder, uint256 amountDispensed);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyShareholder() {
        require(shares[msg.sender].isAuthorized);
        _;
    }

    function SecureAndTidy() public {
        owner = msg.sender;
    }

    function() payable onlyShareholder public {
        shares[msg.sender].amount += msg.value;
        SharesAdded(msg.sender, msg.value);
    }

    function addShareholder(address _shareholder) onlyOwner public {
        require(!shares[_shareholder].isAuthorized);

        shares[_shareholder].amount = 0;
        shares[_shareholder].isAuthorized = true;
        shareholders.push(_shareholder);

        ShareholderAdded(_shareholder);
    }

    function withdraw() onlyShareholder public {
        uint _amount = shares[msg.sender].amount;

        require(_amount > 0);
        shares[msg.sender].amount = 0;

        msg.sender.transfer(_amount);
        SharesWithdrawn(msg.sender, _amount);
    }

    function dispense() onlyOwner public {
        address _shareholder;
        uint256 _shareAmount;

        for (uint256 i = 0; i < shareholders.length; i++) {
            _shareholder = shareholders[i];
            _shareAmount = shares[_shareholder].amount;

            require(_shareAmount > 0);
            shares[_shareholder].amount = 0;

            _shareholder.transfer(_shareAmount);
            SharesDispensed(msg.sender, _shareAmount);
        }
    }

    function destroy() onlyOwner public {
        selfdestruct(owner);
    }
}

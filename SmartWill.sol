// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract SmartWill {
    address public addressSpouse;
    address public addressElderChild;
    address public addressYoungerChild;
    bool public isGrantorAlive;
    bool public isSpouseAlive;
    uint256 public grantorBalance;
    uint256 public spouseBalance;
    uint256 public elderChildBalance;
    uint256 public youngerChildBalance;
}

constructor (address _addressSpouse, address _addressElderChild, address _addressYoungerChild) payable {
    addressSpouse = _addressSpouse;
    addressElderChild = _addressElderChild;
    addressYoungerChild = _addressYoungerChild;
    isGrantorAlive = true;
    isSpouseAlive = true;
    grantorBalance = address(this).balance;
    spouseBalance = elderChildBalance = youngerChildBalance = 0;
}

function handleLifeEvent(bool _isGrantorAlive, bool _isSpouseAlive) external {
    isGrantorAlive = _isGrantorAlive;
    isSpouseAlive = _isSpouseAlive;
}

function distribute() external {
    if (isGrantorAlive) {
        return;
    }
    if (isSpouseAlive) {
        payable(addressSpouse).transfer(grantorBalance);
        grantorBalance = 0;
        spouseBalance = addressSpouse.balance;
        return;
    }
    payable(addressElderChild).transfer(grantorBalance / 2);
    payable(addressYoungerChild).transfer(grantorBalance / 2);
    grantorBalance = 0;
    elderChildBalance = addressElderChild.balance;
    youngerChildBalance = addressYoungerChild.balance;
}

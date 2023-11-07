// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";


contract RealEstateContract {
    //Aqui define-se todas as entidades do contrato
    address public seller; // Vendedor
    address public buyer; //Comprador
    uint public purchasePrice; // Preço do imóvel
    uint public closingDate; // Data de fechamento
    bool public propertyInspected; // Se o contrato foi inspecionado ou não
    bool public titleCleared;
    
    // Aqui define-se os estados (ou estágios) do contrato
    enum ContractState { Created, Inspected, TitleCleared, Completed }
    ContractState public state = ContractState.Created;

    modifier onlySeller() {
        require(msg.sender == seller, "Only the seller can call this function");
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only the buyer can call this function");
        _;
    }

    constructor(address _buyer, address _seller, uint _purchasePrice, uint _closingDate) {
        seller = _seller;
        buyer = _buyer;
        purchasePrice = _purchasePrice;
        closingDate = _closingDate;
    }

    function requestInspection() public onlyBuyer {
        require(state == ContractState.Created, "Inspection already requested.");
        state = ContractState.Inspected;
    }

    function completeInspection(bool _propertyInspected) public onlySeller {
        require(state == ContractState.Inspected, "Inspection must be requested first.");
        propertyInspected = _propertyInspected;
        if (propertyInspected) {
            state = ContractState.TitleCleared;
        } else {
            state = ContractState.Completed;
        }
    }

    function clearTitle() public onlySeller {
        require(state == ContractState.TitleCleared, "Title can only be cleared after inspection.");
        titleCleared = true;
        state = ContractState.Completed;
    }

    function transferOwnership() public onlySeller {
        require(state == ContractState.Completed, "Transaction must be completed.");
        seller = buyer;
        buyer = address(0);
        state = ContractState.Created;
    }
}

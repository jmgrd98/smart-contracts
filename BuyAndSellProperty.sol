// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";


contract RealEstateContract {
    //Aqui define-se todas as entidades do contrato
    address public seller; // O endereço da carteira do vendedor
    address public buyer; //O endereço da carteira do comprador
    uint public purchasePrice; // Preço do imóvel
    uint public closingDate; // Data de fechamento
    bool public propertyInspected; // Se o contrato foi inspecionado ou não
    bool public titleCleared;
    
    // Aqui define-se os estados (ou estágios) do contrato
    enum ContractState { Created, OnInspection, Inspected, TitleCleared, Completed }
    ContractState public state = ContractState.Created;

    modifier onlySeller() {
        require(msg.sender == seller, "Only the seller can call this function");
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only the buyer can call this function");
        _;
    }

    constructor(address _buyer, uint _purchasePrice, uint _closingDate) {
        seller = msg.sender;
        buyer = _buyer;
        purchasePrice = _purchasePrice;
        closingDate = _closingDate;
    }

    // Função de requerer vistoria, apenas o comprador pode chamar essa função.
    function requestInspection() public onlyBuyer {
        require(state == ContractState.Created, "Inspection already requested."); // Só irá acontecer caso o contrato estiver criado.
        state = ContractState.OnInspection; // Muda o estado do contrato para inspecionado.
    }

    // Função de completar vistoria, apenas o vendedor pode chamar essa função.
    function completeInspection(bool _propertyInspected) public onlySeller {
        require(state == ContractState.OnInspection, "Inspection must be requested first."); // Só irá acontecer caso a vistoria já tiver sido requisitada pelo comprador.
        propertyInspected = _propertyInspected;
        if (propertyInspected) {
            state = ContractState.TitleCleared;
        } else {
            state = ContractState.Completed;
        }
    }

    // Limpar título do vendedor do imóvel, apenas o comprador pode chamar essa função.
    function clearTitle() public onlySeller {
        require(state == ContractState.TitleCleared, "Title can only be cleared after inspection.");
        titleCleared = true;
        state = ContractState.Completed;
    }

    // Função de transferência de posse para o comprador, apensar o vendedor pode chamar essa função.
    function transferOwnership() public onlySeller {
        require(state == ContractState.Completed, "Transaction must be completed."); // Só irá acontecer se o contrato estiver Completado
        seller = buyer; // Define o comprador agora como vendedor do imóvel.
        buyer = address(0); // Define o antigo como comprador como ninguém.
        state = ContractState.Created; // Muda o estado do contrato para criado novamente.
    }
}

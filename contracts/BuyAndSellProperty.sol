// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC20.sol";


contract RealEstateContract {
    //Aqui define-se todas as entidades do contrato
    IERC20 public usdtToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // A criptomoeda em que serão feitas as transações, nesse caso USDT (dólar).
    address public seller; // O endereço da carteira do vendedor.
    address public buyer; //O endereço da carteira do comprador.
    uint public purchasePrice; // Preço do imóvel.
    uint public downPaymentDate // Data de quando será debitado o valor de entrada do imóvel.
    uint public closingDate; // Data de fechamento, quando será debitado o valor restante do imóvel.
    bool public propertyInspected; // Se o contrato foi inspecionado ou não
    bool public titleCleared;
    
    // Aqui define-se os estados (ou estágios) do contrato
    enum ContractState { Created, OnInspection, Inspected, TitleCleared, Completed }
    ContractState public state = ContractState.Created;

    event InspectionRequested();
    event InspectionCompleted(bool propertyInspected);
    event TitleCleared();
    event OwnershipTransferred();

    modifier onlySeller() {
        require(msg.sender == seller, "Only the seller can call this function");
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only the buyer can call this function");
        _;
    }

    // Essa função acontece assim que o contrato é colocado no ar (ou seja, na blockchain)
    constructor(address _buyer, uint _purchasePrice, uint _closingDate) {
        seller = msg.sender; // O vendedor será quem está colocando o contrato no ar.
        buyer = _buyer; // O comprador será definido na hora de colocar o contrato no ar.
        purchasePrice = _purchasePrice; // O preço da compra será definida na hora de colocar o contrato no ar.
        downPaymentDate = _downPaymentDate; // O preço do pagamento do valor de entrada será definido nesse mesmo momento.
        closingDate = _closingDate; // O preço do pagamento final será definido nesse mesmo momento.
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

    // Função de pagamento de entrada, apenas o comprador pode acionar essa função.
    function makeDownPayment(uint amount) public onlyBuyer {
        amount = purchasePrice / 2; // Aqui define-se o valor do pagamento de entrada.
        require(state == ContractState.OnInspection, "Down payment can only be made during the inspection phase."); // Só pode acontecer se o contrato estiver em vistoria.
        require(block.timestamp < propertyDocumentsPresentationDate, "Down payment period has ended."); // Só pode acontecer até a data definida no começo do contrato entre as partes;
        require(usdtToken.transferFrom(buyer, seller, amount), "Down payment transfer failed"); // Efetivar a transferência em USDT da carteira do comprador para a carteira do vendedor.

    // Função de pagamento final, apenas o comprador pode acionar essa função.
    function makeFinalPayment() public onlyBuyer {
        require(state == ContractState.Completed, "Final payment can only be made after the transaction is completed."); // Só pode acontecer se o contrato precisa estar em estágio final.
        require(block.timestamp < closingDate, "Closing date has passed."); // Só pode acontecer até a data final definida no começo do contrato
        require(usdtToken.transferFrom(buyer, seller, purchasePrice), "Final payment transfer failed");
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

    function cancelContract() public {
    require(state != ContractState.Completed, "Contract cannot be canceled after completion.");
    
    if (msg.sender == seller) {
        // Seller can cancel the contract at any time before completion.
        state = ContractState.Completed;
    } else if (msg.sender == buyer) {
        // Buyer can cancel the contract before making the final payment.
        require(state != ContractState.TitleCleared, "Buyer cannot cancel after title is cleared.");
        state = ContractState.Completed;
    }
    uint refundAmount = purchasePrice / 2; // Devolvendo o dinheiro do comprador
    require(usdtToken.transferFrom(seller, buyer, refundAmount), "Refund transfer failed");
}
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {Proof} from "./IZKToken.sol";

interface IEscrow {
    enum ItemType {
        ERC20,
        ERC721
    }

    struct OfferItem {
        ItemType itemType;
        address token;
        uint256 amountOrIdentifier;
    }

    struct Consideration {
        address recipient;
        uint256 hashConsideration;
    }

    struct Order {
        address offerer;
        OfferItem offer;
        Consideration consideration;
    }

    struct FulfilOrderParameters {
        uint256 orderId;
        address offerRecipient;
        uint256 hashValue;
        uint256 hashSenderBalanceAfter;
        uint256 hashReceiverBalanceAfter;
        address from;
        Proof proof;
    }

    error InvalidCanceller();
    error InvalidOffer();
    error OrderIsCancelled();
    error NoContract(address);
    error OrderCreatorERC20NotEnough(address, address, uint256);
    error OrderCreatorIsNotOwner(address, address, uint256);
    error TokenTransferGenericFailure(address, address, address, uint256);

    event OrderCreated(uint256, address, Order);
    event OrderCanceled(uint256);
    event OrderFulfilled(uint256);

    function createOrder(
        OfferItem calldata _offer,
        Consideration calldata _consideration
    ) external returns (uint256);

    function cancelOrder(uint256 orderId) external;

    function fulfillOrder(FulfilOrderParameters calldata params) external;
}

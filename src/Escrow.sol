// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {IEscrow} from "./interfaces/IEscrow.sol";
import {IZKToken} from "./interfaces/IZKToken.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IERC721} from "./interfaces/IERC721.sol";

contract Escrow is IEscrow {
    uint256 public orderIndex = 1;
    mapping(uint256 => Order) public getOrder;
    IZKToken public zkToken;

    constructor(address _zkToken) {
        zkToken = IZKToken(_zkToken);
    }

    function createOrder(
        OfferItem calldata _offer,
        Consideration calldata _consideration
    ) external returns (uint256) {
        _isValidOffer(_offer);
        Order memory order = Order({
            offerer: msg.sender,
            offer: _offer,
            consideration: _consideration
        });
        getOrder[orderIndex] = order;
        emit OrderCreated(orderIndex, msg.sender, order);
        return orderIndex++;
    }

    /**
     * @dev `delete` keyword will not affect getOrder[orderId].offer
     */
    function cancelOrder(uint256 orderId) external {
        Order memory order = getOrder[orderId];
        if (order.offerer == address(0)) {
            revert OrderIsCancelled();
        }
        if (msg.sender != order.offerer) {
            revert InvalidCanceller();
        }

        delete getOrder[orderId];
        emit OrderCanceled(orderId);
    }

    function fulfillOrder(FulfilOrderParameters calldata params) external {
        Order memory order = getOrder[params.orderId];
        if (order.offerer == address(0)) {
            revert OrderIsCancelled();
        }
        _transferERC20OrERC721(
            order.offer.token,
            order.offerer,
            params.offerRecipient,
            order.offer.amountOrIdentifier
        );

        zkToken.transferFrom(
            params.hashValue,
            params.hashSenderBalanceAfter,
            params.hashReceiverBalanceAfter,
            params.from,
            order.consideration.recipient,
            params.proof
        );
    }

    function _isValidOffer(OfferItem memory offer) internal view {
        if (offer.itemType == ItemType.ERC20) {
            if (
                IERC20(offer.token).balanceOf(msg.sender) <
                offer.amountOrIdentifier
            ) {
                revert OrderCreatorERC20NotEnough(
                    offer.token,
                    msg.sender,
                    offer.amountOrIdentifier
                );
            }
        } else {
            if (
                IERC721(offer.token).ownerOf(offer.amountOrIdentifier) !=
                msg.sender
            ) {
                revert OrderCreatorIsNotOwner(
                    offer.token,
                    msg.sender,
                    offer.amountOrIdentifier
                );
            }
        }
    }

    function _transferERC20OrERC721(
        address token,
        address from,
        address to,
        uint256 amountOrIdentifier
    ) internal {
        if (token.code.length == 0) {
            revert NoContract(token);
        }

        bool success;

        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            // abi.encodeWithSignature("transferFrom(address,address,uint256)")
            mstore(
                freeMemoryPointer,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amountOrIdentifier) // Append the "amount" or "tokenId" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(
                    and(eq(mload(0), 1), gt(returndatasize(), 31)),
                    iszero(returndatasize())
                ),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        if (!success) {
            revert TokenTransferGenericFailure(
                token,
                from,
                to,
                amountOrIdentifier
            );
        }
    }
}

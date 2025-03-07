// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//import "./ISoloMargin.sol";
import "https://raw.githubusercontent.com/welcomefrank/defi-by-example/main/contracts/interfaces/dydx/ISoloMargin.sol";

contract DydxFlashloanBase {
  using SafeMath for uint;

  // -- Internal Helper functions -- //

  function _getMarketIdFromTokenAddress(address _solo, address token)
    internal
    view
    returns (uint)
  {
    ISoloMargin solo = ISoloMargin(_solo);

    uint numMarkets = solo.getNumMarkets();

    address curToken;
    for (uint i = 0; i < numMarkets; i++) {
      curToken = solo.getMarketTokenAddress(i);

      if (curToken == token) {
        return i;
      }
    }

    revert("No marketId found for provided token");
  }

  function _getRepaymentAmountInternal(uint amount) internal pure returns (uint) {
    // Needs to be overcollateralize
    // Needs to provide +2 wei to be safe
    return amount.add(2);
  }

  function _getAccountInfo() internal view returns (Account.Info memory) {
    return Account.Info({owner: address(this), number: 1});
  }

  function _getWithdrawAction(uint marketId, uint amount)
    internal
    view
    returns (Actions.ActionArgs memory)
  {
    return
      Actions.ActionArgs({
        actionType: Actions.ActionType.Withdraw,
        accountId: 0,
        amount: Types.AssetAmount({
          sign: false,
          denomination: Types.AssetDenomination.Wei,
          ref: Types.AssetReference.Delta,
          value: amount
        }),
        primaryMarketId: marketId,
        secondaryMarketId: 0,
        otherAddress: address(this),
        otherAccountId: 0,
        data: ""
      });
  }

  function _getCallAction(bytes memory data)
    internal
    view
    returns (Actions.ActionArgs memory)
  {
    return
      Actions.ActionArgs({
        actionType: Actions.ActionType.Call,
        accountId: 0,
        amount: Types.AssetAmount({
          sign: false,
          denomination: Types.AssetDenomination.Wei,
          ref: Types.AssetReference.Delta,
          value: 0
        }),
        primaryMarketId: 0,
        secondaryMarketId: 0,
        otherAddress: address(this),
        otherAccountId: 0,
        data: data
      });
  }

  function _getDepositAction(uint marketId, uint amount)
    internal
    view
    returns (Actions.ActionArgs memory)
  {
    return
      Actions.ActionArgs({
        actionType: Actions.ActionType.Deposit,
        accountId: 0,
        amount: Types.AssetAmount({
          sign: true,
          denomination: Types.AssetDenomination.Wei,
          ref: Types.AssetReference.Delta,
          value: amount
        }),
        primaryMarketId: marketId,
        secondaryMarketId: 0,
        otherAddress: address(this),
        otherAccountId: 0,
        data: ""
      });
  }
}

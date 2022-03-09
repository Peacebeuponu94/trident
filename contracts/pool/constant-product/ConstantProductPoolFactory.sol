// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import {ConstantProductPool} from "./ConstantProductPool.sol";
import {PoolDeployer} from "../../abstract/PoolDeployer.sol";

/// @notice Contract for deploying Trident exchange Constant Product Pool with configurations.
/// @author Mudit Gupta.
contract ConstantProductPoolFactory is PoolDeployer {
    constructor(address _masterDeployer) PoolDeployer(_masterDeployer) {}

    function deployPool(bytes calldata _deployData) public returns (address pool) {
        (address tokenA, address tokenB, uint256 swapFee, bool twapSupport) = abi.decode(_deployData, (address, address, uint256, bool));

        if (tokenA > tokenB) {
            (tokenA, tokenB) = (tokenB, tokenA);
        }

        // Strips any extra data.
        _deployData = abi.encode(tokenA, tokenB, swapFee, twapSupport);

        address[] memory tokens = new address[](2);
        tokens[0] = tokenA;
        tokens[1] = tokenB;

        // Salt is not actually needed since `_deployData` is part of creationCode and already contains the salt.
        bytes32 salt = keccak256(_deployData);
        pool = address(new ConstantProductPool{salt: salt}(_deployData, IMasterDeployer(masterDeployer)));
        _registerPool(pool, tokens, salt);
    }
}

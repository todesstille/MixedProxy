// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

contract MockERC20GovV2 is Initializable {

    address public govAddress;
    string public version;

    function __ERC20Gov_init(
        address _govAddress,
        string calldata v
    ) external initializer {
        govAddress = _govAddress;
        version = v;
    }

    function itWorks() pure external returns (bool) {
        return true;
    }

    function itWorks2() pure external returns (bool) {
        return true;
    }
}

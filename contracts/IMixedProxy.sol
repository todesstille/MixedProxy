// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IMixedProxy {
    function admin() external view returns (address);

    function isBeaconProxy() external view returns (bool);

    function implementation() external view returns (address);

    function upgradeTo(address) external;

    function upgradeToAndCall(address, bytes memory) external payable;
}

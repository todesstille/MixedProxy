// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./IMixedProxy.sol";
import "./IERC20Gov.sol";

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract ProxyERC20Gov is BeaconProxy {

    constructor(address beacon, bytes memory data) payable BeaconProxy(beacon, data) {}

    function _implementation() internal view virtual override returns (address) {
        if (_isBeaconProxy()) {
            return IBeacon(_getBeacon()).implementation();
        } else {
            return _getImplementation();
        }
    }

    function _isBeaconProxy() internal view returns (bool) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value == address(0);
    }

    function _getAdminFromImplementation() internal view returns (address) {
        return IERC20Gov(address(this)).govAddress();
    }

    function _fallback() internal virtual override {
        bytes memory ret;
        bytes4 selector = msg.sig;
        if (selector == IMixedProxy.upgradeTo.selector) {
            _onlyAdmin();
            ret = _dispatchUpgradeTo();
            assembly {
                return(add(ret, 0x20), mload(ret))
            }
        } else if (selector == IMixedProxy.upgradeToAndCall.selector) {
            _onlyAdmin();
            ret = _dispatchUpgradeToAndCall();
            assembly {
                return(add(ret, 0x20), mload(ret))
            }
        } else if (selector == IMixedProxy.admin.selector) {
            ret = _dispatchAdmin();
            assembly {
                return(add(ret, 0x20), mload(ret))
            }
        } else if (selector == IMixedProxy.implementation.selector) {
            ret = _dispatchImplementation();
            assembly {
                return(add(ret, 0x20), mload(ret))
            }
        } else {
            super._fallback();
        }
    }

    function _dispatchAdmin() private returns (bytes memory) {
        _requireZeroValue();

        address admin = _getAdminFromImplementation();
        return abi.encode(admin);
    }

    function _dispatchImplementation() private returns (bytes memory) {
        _requireZeroValue();

        address implementation = _implementation();
        return abi.encode(implementation);
    }

    function _dispatchUpgradeTo() private returns (bytes memory) {
        _requireZeroValue();

        address newImplementation = abi.decode(msg.data[4:], (address));
        _upgradeToAndCall(newImplementation, bytes(""), false);

        return "";
    }

    function _dispatchUpgradeToAndCall() private returns (bytes memory) {
        (address newImplementation, bytes memory data) = abi.decode(msg.data[4:], (address, bytes));
        _upgradeToAndCall(newImplementation, data, true);

        return "";
    }


    function _requireZeroValue() private {
        require(msg.value == 0);
    }

    function _onlyAdmin() internal view {
        require(msg.sender == _getAdminFromImplementation(), "ProxyERC20Gov: caller is not the admin");
    }
}

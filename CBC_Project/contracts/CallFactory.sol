// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Call.sol";

contract CallFactory {
    mapping(address => address[]) public userCalls;
    event CallCreated(address indexed call, address indexed user1, address indexed user2);
    
    function createCall(address _user1, address _user2) external returns (address) {
        Call newCall = new Call(_user1, _user2);
        userCalls[_user1].push(address(newCall));
        userCalls[_user2].push(address(newCall));
        emit CallCreated(address(newCall), _user1, _user2);
        return address(newCall);
    }
    
    function getUserCalls(address user) external view returns (address[] memory) {
        return userCalls[user];
    }
}
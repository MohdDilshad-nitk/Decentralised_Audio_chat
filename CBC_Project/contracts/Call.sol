// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Call {
    address public user1;
    address public user2;
    string[] public user1Messages;
    string[] public user2Messages;
    uint256 public user1ListenedIndex;
    uint256 public user2ListenedIndex;
    
    event NewMessage(address indexed sender, string contentId, uint256 messageIndex);
    event MessageListened(address indexed listener, uint256 messageIndex);
    
    constructor(address _user1, address _user2) {
        user1 = _user1;
        user2 = _user2;
    }
    
    modifier onlyParticipants(address sender) {
        require(sender == user1 || sender == user2, "Only call participants can send messages");
        _;
    }

    //write a function to return the last element from userMessages, if user1 is calling the function then return the last element of user2Messages and vice versa
    function getLastMessage(address user) external view returns (string memory) {
        require(user == user1 || user == user2, "Invalid user");
        return user == user1 ? user2Messages[user2Messages.length - 1] : user1Messages[user1Messages.length - 1];
    }
    
    function sendMessage(address sender, string memory contentId) external onlyParticipants(sender) {
        if (sender == user1) {
            user1Messages.push(contentId);
            emit NewMessage(user1, contentId, user1Messages.length - 1);
        } else {
            user2Messages.push(contentId);
            emit NewMessage(user2, contentId, user2Messages.length - 1);
        }
    }
    
    function markMessageAsListened(address listener, uint256 index) external onlyParticipants(listener) {
        if (listener == user1) {
            require(index < user2Messages.length, "Invalid message index");
            require(index == user1ListenedIndex, "Must listen to messages in order");
            user1ListenedIndex = index + 1;
        } else {
            require(index < user1Messages.length, "Invalid message index");
            require(index == user2ListenedIndex, "Must listen to messages in order");
            user2ListenedIndex = index + 1;
        }
        emit MessageListened(listener, index);
    }
    
    function getMessages(address user) external view returns (string[] memory) {
        require(user == user1 || user == user2, "Invalid user");
        return user == user1 ? user1Messages : user2Messages;
    }
    
    function getListenedIndex(address user) external view returns (uint256) {
        require(user == user1 || user == user2, "Invalid user");
        return user == user1 ? user1ListenedIndex : user2ListenedIndex;
    }
}

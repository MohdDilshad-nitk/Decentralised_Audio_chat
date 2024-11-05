const CallFactory = artifacts.require("CallFactory");
const Call = artifacts.require("Call");

contract("CallFactory", (accounts) => {
    let callFactory;
    const user1 = accounts[1];
    const user2 = accounts[2];

    before(async () => {
        callFactory = await CallFactory.deployed();
    });

    it("should create a new call", async () => {
        const tx = await callFactory.createCall(user1, user2);
        const event = tx.logs.find(log => log.event === 'CallCreated');
        
        assert.exists(event, 'CallCreated event should be emitted');
        assert.equal(event.args.user1, user1, 'User1 should match');
        assert.equal(event.args.user2, user2, 'User2 should match');
    });

    it("should track user calls", async () => {
        await callFactory.createCall(user1, user2);
        const user1Calls = await callFactory.getUserCalls(user1);
        const user2Calls = await callFactory.getUserCalls(user2);

        assert.isTrue(user1Calls.length > 0, 'User1 should have calls');
        assert.isTrue(user2Calls.length > 0, 'User2 should have calls');
    });

    it("should allow sending messages", async () => {
        const tx = await callFactory.createCall(user1, user2);
        const event = tx.logs.find(log => log.event === 'CallCreated');
        const callAddress = event.args.call;
        
        const call = await Call.at(callAddress);
        
        // Send message from user1
        const contentId = "QmTest123";
        await call.sendMessage(user1, contentId);
        
        // Check if message was stored
        const user2Messages = await call.getMessages(user2);
        assert.equal(user2Messages[0], contentId, 'Message should be stored');
    });

    it("should track message listening status", async () => {
        const tx = await callFactory.createCall(user1, user2);
        const callAddress = tx.logs[0].args.call;
        const call = await Call.at(callAddress);
        
        // Send message from user1
        await call.sendMessage(user1, "QmTest123");
        
        // Mark message as listened
        await call.markMessageAsListened(user2, 0);
        
        // Check listened index
        const listenedIndex = await call.getListenedIndex(user2);
        assert.equal(listenedIndex.toNumber(), 1, 'Listened index should be updated');
    });

    it("should fail when non-participant tries to send message", async () => {
        const tx = await callFactory.createCall(user1, user2);
        const callAddress = tx.logs[0].args.call;
        const call = await Call.at(callAddress);
        
        try {
            await call.sendMessage(accounts[3], "QmTest123");
            assert.fail('Should have thrown an error');
        } catch (error) {
            assert.include(error.message, 'Only call participants can send messages');
        }
    });
});
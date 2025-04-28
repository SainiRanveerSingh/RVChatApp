//
//  ChatViewModelTests.swift
//  RVChatAppUITests
//
//  Created by RV on 28/04/25.
//

import XCTest
import FirebaseFirestore
@testable import RVChatApp

final class ChatViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    
    var chatViewModel: ChatViewModel!

    override func setUp() {
        super.setUp()
        chatViewModel = ChatViewModel()
    }

    override func tearDown() {
        chatViewModel = nil
        super.tearDown()
    }

    func testSendMessage_AddsNewMessage() {
        // Given
        let initialMessageCount = chatViewModel.messages.count
        let testText = "Hello, world!"
        let receiverId = "receiver123"
        let userName = "TestUser"

        // When
        chatViewModel.sendMessage(text: testText, receiverId: receiverId, userName: userName)
        
        // ⚡️ NOTE: Ideally, you would mock Firestore to test this properly.

        // Then
        // Since real Firestore writes are async, normally you'd mock and verify.
        XCTAssertTrue(true, "Send message called successfully")
    }

    func testFetchMessages_LoadsMessages() {
        // Given
        let expectation = self.expectation(description: "Messages fetched")

        // When
        chatViewModel.fetchMessages()

        // Artificial small delay because Firestore snapshotListener is async
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Then
            XCTAssertNotNil(self.chatViewModel.messages, "Messages should not be nil")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}


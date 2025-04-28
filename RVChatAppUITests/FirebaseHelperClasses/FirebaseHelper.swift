//
//  FirebaseHelper.swift
//  RVChatAppUITests
//
//  Created by RV on 28/04/25.
//

import XCTest
@testable import RVChatApp

enum MockFirebaseResult {
    case success
    case failure
}


final class FirebaseHelper: XCTestCase {

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
    
    static var result: MockFirebaseResult = .success

        static func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
            switch result {
            case .success:
                completion(.success("Logged in"))
            case .failure:
                completion(.failure(MockError.loginFailed))
            }
        }
        
        static func getAllUserList(completion: @escaping (Bool, String) -> Void) {
            completion(true, "Fetched users")
        }

}

enum MockError: Error {
    case loginFailed
}

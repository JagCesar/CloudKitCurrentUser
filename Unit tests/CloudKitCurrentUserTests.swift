//
//  CloudKitCurrentUserTests.swift
//  CloudKitCurrentUserTests
//
//  Created by Cesar Pinto Castillo on 2016-12-02.
//  Copyright © 2016 JagCesar. All rights reserved.
//

import XCTest
@testable import CloudKitCurrentUser

extension CurrentUserStatus {
    static let allKeys: [CurrentUserStatus] = [.SignedIn, Restricted, Anonymous, NotDetermined]
}

struct TestError: Error {

}

class TestableCurrentUserRequest: CurrentUserRequestProtocol {
    var status: CurrentUserStatus = .NotDetermined
    var userIdentifier: String?
    var error: Error?

    func currentStatus(completionBlock: @escaping StatusCompletionBlock) {
        completionBlock(status, error)
    }

    func userIdentifier(completionBlock: @escaping UserIdentifierCompletionBlock) {
        completionBlock(userIdentifier, error)
    }

    func statusChangedNotification() -> Notification.Name {
        return Notification.Name.init("Notification")
    }
}

class CloudKitCurrentUserTests: XCTestCase {

    lazy var testableCurrentUser: CurrentUser = {
        let testableCurrentUser = CurrentUser.sharedInstance
        testableCurrentUser.userRequestObject = self.testableCurrentUserRequest
        return testableCurrentUser
    }()

    let testableCurrentUserRequest = TestableCurrentUserRequest()

    func testNotificationName() {
        XCTAssertEqual(CurrentUser.statusChangedNotification.rawValue, "CurrentUserStatusChanged")
    }

    func testCurrentStatus() {
        CurrentUserStatus.allKeys.forEach { currentStatus in
            testableCurrentUserRequest.status = currentStatus
            testableCurrentUserRequest.error = nil
            testableCurrentUser.statusChanged() // Reset the current user
            let testExpectation = expectation(description: "Load current status")
            testableCurrentUser.currentStatus { status, error in
                XCTAssertEqual(status, currentStatus)
                XCTAssertNil(error)
                testExpectation.fulfill()
            }
            waitForExpectations(timeout: 5, handler: nil)
        }

        let customError: TestError = TestError()

        testableCurrentUserRequest.status = .NotDetermined
        testableCurrentUserRequest.error = customError
        let testExpectation = expectation(description: "Load current status")
        testableCurrentUser.currentStatus { status, error in
            XCTAssertEqual(status, .NotDetermined)
            XCTAssertNotNil(error)
            testExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testUserIdentifier() {
        let customError = TestError()
        let customIdentifier = "El identifier string"

        userIdentifierTest(testIdentifier: nil, testError: nil)
        userIdentifierTest(testIdentifier: customIdentifier, testError: nil)
        userIdentifierTest(testIdentifier: customIdentifier, testError: customError)
        userIdentifierTest(testIdentifier: nil, testError: customError)
    }

    func userIdentifierTest(testIdentifier: String?, testError: Error?) {
        testableCurrentUser.statusChanged() // Reset the current user

        testableCurrentUserRequest.userIdentifier = testIdentifier
        testableCurrentUserRequest.error = testError
        let testExpectation = expectation(description: "Load current user")
        testableCurrentUser.userIdentifier { identifier, error in
            XCTAssertEqual(identifier, testIdentifier)
            if let _ = testError {
                XCTAssertNotNil(error)
            } else {
                XCTAssertNil(error)
            }
            testExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testStatusChanged() {
        let testExpectation = expectation(description: "User changed notification")
        var token: NSObjectProtocol?
        token = NotificationCenter.default.addObserver(forName: CurrentUser.statusChangedNotification,
                                               object: nil,
                                               queue: nil) { notification in
                                                NotificationCenter.default.removeObserver(token!)
                                                testExpectation.fulfill()
        }
        testableCurrentUser.statusChanged()
        waitForExpectations(timeout: 5, handler: nil)
    }
}

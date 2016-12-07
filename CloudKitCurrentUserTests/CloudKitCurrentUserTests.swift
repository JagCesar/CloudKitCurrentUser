//
//  CloudKitCurrentUserTests.swift
//  CloudKitCurrentUserTests
//
//  Created by Cesar Pinto Castillo on 2016-12-02.
//  Copyright © 2016 JagCesar. All rights reserved.
//

import XCTest
@testable import CloudKitCurrentUser

class CloudKitCurrentUserTests: XCTestCase {

    func testInit() {
        XCTAssertNotNil(CurrentUser.sharedInstance)
    }

    func testNotificationName() {
        XCTAssertEqual(CurrentUser.statusChangedNotification.rawValue, "CurrentUserStatusChanged")
    }

    // I would love to add more Unit tests here, but since we can't enable CloudKit for the
    // CloudKitCurrentUser target, we can't test any of the other public functions. Any ideas
    // on how to solve this are welcome!
}

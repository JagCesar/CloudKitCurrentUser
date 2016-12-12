//
//  CloudKitCurrentUserRequest.swift
//  CloudKitCurrentUser
//
//  Created by Cesar Pinto Castillo on 2016-12-09.
//  Copyright © 2016 JagCesar. All rights reserved.
//

import CloudKit

internal class CloudKitCurrentUserRequest: CurrentUserRequestProtocol {
    func currentStatus(completionBlock: @escaping StatusCompletionBlock) {
        CKContainer.default().accountStatus { accountStatus, error in
            switch accountStatus {
            case .couldNotDetermine:
                completionBlock(.NotDetermined, error)
            case .available:
                completionBlock(.SignedIn, error)
            case .restricted:
                completionBlock(.Restricted, error)
            case .noAccount:
                completionBlock(.Anonymous, error)
            }
        }
    }

    func userIdentifier(completionBlock: @escaping UserIdentifierCompletionBlock) {
        CKContainer.default().fetchUserRecordID { recordID, error in
            completionBlock(recordID?.recordName, error)
        }
    }

    func statusChangedNotification() -> NSNotification.Name {
        return NSNotification.Name.CKAccountChanged
    }
}

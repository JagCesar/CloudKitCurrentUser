//
//  CurrentUserRequestProtocol.swift
//  CloudKitCurrentUser
//
//  Created by Cesar Pinto Castillo on 2016-12-09.
//  Copyright © 2016 JagCesar. All rights reserved.
//

import Foundation

public enum CurrentUserStatus {
    case SignedIn
    case Restricted
    case Anonymous
    case NotDetermined
}

public typealias StatusCompletionBlock = (_ status: CurrentUserStatus, _ error: Error?) -> Swift.Void
public typealias UserIdentifierCompletionBlock = (_ userIdentifier: String?, _ error: Error?) -> Swift.Void

internal protocol CurrentUserRequestProtocol: class {
    func currentStatus(completionBlock: @escaping StatusCompletionBlock)
    func userIdentifier(completionBlock: @escaping UserIdentifierCompletionBlock)

    func statusChangedNotification() -> NSNotification.Name
}

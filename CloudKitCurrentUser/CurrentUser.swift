//
//  CurrentUser.swift
//  CloudKitCurrentUser
//
//  Created by Cesar Pinto Castillo on 2016-12-02.
//  Copyright © 2016 JagCesar. All rights reserved.
//

import Foundation

public class CurrentUser {
    public static let sharedInstance = CurrentUser()
    public static let statusChangedNotification: NSNotification.Name = NSNotification.Name("CurrentUserStatusChanged")

    private var status: CurrentUserStatus = .NotDetermined
    private var isLoadingStatus: Bool = false
    private var statusCompletionBlocks: [StatusCompletionBlock] = []

    private var userIdentifier: String?
    private var isLoadingUserIdentifier: Bool = false
    private var userIdentifierCompletionBlocks: [UserIdentifierCompletionBlock] = []
    var userRequestObject: CurrentUserRequestProtocol = CloudKitCurrentUserRequest()

    private init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CurrentUser.statusChanged),
                                               name: NSNotification.Name.CKAccountChanged,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func currentStatus(forcedReload: Bool = false, completionBlock: @escaping StatusCompletionBlock) {
        guard forcedReload || status == .NotDetermined else {
            DispatchQueue.main.async {
                completionBlock(self.status, nil)
            }
            return
        }
        statusCompletionBlocks.append(completionBlock)
        guard !isLoadingStatus || forcedReload else { return }
        isLoadingStatus = true

        userRequestObject.currentStatus { accountStatus, error in
            self.status = accountStatus

            self.isLoadingStatus = false

            for completionBlock in self.statusCompletionBlocks {
                DispatchQueue.main.async {
                    completionBlock(self.status, error)
                }
            }
            self.statusCompletionBlocks.removeAll()
        }
    }

    public func userIdentifier(completionBlock: @escaping UserIdentifierCompletionBlock) {
        if let userIdentifier = userIdentifier {
            completionBlock(userIdentifier, nil)
            return
        }
        userIdentifierCompletionBlocks.append(completionBlock)
        guard !isLoadingUserIdentifier else { return }
        isLoadingUserIdentifier = true

        userRequestObject.userIdentifier { identifier, error in
            self.userIdentifier = identifier
            self.isLoadingUserIdentifier = false
            for completionBlock in self.userIdentifierCompletionBlocks {
                DispatchQueue.main.async {
                    completionBlock(self.userIdentifier, error)
                }
            }
            self.userIdentifierCompletionBlocks.removeAll()
        }
    }

    @objc func statusChanged() {
        userIdentifier = nil
        status = .NotDetermined
        currentStatus(forcedReload: true) { _ in

        }
        NotificationCenter.default.post(name: CurrentUser.statusChangedNotification, object: nil)
    }
}

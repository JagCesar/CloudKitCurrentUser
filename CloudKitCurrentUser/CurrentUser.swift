//
//  CurrentUser.swift
//  CloudKitCurrentUser
//
//  Created by Cesar Pinto Castillo on 2016-12-02.
//  Copyright © 2016 JagCesar. All rights reserved.
//

import CloudKit

public enum CurrentUserStatus {
    case SignedIn
    case Restricted
    case Anonymous
    case NotDetermined
}

public typealias StatusCompletionBlock = (_ status: CurrentUserStatus) -> Swift.Void

public class CurrentUser {
    public static let sharedInstance = CurrentUser()
    public static let statusChangedNotification: NSNotification.Name = NSNotification.Name("CurrentUserStatusChanged")
    private var status: CurrentUserStatus = .NotDetermined
    private var isLoading: Bool = false
    private var statusCompletionBlocks: [StatusCompletionBlock] = []

    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CurrentUser.statusChanged),
                                               name: NSNotification.Name.CKAccountChanged,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func currentStatus(forcedReload: Bool = false, completionBlock: @escaping StatusCompletionBlock) {
        if forcedReload || status == .NotDetermined {
            statusCompletionBlocks.append(completionBlock)
            guard !isLoading || forcedReload else {
                return
            }
            isLoading = true
            CKContainer.default().accountStatus { accountStatus, error in
                switch accountStatus.rawValue {
                case 0:
                    self.status = CurrentUserStatus.NotDetermined
                case 1:
                    self.status = CurrentUserStatus.SignedIn
                case 2:
                    self.status = CurrentUserStatus.Restricted
                case 3:
                    self.status = CurrentUserStatus.Anonymous
                default:
                    break
                }

                self.isLoading = false

                for completionBlock in self.statusCompletionBlocks {
                    DispatchQueue.main.async {
                        completionBlock(self.status)
                    }
                }
                self.statusCompletionBlocks.removeAll()
            }
        } else {
            DispatchQueue.main.async {
                completionBlock(self.status)
            }
        }
    }

    @objc func statusChanged() {
        currentStatus(forcedReload: true) { status in
            NotificationCenter.default.post(name: CurrentUser.statusChangedNotification, object: nil)
        }
    }
}

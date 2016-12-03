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
public typealias UserIdentifierCompletionBlock = (_ userIdentifier: String?, _ error: Error?) -> Swift.Void

public class CurrentUser {
    public static let sharedInstance = CurrentUser()
    public static let statusChangedNotification: NSNotification.Name = NSNotification.Name("CurrentUserStatusChanged")

    private var status: CurrentUserStatus = .NotDetermined
    private var isLoadingStatus: Bool = false
    private var statusCompletionBlocks: [StatusCompletionBlock] = []

    private var userIdentifier: String?
    private var isLoadingUserIdentifier: Bool = false
    private var userIdentifierCompletionBlocks: [UserIdentifierCompletionBlock] = []


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
            guard !isLoadingStatus || forcedReload else {
                return
            }
            isLoadingStatus = true
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

                self.isLoadingStatus = false

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

    public func userIdentifier(completionBlock: @escaping UserIdentifierCompletionBlock) {
        if let userIdentifier = userIdentifier {
            completionBlock(userIdentifier, nil)
        } else {
            userIdentifierCompletionBlocks.append(completionBlock)
            guard !isLoadingUserIdentifier else {
                return
            }
            isLoadingUserIdentifier = true
            CKContainer.default().fetchUserRecordID { recordID, error in
                self.userIdentifier = recordID?.recordName
                self.isLoadingUserIdentifier = false
                for completionBlock in self.userIdentifierCompletionBlocks {
                    DispatchQueue.main.async {
                        completionBlock(self.userIdentifier, error)
                    }
                }
                self.userIdentifierCompletionBlocks.removeAll()
            }
        }
    }

    @objc func statusChanged() {
        userIdentifier = nil
        currentStatus(forcedReload: true) { status in
            NotificationCenter.default.post(name: CurrentUser.statusChangedNotification, object: nil)
        }
    }
}

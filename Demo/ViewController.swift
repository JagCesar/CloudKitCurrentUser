//
//  ViewController.swift
//  Demo
//
//  Created by Cesar Pinto Castillo on 2016-12-02.
//  Copyright © 2016 JagCesar. All rights reserved.
//

import UIKit
import CloudKitCurrentUser

class ViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.getUserStatus),
                                               name: CurrentUser.statusChangedNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        getUserStatus()
    }

    @IBAction func forceReloadUserStatus() {
        logStatusChange(string: "Force reload of user")
        CurrentUser.sharedInstance.currentStatus(forcedReload: true) { status in
            self.logStatusChange(status: status)
        }
    }

    @IBAction func logUserIdentifier() {
        logStatusChange(string: "Log user identifier")
            CurrentUser.sharedInstance.userIdentifier { userIdentifier, error in
                if let userIdentifier = userIdentifier {
                    self.logStatusChange(string: "User identifier: \(userIdentifier)")
                } else {
                    self.logStatusChange(string: "Unable to get user identifier")
                }
        }
    }

    @objc private func getUserStatus() {
        CurrentUser.sharedInstance.currentStatus { status in
            self.logStatusChange(status: status)
        }
    }

    private func logStatusChange(status: CurrentUserStatus? = nil, string: String? = nil) {
        if let status = status {
            switch status {
            case .Anonymous:
                textView.text = textView.text + "\nStatus: Anonymous"
            case .NotDetermined:
                textView.text = textView.text + "\nStatus: Not Determined"
            case .Restricted:
                textView.text = textView.text + "\nStatus: Restricted"
            case .SignedIn:
                textView.text = textView.text + "\nStatus: Signed in"
            }
        }
        if let string = string {
            textView.text = textView.text + "\nString: \(string)"
        }
    }
}


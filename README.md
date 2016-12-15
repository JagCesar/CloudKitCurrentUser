# CloudKitCurrentUser

[![Build Status](https://travis-ci.org/JagCesar/CloudKitCurrentUser.svg?branch=master)](https://travis-ci.org/JagCesar/CloudKitCurrentUser)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CloudKitCurrentUser](https://img.shields.io/badge/platform-iOS-lightgrey.svg?style=flat)](https://github.com/JagCesar/CloudKitCurrentUser)
[![License](https://img.shields.io/badge/license-MIT-AA8DF8.svg?style=flat)](https://github.com/JagCesar/CloudKitCurrentUser/blob/master/LICENSE)
[![Language](https://img.shields.io/badge/language-Swift%203-E05C43.svg?style=flat)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@JagCesar-00ACED.svg?style=flat)](http://twitter.com/JagCesar)

## Purpose

CloudKitCurrentUser is a wrapper around CloudKit that helps out to keep track of the current user signed in state.

## Features

- [x] Asyncronous loading of signed in state
- [x] Automatic refresh of signed in state
- [x] Caching of signed in state
- [x] Notification when the user signed in status changes

## Requirements

- iOS 9.0+
- Xcode 8.1+
- Swift 3.0+

## Installation

### Carthage

The best way to install CloudKitCurrentUser to your project is to use Carthage. To add this dependency to your project you enter the following in your Cartfile:

`github "JagCesar/CloudKitCurrentUser"`

Take a look at the [documentation](https://github.com/Carthage/Carthage#installing-carthage) for more information on how you set up Carthage.

## Usage

First of all you have to import CloudKitCurrentUser to your current file. To do that you add the following at the top of your swift file:

```
import CloudKitCurrentUser
```

To get the status of the current user you just call the `currentStatus` function, like this:

```
CurrentUser.sharedInstance.currentStatus { status, error in
	// Act accordingly here
}
```

And to get the current user identifier, you write the following:

```
CurrentUser.sharedInstance.userIdentifier { identifier, error in
	// Act accordingly
}
```

## Get in touch

Feel free to get in touch if you have any questions. I'm available on Twitter as [@JagCesar](http://twitter.com/JagCesar).

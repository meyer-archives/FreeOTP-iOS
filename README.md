# FreeOTP (WIP)

**FreeOTP (WIP)** is a multifactor authentication client for iOS. It’s a fork of the excellent [FreeOTP][] by the good folks at Red Hat.


## The Problem

* **Google Authenticator** is not very pretty, and it doesn’t let me export my original MFA tokens.
* **Authy** is almost what I need, but visually-speaking, the app leaves something to be desired, and I don’t like their lack of transparency as to how things are stored and encrypted.


## The Solution

FreeOTP is well-built; all the hard work has already been done (major shoutout to [Nathaniel McCallum][nathaniel]). Since it’s opensource, I can see exactly what’s going on and I can change things I don’t like. That makes me happy.

## Goals

### Near Future
* [ ] **A better name.**
* [ ] **A nice icon.** Working on that at the moment.
* [ ] **Encrypted token export.** I’d like to be able to store my MFA tokens somewhere safe.
* [ ] **Encrypted token sync.** Still not sure about this one, but it’d be nice if I could sync tokens across devices.
* [ ] **Touch ID support.**

### Distant Future
* [ ] **Companion Mac app that uses Bluetooth LE to do magic.** This would be *sick*.
* [ ] **App code converted to Swift.** Any new code I write will be in Swift, so this will be a gradual conversion.

[freeotp]: https://fedorahosted.org/freeotp/
[nathaniel]: http://nathaniel.themccallums.org/
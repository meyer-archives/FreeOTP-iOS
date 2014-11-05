//
//  AppDelegate.swift
//  FreeOTP
//
//  Created by Mike Meyer on 2014/11/05.
//  Copyright (c) 2014 Mike Meyer. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        return true
    }

//    TODO: Test this.
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {

//        Make token
        let token: Token? = Token(URL: url)
        
        if token == nil {
            return false
        }
        
//        Save the token
        TokenStore().add(token)
        
//        Reload the view
        self.window?.rootViewController?.loadView()
        
        return true
    }
}
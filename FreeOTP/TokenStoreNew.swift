//
//  TokenStore.swift
//  FreeOTP
//
//  Created by Mike Meyer on 2014/11/06.
//  Copyright (c) 2014 Mike Meyer. All rights reserved.
//

let TOKEN_ORDER_KEY = "tokenOrder"

@objc class TokenStoreNew {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var order: NSMutableArray?

    func init() {
        println("DEFAULTS: %s", userDefaults.dictionaryRepresentation())
    }

    func add(token: Token) {
        
    }
    
    func del(token: Token) {
        
    }
    
    func get(token: Token) {
        
    }
}
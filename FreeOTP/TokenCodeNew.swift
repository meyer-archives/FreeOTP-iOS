//
//  TokenCodeNew.swift
//  FreeOTP
//
//  Created by Mike Meyer on 2014/11/10.
//  Copyright (c) 2014 Mike Meyer. All rights reserved.
//

@objc class TokenCodeNew{
    var nextCode: TokenCodeNew?
    var codeText: NSString
    var startTime: UInt64
    var endTime: UInt64

    init(code: NSString, start: time_t, end: time_t){
        codeText = code
        startTime = UInt64(start * 1000)
        endTime = UInt64(end * 1000)
        nextCode = nil
    }

    convenience init(code: NSString, start: time_t, end: time_t, next: TokenCodeNew){
        self.init(code: code, start: start, end: end)
        nextCode = next
    }
    
    var currentCode: NSString?{
        let now = UInt64(CFAbsoluteTimeGetCurrent())

        if now < startTime {
            return nil
        }
        
        if now < endTime {
            return codeText
        }
        
        if nextCode != nil {
            return nextCode?.currentCode?
        }
        
        return nil
    }

    var currentProgress: Float?{
        let now = UInt64(CFAbsoluteTimeGetCurrent())
        
        if now < startTime {
            return 0.0
        }
        
        if now < endTime {
            var totalTime = (Float) (endTime - startTime)
            return 1.0 - Float(now - startTime) / totalTime
        }
        
        if nextCode != nil {
            return nextCode?.currentProgress?
        }

        return 0.0
    }

    var totalProgress: Float{
        let now = UInt64(CFAbsoluteTimeGetCurrent())
        var last:TokenCodeNew = self
        
        if (now < startTime) {
            return 0.0
        }
        
        // Find the last token code.
        while last.nextCode != nil {
            last = last.nextCode!
        }
        
        if (now < last.endTime) {
            let totalTime = (Float) (last.endTime - startTime)
            return 1.0 - Float(now - startTime) / totalTime
        }
        
        return 0.0
    }
}
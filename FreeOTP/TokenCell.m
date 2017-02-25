//
// FreeOTP
//
// Authors: Nathaniel McCallum <npmccallum@redhat.com>
//
// Copyright (C) 2014  Nathaniel McCallum, Red Hat
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "TokenCell.h"

@implementation TokenCell
{
    NSTimer* timer;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self == nil)
        return nil;

    self.layer.cornerRadius = 8.0f;
    self.layer.borderWidth = 4.0f;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.masksToBounds = YES;
    
    return self;
}

// I don’t think this ever gets called (?)
- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"Init With Frame!!!!!!!!!!!!!!!!!");

    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;

    self.layer.cornerRadius = 2.0f;
    return self;
}

- (BOOL)bind:(Token*)token
{
    self.state = nil;

    if (token == nil)
        return NO;

    unichar tmp[token.digits];
    for (NSUInteger i = 0; i < sizeof(tmp) / sizeof(unichar); i++)
        tmp[i] = [self.placeholder.text characterAtIndex:0];

    self.outer.hidden = ![token.type isEqualToString:@"totp"];

    self.issuer.text = token.issuer;
    self.label.text = token.label;
    self.code.text = @"Not set";

    self.outer.progress = 1.0f;
    self.inner.progress = 1.0f;
    
    return YES;
}

- (void)timerCallback:(NSTimer*)timer
{
    NSString* str = self.state.currentCode;
    if (str == nil) {
        self.state = nil;
        return;
    }

    self.inner.progress = self.state.currentProgress;
    self.outer.progress = self.state.totalProgress;
    self.code.text = str;
}

- (void)setState:(TokenCode *)state
{
    NSLog(@"%@ /// %@", state, _state);
    
    if (_state == state)
        return;

    if (state == nil) {
        self.outer.progress = 1.0f;
        self.inner.progress = 1.0f;
        self.code.text = @"Expired";
        
        if (self->timer != nil) {
            [self->timer invalidate];
            self->timer = nil;
        }
    } else if (self->timer == nil) {
        self->timer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self
                                               selector: @selector(timerCallback:)
                                               userInfo: nil repeats: YES];
    }

    _state = state;
}
@end

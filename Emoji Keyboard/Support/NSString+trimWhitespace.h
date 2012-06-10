//
//  NSString+trimWhitespace.h
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 5/15/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (trimWhitespace)

- (NSString *)trimWhitespace;
- (BOOL)trimmedIsBlank;

@end

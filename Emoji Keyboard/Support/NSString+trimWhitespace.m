//
//  NSString+trimWhitespace.m
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 5/15/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

#import "NSString+trimWhitespace.h"

@implementation NSString (trimWhitespace)

- (NSString *)trimWhitespace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)trimmedIsBlank
{
    return ([[self trimWhitespace] isEqualToString:@""]) ? YES : NO;
}

@end

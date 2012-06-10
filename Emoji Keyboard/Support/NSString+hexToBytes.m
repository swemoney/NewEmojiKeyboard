//
//  NSString+hexToBytes.m
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 4/22/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

@interface NSString (hexToBytes)
-(NSData *)hexToBytes;
@end

@implementation NSString (hexToBytes)
-(NSData*) hexToBytes {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= self.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [self substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
@end
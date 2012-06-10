//
//  SEEmojiCatalog.h
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 4/24/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SEEmojiCatalog : NSObject

@property (nonatomic, strong) NSArray        *allEmojis;
@property (nonatomic, strong) NSMutableArray *favoriteEmojis;

- (NSArray *)searchEmojis:(NSString *)searchString;
- (NSArray *)emojisForCategory:(int)category;
- (NSArray *)emojisForPage:(int)page inCategory:(int)category withColumns:(int)cols andRows:(int)rows;
- (int)totalPagesForCategory:(int)category withColumns:(int)cols andRows:(int)rows;

@end

//
//  SEAppDelegate.h
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 4/21/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEEmojiCatalog.h"

@class SEViewController;

@interface SEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow         *window;
@property (strong, nonatomic) SEViewController *viewController;
@property (strong, nonatomic) SEEmojiCatalog   *emojiCatalog;
@property (nonatomic, strong) NSDictionary     *loadedSettings;

- (void)logNewEvent:(NSString *)eventName;
- (void)logNewEvent:(NSString *)eventName withParamaters:(NSDictionary *)params;

@end

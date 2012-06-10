//
//  SEKeyboardPageViewController.h
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 5/9/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEEmojiKeyboardViewController.h"

@interface SEKeyboardPageViewController : UIViewController {
    int page;
    int category;
    int totalPages;
}

@property (nonatomic, assign) SEEmojiKeyboardViewController *keyboardViewController;
@property (nonatomic, strong) NSArray                       *emojis;

- (id)initWithPageNumber:(int)page inCategory:(int)category;

@end

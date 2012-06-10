//
//  SEViewController.h
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 4/21/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEKeyboardToolbarViewController.h"
#import "SEEmojiKeyboardViewController.h"

@interface SEViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong)          SEKeyboardToolbarViewController  *toolbarViewController;
@property (nonatomic, strong)          SEEmojiKeyboardViewController    *keyboardViewController;
@property (nonatomic, strong) IBOutlet UITextView                       *textView;

- (void)showInfoWindowIfNeeded;

@end

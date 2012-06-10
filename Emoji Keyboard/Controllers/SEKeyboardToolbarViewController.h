//
//  SEKeyboardToolbarViewController.h
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 4/21/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>

@class SEViewController;

@interface SEKeyboardToolbarViewController : UIViewController <UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIToolbar        *toolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem  *doneButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem  *keyboardToggleButton;
@property (nonatomic, assign)          SEViewController *mainViewController;

- (IBAction)doneTapped:(id)sender;
- (IBAction)clearTapped:(id)sender;
- (IBAction)keyboardToggleTapped:(id)sender;

@end

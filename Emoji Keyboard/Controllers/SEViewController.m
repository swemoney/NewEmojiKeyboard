//
//  SEViewController.m
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 4/21/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

#import "SEViewController.h"
#import "SEInfoViewController.h"

@interface SEViewController ()
@end


@implementation SEViewController

@synthesize toolbarViewController  = _toolbarViewController;
@synthesize keyboardViewController = _keyboardViewController;
@synthesize bannerViewContainer    = _bannerViewContainer;
@synthesize bannerView             = _bannerView;
@synthesize textView               = _textView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    // Set up some notifications for the keyboard so we know when it shows up and hides
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notifyKeyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notifyKeyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    //
    // Initialize the keyboard view controller
    _keyboardViewController = [[SEEmojiKeyboardViewController alloc] initWithNibName:@"SEEmojiKeyboard_iPhone" bundle:nil];
    _keyboardViewController.textView = _textView;
    
    //
    // Initialize the keyboard toolbar
    _toolbarViewController = [[SEKeyboardToolbarViewController alloc] initWithNibName:@"SEKeyboardToolbar_iPhone" bundle:nil];
    _toolbarViewController.mainViewController = self;
    
    //
    // Set the accessory and input keyboards for the text view
    [_textView setInputAccessoryView:_toolbarViewController.view];
    [_textView setInputView:_keyboardViewController.view];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //
    // Show the info window if we need to
    [self showInfoWindowIfNeeded];
    
    //
    // Raise the keyboard!
    [_textView becomeFirstResponder];
}

- (void)showInfoWindowIfNeeded
{
    // 
    // If the user enabled it in Settings, or it's our first run
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if (![d boolForKey:@"infoWindowSeen"] || [d boolForKey:@"showInfoWindow"]) {
        SEInfoViewController *infoViewController = [[SEInfoViewController alloc] initWithNibName:@"SEInfoView_iPhone" bundle:nil];
        [self presentModalViewController:infoViewController animated:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _textView               = nil;
    _keyboardViewController = nil;
    _toolbarViewController  = nil;
    _bannerViewContainer    = nil;
    _bannerView             = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#
#pragma mark - Ad Network Delegates
#

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    [_textView becomeFirstResponder];
}


#
#pragma mark - UIKeyboard Notifications
#

- (void)notifyKeyboardDidShow:(NSNotification *)notification 
{
    CGSize keyboardSize = CGSizeMake(320, 260);
    
    CGRect textFrame   = _textView.frame;
    CGRect bannerFrame = _bannerViewContainer.frame;
    
    textFrame.size.height = self.view.frame.size.height - keyboardSize.height - 50;
    bannerFrame.origin.y  = textFrame.size.height;
    
    _textView.frame = textFrame;
    _bannerViewContainer.frame = bannerFrame;
}

- (void)notifyKeyboardDidHide:(NSNotification *)notification
{
    CGRect textFrame = _textView.frame;
    CGRect bannerFrame = _bannerViewContainer.frame;
    
    textFrame.size.height = self.view.frame.size.height - 50;
    bannerFrame.origin.y  = textFrame.size.height;
    
    _textView.frame = textFrame;
    _bannerViewContainer.frame = bannerFrame;
}

@end

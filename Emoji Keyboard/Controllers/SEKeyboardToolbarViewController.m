//
//  SEKeyboardToolbarViewController.m
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 4/21/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

#import "SEKeyboardToolbarViewController.h"
#import "NSString+trimWhitespace.h"
#import "SEAppDelegate.h"
#import "SEViewController.h"
#import "TargetConditionals.h"

//#define kActionSheetCopyAndLoad 1
//#define kActionSheetFacebook    4
#define kActionSheetCopy        0
#define kActionSheetMessage     1
#define kActionSheetMail        2
#define kActionSheetTweet       3
#define kActionSheetCancel      4

#define kAlertCopyAndLoad 20

@interface SEKeyboardToolbarViewController ()
@end

@implementation SEKeyboardToolbarViewController

@synthesize mainViewController   = _mainViewController;
@synthesize keyboardToggleButton = _keyboardToggleButton;
@synthesize doneButton           = _doneButton;
@synthesize toolbar              = _toolbar;

- (void)viewDidUnload
{
    [super viewDidUnload];
    _keyboardToggleButton = nil;
    _doneButton           = nil;
    _toolbar              = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}

- (void)focusTextView
{
    [_mainViewController.textView performSelectorOnMainThread:@selector(becomeFirstResponder) 
                                                   withObject:NULL 
                                                waitUntilDone:YES];
}

#
#pragma mark - Buttons
#

- (IBAction)doneTapped:(id)sender
{
    if (![_mainViewController.textView.text trimmedIsBlank]) {
    
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"What would you like to do with this text?" 
                                                                 delegate:self 
                                                        cancelButtonTitle:@"Cancel" 
                                                   destructiveButtonTitle:nil 
                                                        otherButtonTitles:@"Copy", @"Message", @"Mail", @"Tweet", nil];
        
        [actionSheet showInView:_mainViewController.view];
        
    } else {
        
        [kAppDelegate logNewEvent:@"Done Touched: Blank Text"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Emoji or Text Entered" 
                                                        message:@"I can't do anything without any Emojis or text entered. Go nuts! Type something awesome!" 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show]; alert = nil;
    }
}

- (IBAction)clearTapped:(id)sender
{
    [kAppDelegate logNewEvent:@"Text Cleared"];
    [_mainViewController.textView setText:@""];
}

- (IBAction)keyboardToggleTapped:(id)sender
{
    [kAppDelegate logNewEvent:@"Keyboard Toggled"];
    if (_mainViewController.textView.inputView == nil)
         _mainViewController.textView.inputView = _mainViewController.keyboardViewController.view;
    else _mainViewController.textView.inputView = nil;
    [_mainViewController.textView reloadInputViews];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case kActionSheetCopy:
            [self actionCopy];
            break;
        case kActionSheetMessage:
            [self actionMessage];
            break;
        case kActionSheetMail:
            [self actionMail];
            break;
        case kActionSheetTweet:
            [self actionTweet];
            break;
        default:
            break;
    }
}


#
#pragma mark - Action Sheet methods
#

// Action selected: Copy
- (void)actionCopy
{
    [kAppDelegate logNewEvent:@"Action Selected: Copy"];
    [[UIPasteboard generalPasteboard] setString:_mainViewController.textView.text];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Copied" 
                                                    message:@"Your message has been copied! Feel free to paste it in any other application." 
                                                   delegate:self 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show]; alert = nil;
}

- (void)actionCopyAndLoad
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if (![d boolForKey:@"informedAboutCopyAndLoad"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Copy & Load"
                                                        message:@"Copy & Load will copy the currently typed text and emoji characters to the clipboard and then load the specified application.\n\nYou can change the specified application in your device's Settings app." 
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel" 
                                              otherButtonTitles:@"OK", nil];
        alert.tag = kAlertCopyAndLoad;
        [alert show]; alert = nil;
    } else {
        [self finishActionCopyAndLoad];
    }
}

// Not fully implemented yet. Eventually going to allow the user to select an application
// that will launch after the text is copied.
- (void)finishActionCopyAndLoad
{
    [kAppDelegate logNewEvent:@"Action Selected: Copy & Load"];
    [[UIPasteboard generalPasteboard] setString:_mainViewController.textView.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"sms:"]];

}

// Action selected: Message
- (void)actionMessage
{
    [kAppDelegate logNewEvent:@"Action Selected: Message"];
    if ([MFMessageComposeViewController canSendText]) {
        
        #if (TARGET_IPHONE_SIMULATOR)
        DLog(@"MessageUI Doesn't Work in Simulator");
        #else
        MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
        [messageViewController setMessageComposeDelegate:self];
        [messageViewController setBody:_mainViewController.textView.text];
        [_mainViewController presentModalViewController:messageViewController animated:NO];
        #endif
        
    } else {
        
        [kAppDelegate logNewEvent:@"User Can't Send Message"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can\'t Send Text Messages" 
                                                        message:@"Your iOS device is not set up to send either SMS Text Messages or iMessages. Check your Settings application and try again." 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show]; alert = nil;
        
    }
}

// Action selected: Mail
- (void)actionMail
{
    [kAppDelegate logNewEvent:@"Action Selected: Mail"];
    if ([MFMailComposeViewController canSendMail]) {
        
        #if (TARGET_IPHONE_SIMULATOR)
        DLog(@"Mail Composer Doesn't Work in Simulator");
        #else
        NSString *body = [NSString stringWithFormat:@"%@\n\n\nSent using New Emoji Keyboard.", _mainViewController.textView.text];
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        [mailViewController setMailComposeDelegate:self];
        [mailViewController setMessageBody:body isHTML:NO];
        [_mainViewController presentModalViewController:mailViewController animated:NO];
        #endif
        
    } else {
        
        [kAppDelegate logNewEvent:@"User Can't Send Mail"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can\'t Send Mail" 
                                                        message:@"Your iOS device is not set up to send Mail. Check your Settings application and try again." 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show]; alert = nil;
        
    }
}

// Action selected: Tweet
- (void)actionTweet
{
    [kAppDelegate logNewEvent:@"Action Selected: Tweet"];
    if ([TWTweetComposeViewController canSendTweet]) {
        
        TWTweetComposeViewController * tweetViewController = [[TWTweetComposeViewController alloc] init];
        [tweetViewController setInitialText:_mainViewController.textView.text];
        [tweetViewController setCompletionHandler:NULL];
        [_mainViewController presentModalViewController:tweetViewController animated:NO];
        
    } else {
        
        [kAppDelegate logNewEvent:@"User Can't Send Tweet"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can\'t Send Tweets" 
                                                        message:@"Your iOS device is not set up for Twitter. Check your Settings application and try again." 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show]; alert = nil;
        
    }
}


#
#pragma mark - Delegates
#

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertCopyAndLoad) {
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        [d setBool:YES forKey:@"informedAboutCopyAndLoad"];
        [d synchronize];
        
        if (buttonIndex == 1)
            [self finishActionCopyAndLoad];
        return;
    }
}
    

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller 
                 didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            [kAppDelegate logNewEvent:@"Send Message: Canceled"];
            break;
        case MessageComposeResultSent:
            [kAppDelegate logNewEvent:@"Send Message: Sent"];
            break;
        case MessageComposeResultFailed:
            [kAppDelegate logNewEvent:@"Send Message: Failed"];
            break;
        default: {
            [kAppDelegate logNewEvent:@"Send Message: Failed"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                            message:@"Sending Failed" 
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show]; alert = nil; }
            break;
    }
    
    //
    // Using ..Animated:YES makes the textView lose first responder and we can't get it back
    [_mainViewController dismissModalViewControllerAnimated:NO];
    [self focusTextView];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller 
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            [kAppDelegate logNewEvent:@"Send Mail: Canceled"];
            break;
        case MFMailComposeResultSaved:
            [kAppDelegate logNewEvent:@"Send Mail: Saved"];
            break;
        case MFMailComposeResultSent:
            [kAppDelegate logNewEvent:@"Send Mail: Sent"];
            break;
        case MFMailComposeResultFailed:
            [kAppDelegate logNewEvent:@"Send Mail: Failed"];
            break;
        default: {
            [kAppDelegate logNewEvent:@"Send Mail: Failed"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail"
                                                            message:@"Sending Failed" 
                                                           delegate:self 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show]; alert = nil; }
            break;
    }
    
    //
    // If we use ..Animated:NO we get a bad_access error
    [_mainViewController dismissModalViewControllerAnimated:YES];
    [self focusTextView];
    
}

@end

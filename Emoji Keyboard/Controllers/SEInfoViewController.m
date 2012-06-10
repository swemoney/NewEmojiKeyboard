//
//  SEInfoViewController.m
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 5/14/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

#import "SEInfoViewController.h"
#import "SEAppDelegate.h"

@interface SEInfoViewController ()
@end

@implementation SEInfoViewController

@synthesize webView;

- (void)viewDidLoad
{
    NSLog(@"Info View Did Load");
    [super viewDidLoad];
    NSString *info = @"<html><head><style>body{font-family:verdana;background-color:transparent;color:white;}h1,h2{text-align:center;}h1{font-size:1.6em;}h2{font-size:1.0em;}p{text-align:justify;font-size:0.9em;line-height:1.4em;}ul{font-size:0.9em;}strong{font-size:1.1em;}</style></head><body>"
    "<h1>New Emoji Keyboard</h1>"
    "<h2>Looking for a <em>global</em> keyboard?</h2>"
    "<p>New Emoji Keyboard does <strong>NOT</strong> install a new global keyboard! Apple does <strong>not</strong> give developers the ability to install new keyboards onto the system! Let's face it. The emoji apps that add <strong>hundreds of entries</strong> to your contact list and make you use the Japanese (Kanji) keyboard just plain stink. They sacrifice the quality of their app and the user experience for a marketing gimmick and usually end up ripping off it's users in the process. New Emoji Keyboard <strong><em>won't do any of this!</em></strong> <em>Instead</em>, New Emoji Keyboard will make the in-app experience as great for it's users as possible. If Apple changes it's policies and allows developers to start installing new keyboard for real, I will be happy to implement this into New Emoji Keyboard.</p>"
    "<p style=\"text-align:left;\"><strong>Looking for some customization?</strong><br />New Emoji Keyboard let's your customize parts of the keyboard without getting in your way. Head to your device's Settings.app to find all the settings for New Emoji Keyboard.</p>"
    "<p style=\"text-align:left;\"><strong>Who can see these new Emojis?</strong></br />When Apple released iOS 5.0, they broke Emoji compatibility with iOS 4.x. Also, they released the NEW (330+) Emoji's with iOS 5.1. Because of this, New Emoji Keyboard requires iOS 5.1 because only devices updated past iOS 5.1 can see them. If your friends can't see the Emoji icons you send them from this app, tell them to update their phone to iOS 5.1 or greater!</p>"
    "<p><strong>Don't have the old, default Emoji Keyboard enabled?</strong><br />As of iOS 5.0, Apple has finally unlocked the default Emoji Keyboard for <em>EVERYONE</em>! <strong>No app required</strong>! If you are running iOS 5.0 or greater, do NOT pay money for an app that promises to unlock and install the old keyboard.</p>"
    "<p style=\"text-align:left;\"><strong>Installing the old, default Emoji Keyboard:</strong><br />"
    "<ul><li>Load up your Settings.app</li>"
    "<li>Navigate to General -> Keyboard</li>"
    "<li>Go to International Keyboards</li>"
    "<li>Scroll down, find Emoji and tap it</li>"
    "<li>ENJOY! That's all there is to it!</li></ul>"
    "<p>You will then be able to switch to the default emoji keyboard provided by Apple at any time by tapping the 'globe' key on the keyboard next to the space key.</p></body></html>";
    [webView loadHTMLString:info baseURL:nil];
    info = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dismissInfo:(id)sender
{
    [kAppDelegate logNewEvent:@"Info: Dismissed"];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setBool:YES forKey:@"infoWindowSeen"];
    [d setBool:NO  forKey:@"showInfoWindow"];
    [d synchronize]; d = nil;
    
    [self dismissModalViewControllerAnimated:YES];
}

@end

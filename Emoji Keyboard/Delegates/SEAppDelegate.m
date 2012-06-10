//
//  SEAppDelegate.m
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 4/21/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

#import "SEAppDelegate.h"
#import "SEViewController.h"

@implementation SEAppDelegate

#define kDefaultsUpdatedDate @"2012-05-15"

@synthesize window         = _window;
@synthesize viewController = _viewController;
@synthesize emojiCatalog   = _emojiCatalog;
@synthesize loadedSettings = _loadedSettings;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    // Create the emoji catalog
    _emojiCatalog = [[SEEmojiCatalog alloc] init];
    
    // Initialize window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Create the main view controller
    _viewController = [[SEViewController alloc] initWithNibName:@"SEViewController_iPhone" bundle:nil];
    
    // Load the current defaults
    [self registerDefaultDefaults];
    [self loadCurrentDefaults];
    
    // Set the root view controller and make everything visible
    self.window.rootViewController = _viewController;
    [self.window makeKeyAndVisible];
    return YES;
}


#
#pragma mark - Debug/Release methods
#

- (void)logNewEvent:(NSString *)eventName
{
    #ifdef DEBUG
    DLog(@"DEBUG: Event: %@", eventName);
    #else
    // Old entry point for analytics
    #endif
}

- (void)logNewEvent:(NSString *)eventName withParamaters:(NSDictionary *)params
{
    #ifdef DEBUG
    DLog(@"DEBUG: Event: %@ - With Paramaters: %@", eventName, params);
    #else
    // Old entry point for analytics
    #endif
}

- (void)startAnalytics
{
    #ifdef DEBUG
    DLog(@"DEBUG: Analytics NOT Loaded in debug mode");
    #else
    // Old entry point for analytics
    #endif
}


#
#pragma mark - Settings
#

- (void)registerDefaultDefaults
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    if ([self defaultsNeedToBeSet]) {
        NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:1],    @"emojiSorting",
                                  [NSNumber numberWithBool:NO],  @"hideOldEmojis",
                                  [NSNumber numberWithBool:YES], @"highlightNewEmojis",
                                  [NSDate date],                 @"defaultsRegisteredOn", nil];
        [d registerDefaults:defaults];
        [d synchronize];
    }
}

- (BOOL)defaultsNeedToBeSet
{
    NSUserDefaults  *d = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *defaultsRegisteredDate = [d objectForKey:@"defaultsRegisteredOn"];
    NSDate *defaultsUpdatedDate    = [f dateFromString:kDefaultsUpdatedDate];
    
    return (defaultsRegisteredDate == nil || ([defaultsRegisteredDate timeIntervalSinceDate:defaultsUpdatedDate] < 0)) ? YES : NO;
}

- (void)loadCurrentDefaults
{
    DLog(@"Saving Current Settings");
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults]; [d synchronize];
    _loadedSettings = nil;
    _loadedSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                       [d objectForKey:@"emojiSorting"],       @"emojiSorting",
                       [d objectForKey:@"hideOldEmojis"],      @"hideOldEmojis",
                       [d objectForKey:@"highlightNewEmojis"], @"highlightNewEmojis", nil];
}

- (BOOL)intSettingHasChanged:(NSString *)setting
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    int defaults = [d integerForKey:setting];
    int loaded   = [[_loadedSettings objectForKey:setting] intValue];
    DLog(@"Comparing int %@ - Loaded: %i, Defaults: %i", setting, loaded, defaults);
    return (defaults == loaded) ? NO : YES;
}

- (BOOL)boolSettingHasChanged:(NSString *)setting
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    BOOL defaults = [d boolForKey:setting];
    BOOL loaded   = [[_loadedSettings objectForKey:setting] boolValue];
    DLog(@"Comparing BOOL %@ - Loaded: %@, Defaults: %@", setting, (loaded ? @"YES" : @"NO"), (defaults ? @"YES" : @"NO"));
    return (defaults == loaded) ? NO : YES;
}

- (void)compareSettings
{
    BOOL changed  = NO;
    if  (changed == NO) changed = [self intSettingHasChanged:@"emojiSorting"];
    if  (changed == NO) changed = [self boolSettingHasChanged:@"hideOldEmojis"];
    if  (changed == NO) changed = [self boolSettingHasChanged:@"highlightNewEmojis"];
    DLog(@"Compared Settings: changed = %@", (changed ? @"YES" : @"NO"));
    
    if (changed)
        [_viewController.keyboardViewController resetKeyboardPagesForCurrentCategory];
    
}


#
#pragma mark - Application States
#

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Make sure the loaded settings are up to date so we can detect changes
    [self loadCurrentDefaults];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Save page and category information
    [_viewController.keyboardViewController saveForBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Compare loaded settings with current defaults
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults]; [d synchronize];
    [self compareSettings];
    [_viewController showInfoWindowIfNeeded];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

@end

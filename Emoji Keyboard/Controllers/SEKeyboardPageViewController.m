//
//  SEKeyboardPageViewController.m
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 5/9/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

#import "SEKeyboardPageViewController.h"
#import "SEAppDelegate.h"

@interface SEKeyboardPageViewController ()
@end

#define kPaddingFarLeft   2
#define kPaddingFarRight  2
#define kPaddingFarTop    21
#define kPaddingFarBottom 4

#define kPaddingX 1
#define kPaddingY 1

#define kKeyWidth  44
#define kKeyHeight 44

@implementation SEKeyboardPageViewController

@synthesize keyboardViewController = _keyboardViewController;
@synthesize emojis                 = _emojis;

- (id)initWithPageNumber:(int)lPage inCategory:(int)lCategory
{
    
    self = [super initWithNibName:@"SEKeyboardPage_iPhone" bundle:nil];
    
    if (self) {
        
        page     = lPage;
        category = lCategory;
        
        // We're on the favorites page so things are a tad different
        if (lCategory == -1) {
            
            if (kEmojiCatalog.favoriteEmojis.count < 1)
                _emojis = nil;
            
            else {
                NSRange range;
                range.location = 0;
                range.length = kEmojiCatalog.favoriteEmojis.count > 20 ? 20 : kEmojiCatalog.favoriteEmojis.count;
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:NO];
                NSMutableArray *sortedArray = [kEmojiCatalog.favoriteEmojis mutableCopy];
                [sortedArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                _emojis = [NSArray arrayWithArray:sortedArray];
            }
            
        }
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (category != -1)
        _emojis = [kEmojiCatalog emojisForPage:page 
                                    inCategory:category 
                                   withColumns:[_keyboardViewController numberOfColumnsPerPage] 
                                       andRows:[_keyboardViewController numberOfRowsPerPage]];

    // We need a clear background
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    // Add the emojis to this page
    if (_emojis != nil)
        [self addEmojis:_emojis toView:self.view];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _emojis = nil;
}

- (void)dealloc
{
    _emojis = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}


#
#pragma mark - Actions
#

- (IBAction)keyPressed:(id)sender
{
    
    // Play the system 'click'
    [[UIDevice currentDevice] playInputClick];
    
    // Insert the emoji into the parent text view
    UIButton *button = (UIButton *)sender;
    [_keyboardViewController.textView insertText:button.titleLabel.text];
    
    // Add the emoji to the recent list
    NSMutableDictionary *emoji = [_emojis objectAtIndex:button.tag];
    [self addEmojiToFavorites:emoji];
    
    [kAppDelegate logNewEvent:@"Key Pressed" withParamaters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [emoji objectForKey:@"utf8"], @"utf8",
                                                             [emoji objectForKey:@"name"], @"name", nil]];
    
}


#
#pragma mark - Key Management
#

// Add the emojis from the array to a view
- (void)addEmojis:(NSArray *)emojis toView:(UIView *)view
{
    int i = 0;
    for (int y = 1; y <= [_keyboardViewController numberOfColumnsPerPage]; y++) {
        for (int x = 1; x <= [_keyboardViewController numberOfRowsPerPage]; x++) {
            if (i < emojis.count)
                [self addKeyAtLocationX:x Y:y emoji:[emojis objectAtIndex:i] toView:view withTag:i];
            i++;
        }
    }
}

// Add a single key to the view at a specific grid location
- (void)addKeyAtLocationX:(int)x Y:(int)y emoji:(NSDictionary *)emoji toView:(UIView *)view withTag:(int)index
{
    UIButton *key = [self keyAtLocationX:x Y:y emoji:emoji];
    key.tag = index;
    [view addSubview:key];
}

// Return a UIButton key for a grid location
- (UIButton *)keyAtLocationX:(int)x Y:(int)y emoji:(NSDictionary *)emoji
{
    UIButton *key = [UIButton buttonWithType:UIButtonTypeCustom];
    [key setFrame:CGRectMake([self xCoordsOnGrid:x], [self yCoordsOnGrid:y], kKeyWidth, kKeyHeight)];
    [key.titleLabel setFont:[UIFont fontWithName:@"Apple Color Emoji" size:32.0f]];
    [key setTitle:[emoji objectForKey:@"utf8"] forState:UIControlStateNormal];
    [key addTarget:self action:@selector(keyPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if ([d boolForKey:@"highlightNewEmojis"]) {
        UIImage *bg = [UIImage imageNamed:@"new_emoji_bg.png"];
        if ([[emoji objectForKey:@"hidden"] boolValue])
            [key setBackgroundImage:bg forState:UIControlStateNormal];
        bg = nil;
    }
    
    return key;
}

// Add a key to the favorites array
- (void)addEmojiToFavorites:(NSDictionary *)emoji
{
    DLog(@"Adding Emoji To Favorites");
    NSPredicate    *filter     = [NSPredicate predicateWithFormat:@"unicode = %@", [emoji objectForKey:@"unicode"]];
    NSMutableArray *duplicates = [kEmojiCatalog.favoriteEmojis mutableCopy];
    [duplicates filterUsingPredicate:filter];
    
    int weight = 0;
    
    for (NSDictionary *duplicate in duplicates) {
        weight = [[duplicate objectForKey:@"weight"] intValue];
        [kEmojiCatalog.favoriteEmojis removeObject:duplicate];
    }
    
    duplicates = nil;
    filter = nil;
    
    [emoji setValue:[NSNumber numberWithInt:weight + 1] forKey:@"weight"];
    [kEmojiCatalog.favoriteEmojis insertObject:emoji atIndex:0];
    if (kEmojiCatalog.favoriteEmojis.count > 50) [kEmojiCatalog.favoriteEmojis removeLastObject];
    
}

#
#pragma mark - Key Location
#

// Return X coordinates for the X grid location
- (int)xCoordsOnGrid:(int)x
{
    return (kPaddingFarLeft - kPaddingX) + (kPaddingX * x) + (x * kKeyWidth) - kKeyWidth;
}

// Return Y coordinates for the Y grid location
- (int)yCoordsOnGrid:(int)y
{
    return (kPaddingFarTop - kPaddingY) + (kPaddingY * y) + (y * kKeyHeight) - kKeyHeight;
}


@end

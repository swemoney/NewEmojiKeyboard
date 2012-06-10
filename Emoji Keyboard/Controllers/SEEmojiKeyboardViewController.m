//
//  SEEmojiKeyboardViewController.m
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 4/21/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

#import "SEEmojiKeyboardViewController.h"
#import "SEKeyboardPageViewController.h"
#import "SEViewController.h"
#import "SEAppDelegate.h"

@interface SEEmojiKeyboardViewController ()
@end

@implementation SEEmojiKeyboardViewController

@synthesize textView            = _textView;
@synthesize pageViewControllers = _pageViewControllers;
@synthesize tabBar              = _tabBar;
@synthesize scrollView          = _scrollView;
@synthesize pageControl         = _pageControl;
@synthesize activity            = _activity;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Grab the saved category
    currentCategory = [self savedCategory];
    
    // Adjust the size of the tab bar to equal apples own emoji bar
    _tabBar.frame = CGRectMake(-10, _tabBar.frame.origin.y - 11, 
                                    _tabBar.frame.size.width, 
                                    _tabBar.frame.size.height + 11);
    
    // Set the currently selected tab
    [_tabBar setSelectedSegmentIndex:currentCategory + 2];
    
    // Set the background of the view to an image that looks like the default emoji keyboard
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"keyboard_background.png"]]];
    
    // Add and customize the page control element to resemler Apple's default
    _pageControl = [self customPageControl];
    [self.view addSubview:_pageControl];
    
    // Reset the keyboard (just like when the category is changed)
    [self resetKeyboardPagesForCategory:currentCategory];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _tabBar              = nil;
    _scrollView          = nil;
    _pageControl         = nil;
    _pageViewControllers = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#
#pragma mark - Category Switching
#

// Setup the basic info for a category
- (void)setTabInfoForCategory:(int)category
{
    DLog(@"Setting Tab Info");
    
    currentCategory = category;
    currentPage     = [self savedPageNumberForCategory:currentCategory];
    totalPages      = [kEmojiCatalog totalPagesForCategory:category 
                                               withColumns:[self numberOfColumnsPerPage] 
                                                   andRows:[self numberOfRowsPerPage]];
}

- (void)resetKeyboardPagesForCurrentCategory
{
    [self resetKeyboardPagesForCategory:currentCategory];
}

- (void)resetKeyboardPagesForCategory:(int)category
{
    
    if (category == -1) {
        
        DLog(@"Resetting Keyboard for Favorites");
        
        currentCategory = -1;
        currentPage     = 0;
        totalPages      = 1;
        
    } else {
        
        DLog(@"Resetting Keyboard for category switch");
        
        // Set the current tab's info
        [self setTabInfoForCategory:category];

        // Check if our current page number is out of bounds
        if (currentPage >= totalPages)
            currentPage  = totalPages - 1;
        
    }
    
    // Remove all the views from the scroll view
    [[_scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_activity startAnimating];
    
    // Blank out the _pageViewController array
    _pageViewControllers = nil;
    _pageViewControllers = [self blankPagesArray];
    
    // Adjust the content size and start on the new default page
    [_scrollView setContentSize:CGSizeMake(320 * totalPages, 172)];
    [self scrollToPage:currentPage animated:NO];
    
    // Reset the page control to the new page total and current page
    [_pageControl setNumberOfPages:totalPages];
    [_pageControl setCurrentPage:currentPage];

    // Load up the views that are relevant
    // Timer is required or the removeFromSuperview methods don't fire before we load the new pages
    // This way, even though it still takes a second or 2 for the new tab pages to load, the pages
    // are all blank until they load so it doesn't look like you can do anything.
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(loadAllPages) userInfo:NULL repeats:NO];
    
}


#
#pragma mark - Actions
#

- (IBAction)segmentButtonTapped:(id)sender
{
    DLog(@"Selected Segment: %i", [_tabBar selectedSegmentIndex]);
    
    // Play a system 'click'
    [[UIDevice currentDevice] playInputClick];
    
    // Setting tab selected
    if ([_tabBar selectedSegmentIndex] == 0) {
        [_tabBar setSelectedSegmentIndex:currentCategory + 2];
        [_textView insertText:@" "];
        return;
    }
    
    // Backspace tab selected
    if ([_tabBar selectedSegmentIndex] == 7) {
        [_tabBar setSelectedSegmentIndex:currentCategory + 2];
        [_textView deleteBackward];
        return;
    }
    
    // Category selected
    [self resetKeyboardPagesForCategory:([_tabBar selectedSegmentIndex] - 2)];
    
}

- (IBAction)tabbarTouched:(id)sender
{
    
    DLog(@"Tabbar Touched");
    
    // Go back to the first page if we touched the same tab that's already active
    if (currentCategory == ([_tabBar selectedSegmentIndex] - 2)) {
        
        DLog(@"Same Tab Selected!");
        
        if (currentPage > 0) {
            currentPage = 0;
            [self scrollToPage:0 animated:YES];
            [_pageControl setCurrentPage:currentPage];
            [self savePageNumberForCategory:currentCategory];
        }
        
        return;
        
    }
    
    DLog(@"New Category");
    
    // Finish with category change
    [self segmentButtonTapped:sender];
        
}

- (IBAction)pageControlTouched:(id)sender
{

    // Set the new page number
    currentPage = _pageControl.currentPage;
    [self savePageNumberForCategory:currentCategory];
	
	// Update the scroll view to the appropriate page
    [self scrollToPage:currentPage animated:YES];
    
	// Let the scroll view delegate know we used the page control to change pages
    pageControlUsed = YES;

}

- (IBAction)keyPressed:(id)sender
{
    
    DLog(@"Key Pressed");
    
    // Play the system 'click'
    [[UIDevice currentDevice] playInputClick];
    
    // Insert the emoji into the parent text view
    [_textView insertText:[(UIButton *)sender titleLabel].text];
    
}


#
#pragma mark - Page Loading
#

- (void)loadPage:(int)page
{
    // If we're at the beginning or end or our pages, do nothing
    if (page < 0) return;
    if (page >= totalPages) return;
    
    // Fetch the view controller for the current page
    SEKeyboardPageViewController *controller = [_pageViewControllers objectAtIndex:page];
    
    // If the controller for this page is blank, create one and replace it
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[SEKeyboardPageViewController alloc] initWithPageNumber:page inCategory:currentCategory];
        controller.keyboardViewController = self;
        [_pageViewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // If the controller doesn't already exist in the scroll view, add it.
    if (controller.view.superview == nil) {
        CGRect frame = _scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [_scrollView addSubview:controller.view];
    }
    
}

- (void)loadRequiredPages
{
    [self loadPage:currentPage    ];
    [self loadPage:currentPage + 1];
    [self loadPage:currentPage - 1];
}

- (void)loadAllPages
{
    for (int i = 0; i < totalPages; i++)
        [self loadPage:i];
    [_activity stopAnimating];
}

- (NSMutableArray *)blankPagesArray
{
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < totalPages; i++)
		[controllers addObject:[NSNull null]];
    return controllers;
}


#
#pragma mark - Keyboard Sizes
#

- (CGSize)sizeOfKeyboard
{
    return CGSizeMake(320, 172);
}

- (int)numberOfColumnsPerPage
{
    return 3;
}

- (int)numberOfRowsPerPage
{
    return 7;
}


#
#pragma mark - Persistant Storage
#

// Return the saved page for a category
- (int)savedPageNumberForCategory:(int)category
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *categoryString = [NSString stringWithFormat:@"defaultPage%i"];
    if ([d objectForKey:categoryString] == nil)
        [d setObject:[NSNumber numberWithInt:0] forKey:categoryString];
    return [d integerForKey:categoryString];
}

// Save the page for a category
- (void)savePageNumberForCategory:(int)category
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject:[NSNumber numberWithInt:currentPage] 
          forKey:[NSString stringWithFormat:@"defaultPage%i",category]];
    [d synchronize];
}

// Return the saved category
- (int)savedCategory
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    return [d integerForKey:[NSString stringWithFormat:@"currentCategory"]];
}

// Return an NSArray of default pages. Each index coresponds to it's category
- (NSMutableArray *)savedDefaultPages
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSMutableArray *pages = [d objectForKey:@"defaultPages"];
    if (pages == nil)
        pages = [NSMutableArray arrayWithObjects:
                 [NSNumber numberWithInt:0],
                 [NSNumber numberWithInt:0],
                 [NSNumber numberWithInt:0],
                 [NSNumber numberWithInt:0],
                 [NSNumber numberWithInt:0], nil];
    d = nil; return pages;
}

// Save the current category to the user defaults
- (void)saveCurrentCategory
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setInteger:currentCategory forKey:@"currentCategory"];
    [d synchronize]; d = nil;
}

// Save Favorites emojis to the user defaults
- (void)saveFavoritesList
{
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject:kEmojiCatalog.favoriteEmojis forKey:@"favoriteEmojis"];
    [d synchronize]; d = nil;
}

// Saves everything we need to when we get sent to the background
- (void)saveForBackground
{
    [self savePageNumberForCategory:currentCategory];
    [self saveCurrentCategory];
    [self saveFavoritesList];
}


#
#pragma mark - UIScrollView
#

// Create a customized Page Control
- (DDPageControl *)customPageControl
{
    DDPageControl *pageControl = [[DDPageControl alloc] init];
    [pageControl setCenter:CGPointMake(self.view.center.x, 7)];
    [pageControl setNumberOfPages:totalPages];
    [pageControl setCurrentPage:currentPage];
    [pageControl setOnColor:[UIColor darkGrayColor]];
    [pageControl setOffColor:[UIColor lightGrayColor]];
    [pageControl setIndicatorDiameter: 4.8f];
    [pageControl setIndicatorSpace:11.0f];
    [pageControl setHidesForSinglePage:YES];
    [pageControl setDefersCurrentPageDisplay:YES];
    [pageControl addTarget:self action:@selector(pageControlTouched:) forControlEvents:UIControlEventValueChanged];
    return pageControl;
}

// Scroll to a certain page
- (void)scrollToPage:(int)page animated:(BOOL)animated
{
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:animated];
}

// Every frame while a scroll view is scrolling
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    // If we are using the page control to change the page, don't do anything
    if (pageControlUsed) return;
    
    // Update the page number after scrolling half way through this page
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    currentPage = page;
    
    // Update the page control
    _pageControl.currentPage = currentPage;
    [_pageControl updateCurrentPageDisplay];
    
}

// The scroll view finished decelerating
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    pageControlUsed = NO;
    
    if (currentCategory != -1)
        [self savePageNumberForCategory:currentCategory];
    
}

// The scroll view started being dragged
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// The scroll view ended it's animation
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
	[_pageControl updateCurrentPageDisplay];
}

@end
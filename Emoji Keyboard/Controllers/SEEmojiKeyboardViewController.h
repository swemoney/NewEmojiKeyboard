//
//  SEEmojiKeyboardViewController.h
//  Emoji Keyboard
//
//  Created by Steve Ehrenberg on 4/21/12.
//  Copyright (c) 2012 Ess DoubleYou Eee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEEmojiCatalog.h"
#import "DDPageControl.h"

@interface SEEmojiKeyboardViewController : UIViewController <UIScrollViewDelegate> {
    int  totalPages;
    int  currentPage;
    int  currentCategory;
    BOOL pageControlUsed;
}

@property (nonatomic, assign)          UITextView           *textView;
@property (nonatomic, strong)          NSMutableArray       *pageViewControllers;

// Outlet's to controls
@property (nonatomic, strong) IBOutlet UISegmentedControl   *tabBar;
@property (nonatomic, strong) IBOutlet UIScrollView         *scrollView;
@property (nonatomic, strong) IBOutlet DDPageControl        *pageControl;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activity;

// "Tab Bar" action
- (IBAction)segmentButtonTapped:(id)sender;
- (IBAction)tabbarTouched:(id)sender;

// Keyboard sizes
- (CGSize)sizeOfKeyboard;
- (int)numberOfColumnsPerPage;
- (int)numberOfRowsPerPage;

// Persistant storage methods
- (void)saveForBackground;

// Page loading
- (void)loadRequiredPages;
- (void)resetKeyboardPagesForCurrentCategory;

@end

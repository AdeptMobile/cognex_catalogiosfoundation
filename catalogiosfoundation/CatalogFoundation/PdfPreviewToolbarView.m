//
//  ToloPreviewSketchingToolbarView.m
//  ToloApp
//
//  Created by Torey Lomenda on 7/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "PdfPreviewToolbarView.h"

#import "SFAppConfig.h"

#import "UIColor+Chooser.h"
#import "UIImage+Extensions.h"
#import "UIImage+CatalogFoundationResourceImage.h"

#define TOOLBAR_ITEM_SIZE 44.0f
#define TOOLBAR_ITEM_SPACING 44.0f

@interface PdfPreviewToolbarView()

- (void) handleSketchButton: (id) sender;
- (void) handleDocActionsButton: (id) sender;
- (void) handleCloseButton: (id) sender;
- (void) handleSearchButton: (id) sender;
- (void) handleBookmarkButton: (id) sender;
- (void) handleTOCButton: (id) sender;

- (void) dismissPopovers;

@end

@implementation PdfPreviewToolbarView

@synthesize pdfToolbarDelegate;
@synthesize document;
@synthesize currentPage;
@synthesize tocPopover;
@synthesize bookmarkPopover;
@synthesize pdfActionsPopover;

@synthesize bookmarkingDocId;


#pragma mark -
#pragma mark init/dealloc
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self.translucent = YES;
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            UIColor *barColor = [[SFAppConfig sharedInstance] getPortfolioPreviewToolbarTintColor];
            // Adjust alpha of the color in order to make the bar translucent.
            self.barTintColor = [barColor colorWithAlphaComponent:0.50f];
            if ([self.barTintColor colorIsLight]) {
                self.tintColor = [UIColor blackColor];
            } else {
                self.tintColor = [UIColor whiteColor];
            }
        } else {
            self.tintColor = [[SFAppConfig sharedInstance] getPortfolioPreviewToolbarTintColor];
        }
        
        //self.alpha = 0.7f;
        
        UIBarButtonItem *tbFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *tbFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        tbFixed.width = 44.0f;
        
        // add the buttons
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" 
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self 
                                                                       action:@selector(handleCloseButton:)];
        
        UIBarButtonItem *sketchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage contentFoundationResourceImageNamed:@"sketch.png"] 
                                                                          style:UIBarButtonItemStylePlain 
                                                                         target:self 
                                                                         action:@selector(handleSketchButton:)];
        UIBarButtonItem *docActionsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage contentFoundationResourceImageNamed:@"doc-actions.png"] 
                                                                          style:UIBarButtonItemStylePlain 
                                                                         target:self 
                                                                         action:@selector(handleDocActionsButton:)];
//        UIBarButtonItem *searchButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage contentFoundationResourceImageNamed:@"search.png"] 
//                                                                          style:UIBarButtonItemStylePlain 
//                                                                         target:self 
//                                                                         action:@selector(handleSearchButton:)] autorelease];
        UIBarButtonItem *tocButton = [[UIBarButtonItem alloc] initWithImage:[UIImage contentFoundationResourceImageNamed:@"book-toc.png"] 
                                                                          style:UIBarButtonItemStylePlain 
                                                                         target:self 
                                                                         action:@selector(handleTOCButton:)];
        UIBarButtonItem *bookmarkButton = [[UIBarButtonItem alloc] initWithImage:[UIImage contentFoundationResourceImageNamed:@"bookmark.png"] 
                                                                          style:UIBarButtonItemStylePlain 
                                                                         target:self 
                                                                         action:@selector(handleBookmarkButton:)];
        
        NSArray *toolbarButtons = [NSArray arrayWithObjects:doneButton, tbFlex, sketchButton, tbFixed, docActionsButton, tbFixed, tocButton, tbFixed, bookmarkButton, nil];
        [self setItems: toolbarButtons];
        
    }
    return self;
}

- (void)dealloc {
    toolbarItems = nil;
    
    
    
    
    
}

#pragma mark -
#pragma mark PdfContentOutlineViewControllerDelegate Methods
- (void) outlineViewController:(PdfContentOutlineViewController *)ovc didRequestPage:(NSUInteger)page {
    if (pdfToolbarDelegate && [pdfToolbarDelegate respondsToSelector:@selector(outlineSelectPage:)]) {
        [pdfToolbarDelegate outlineSelectPage:page];
    }
    
    [self dismissPopovers];
}

#pragma mark -
#pragma mark PdfBookmarkViewControllerDelegate Methods
- (NSUInteger) pageForBookmarking {
    return currentPage;
}

- (NSString *) documentIdForBookmarking {
    return bookmarkingDocId;
}

#pragma mark -
#pragma mark DocumentActionDelegate Methods
- (void) selectedAction:(DocActionType)actionType {
    if (pdfToolbarDelegate && [pdfToolbarDelegate respondsToSelector:@selector(documentActionSelected:)]) {
        [pdfToolbarDelegate documentActionSelected:actionType];
    }
    
    [self dismissPopovers];
}

- (void) bookmarkViewController:(BookmarkViewController *)bvc didRequestPage:(NSUInteger)page {
    if (pdfToolbarDelegate && [pdfToolbarDelegate respondsToSelector:@selector(bookmarkSelectPage:)]) {
        [pdfToolbarDelegate bookmarkSelectPage:page];
    }
    
    [self dismissPopovers];
}

#pragma mark -
#pragma mark Layout and Drawing
- (void) layoutSubviews {
    [super layoutSubviews];
}


#pragma mark -
#pragma mark Private Methods
- (void) handleSketchButton:(id)sender {
    [self dismissPopovers];
    
    if (pdfToolbarDelegate && [pdfToolbarDelegate respondsToSelector:@selector(sketchButtonTapped:)]) {
        [pdfToolbarDelegate sketchButtonTapped:sender];
    }
}

- (void) handleDocActionsButton:(id)sender {
    if (pdfActionsPopover == nil) {
        ResourceActionController *pdfActionController = [[ResourceActionController alloc] init];
        pdfActionController.delegate = self;
        
        self.pdfActionsPopover = [[UIPopoverController alloc] initWithContentViewController:pdfActionController];
    }
    
    [self dismissPopovers];
    
    [pdfActionsPopover presentPopoverFromBarButtonItem:(UIBarButtonItem *) sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) handleCloseButton:(id)sender {
    [self dismissPopovers];
    
    if (pdfToolbarDelegate && [pdfToolbarDelegate respondsToSelector:@selector(closeButtonTapped:)]) {
        [pdfToolbarDelegate closeButtonTapped:sender];
    }
}

- (void) handleSearchButton:(id)sender {
//    if (delegate && [delegate respondsToSelector:@selector(searchButtonTapped:)]) {
//        [delegate searchButtonTapped:sender];
//    }
}
- (void) handleTOCButton:(id)sender {
    //Bring up popover with save options
    if (tocPopover == nil) {
        PdfContentOutlineViewController *outlineController = [[PdfContentOutlineViewController alloc] initWithStyle:UITableViewStylePlain];
        outlineController.delegate = self;
        [outlineController setOutlineEntries:[document outline]];
        
        self.tocPopover = [[UIPopoverController alloc] initWithContentViewController:outlineController];
    }

    [self dismissPopovers];
    
    [tocPopover presentPopoverFromBarButtonItem:(UIBarButtonItem *) sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}
- (void) handleBookmarkButton:(id)sender {
    if (pdfToolbarDelegate && [pdfToolbarDelegate respondsToSelector:@selector(bookmarkButtonTapped:)]) {
        [pdfToolbarDelegate bookmarkButtonTapped:sender];
    }
    
    //Bring up popover with bookmarking options
    if (bookmarkPopover == nil) {
        PdfBookmarkViewController *bookmarkController = [[PdfBookmarkViewController alloc] init];
        bookmarkController.delegate = self;
        
        self.bookmarkPopover = [[UIPopoverController alloc] initWithContentViewController:bookmarkController];
    }
    
    [self dismissPopovers];
    
    [bookmarkPopover presentPopoverFromBarButtonItem:(UIBarButtonItem *) sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) dismissPopovers {
    if (tocPopover && tocPopover.isPopoverVisible) {
        [tocPopover dismissPopoverAnimated:NO];
    }
    if (bookmarkPopover && bookmarkPopover.isPopoverVisible) {
        [bookmarkPopover dismissPopoverAnimated:NO];
    }
    if (pdfActionsPopover && pdfActionsPopover.isPopoverVisible) {
        [pdfActionsPopover dismissPopoverAnimated:NO];
    }
}

@end

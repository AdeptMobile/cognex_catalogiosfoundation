//
//  ToloPreviewSketchingToolbarView.h
//  ToloApp
//
//  Created by Torey Lomenda on 7/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FastPdfKit/FastPdfKit.h>

#import "PdfContentOutlineViewController.h"
#import "PdfBookmarkViewController.h"
#import "ResourceActionController.h"

@protocol PdfPreviewToolbarDelegate <NSObject>

- (void) sketchButtonTapped: (id) sketchButton;
- (void) closeButtonTapped: (id) closeButton;

- (void) outlineSelectPage: (NSUInteger) pageSelected;

- (void) bookmarkButtonTapped: (id) bookmarkButton;
- (void) bookmarkSelectPage: (NSUInteger) pageSelected;

- (void) documentActionSelected: (DocActionType) docActionType;

// - (void) searchButtonTapped: (id) closeButton;

@end

@interface PdfPreviewToolbarView : UIToolbar<PdfContentOutlineViewControllerDelegate, PdfBookmarkViewControllerDelegate, DocumentActionDelegate> {
    id<PdfPreviewToolbarDelegate> __weak pdfToolbarDelegate;
    
    UIPopoverController *tocPopover;
    UIPopoverController *bookmarkPopover;
    UIPopoverController *pdfActionsPopover;
    
    MFDocumentManager * __weak document;
    
    NSString *bookmarkingDocId;
    NSUInteger currentPage;
    
    NSArray *toolbarItems;
}

@property (nonatomic, weak) id<PdfPreviewToolbarDelegate> pdfToolbarDelegate;
@property (nonatomic, weak) MFDocumentManager *document;

@property (nonatomic, strong) NSString *bookmarkingDocId;
@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, strong) UIPopoverController *tocPopover;
@property (nonatomic, strong) UIPopoverController *bookmarkPopover;
@property (nonatomic, strong) UIPopoverController *pdfActionsPopover;

@end

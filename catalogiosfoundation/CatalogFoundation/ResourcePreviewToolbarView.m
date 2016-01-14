//
//  ToloPreviewSketchingToolbarView.m
//  ToloApp
//
//  Created by Torey Lomenda on 7/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ResourcePreviewToolbarView.h"

#import "SFAppConfig.h"

#import "UIColor+Chooser.h"
#import "UIImage+Extensions.h"
#import "UIImage+CatalogFoundationResourceImage.h"

#define TOOLBAR_ITEM_SIZE 44.0f
#define TOOLBAR_ITEM_SPACING 44.0f

@interface ResourcePreviewToolbarView()

- (void) handleSketchButton: (id) sender;
- (void) handleCloseButton: (id) sender;
- (void) handleDocActionsButton: (id) sender;

- (void) dismissPopovers;

@end

@implementation ResourcePreviewToolbarView

@synthesize resourceToolbarDelegate;
@synthesize docActionsPopover;

#pragma mark -
#pragma mark init/dealloc
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.barTintColor = [[SFAppConfig sharedInstance] getPortfolioPreviewToolbarTintColor];
            if ([self.barTintColor colorIsLight]) {
                self.tintColor = [UIColor blackColor];
            } else {
                self.tintColor = [UIColor whiteColor];
            }
        } else {
            self.tintColor = [[SFAppConfig sharedInstance] getPortfolioPreviewToolbarTintColor];
        }
        self.translucent = YES;
       // self.alpha = 0.7;
        
        UIBarButtonItem *tbFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *tbFixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        tbFixed.width = 44.0f;
        
        // add the buttons
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" 
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self 
                                                                       action:@selector(handleCloseButton:)];
        
        //if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        //    [doneButton setTitleTextAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17.0]} forState:UIControlStateNormal];
        //}
        
        UIBarButtonItem *sketchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage contentFoundationResourceImageNamed:@"sketch.png"] 
                                                                          style:UIBarButtonItemStylePlain 
                                                                         target:self 
                                                                         action:@selector(handleSketchButton:)];
        UIBarButtonItem *docActionsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage contentFoundationResourceImageNamed:@"doc-actions.png"] 
                                                                          style:UIBarButtonItemStylePlain 
                                                                         target:self 
                                                                         action:@selector(handleDocActionsButton:)];
        
        [self setItems: [NSArray arrayWithObjects:doneButton, tbFlex, sketchButton, tbFixed, docActionsButton, nil]];
        
    }
    return self;
}

- (void)dealloc {
    toolbarItems = nil;
    
}

#pragma mark -
#pragma mark Layout and Drawing
- (void) layoutSubviews {
    [super layoutSubviews];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark -
#pragma mark DocumentActionDelegate Methods
- (void) selectedAction:(DocActionType)actionType {
    if (resourceToolbarDelegate && [resourceToolbarDelegate respondsToSelector:@selector(documentActionSelected:)]) {
        [resourceToolbarDelegate documentActionSelected:actionType];
    }
    
    [self dismissPopovers];
}

#pragma mark -
#pragma mark Private Methods
- (void) handleSketchButton:(id)sender {
    [self dismissPopovers];
    
    if (resourceToolbarDelegate && [resourceToolbarDelegate respondsToSelector:@selector(sketchButtonTapped:)]) {
        [resourceToolbarDelegate sketchButtonTapped:sender];
    }

}

- (void) handleCloseButton:(id)sender {
    [self dismissPopovers];
    
    if (resourceToolbarDelegate && [resourceToolbarDelegate respondsToSelector:@selector(closeButtonTapped:)]) {
        [resourceToolbarDelegate closeButtonTapped:sender];
    }
}

- (void) handleDocActionsButton:(id)sender {
    if (docActionsPopover == nil) {
        ResourceActionController *docActionController = [[ResourceActionController alloc] init];
        docActionController.delegate = self;
        
        self.docActionsPopover = [[UIPopoverController alloc] initWithContentViewController:docActionController];
    }
    
    [self dismissPopovers];
    
    [docActionsPopover presentPopoverFromBarButtonItem:(UIBarButtonItem *) sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) dismissPopovers {
    if (docActionsPopover && docActionsPopover.isPopoverVisible) {
        [docActionsPopover dismissPopoverAnimated:NO];
    }
}

@end

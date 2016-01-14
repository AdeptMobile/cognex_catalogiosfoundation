//
//  ResourcePreviewView.h
//  ToloApp
//
//  Created by Torey Lomenda on 6/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContentViewBehavior.h"
#import "ResourceItemPreviewView.h"
#import "StripView.h"
#import "MailSetupDelegate.h"

@interface ResourceListPreviewView : UIView<StripViewDataSource, StripViewDelegate, ResourceImageStatusDelegate> {
    id<ContentViewBehavior> contentProduct;
    
    UIView *resourceTab;
    UILabel *resourceLabel;
    
    StripView *docPreviewStripView;
    
    NSArray *resourcePathList;
    
    UIViewController *__weak productNavigationController;
    
    NSOperationQueue *loadPreviewsQueue;
    
    NSObject<MailSetupDelegate> *__weak mailSetupDelegate;
}

@property (nonatomic, strong) id<ContentViewBehavior> contentProduct;
@property (nonatomic, strong) StripView *docPreviewStripView;
@property (nonatomic, strong) NSArray *resourcePathList;
@property (nonatomic, strong) NSOperationQueue *loadPreviewsQueue;

// We want a pointer to our navigation controller (this class does not own it)
@property (nonatomic, weak) UIViewController *productNavigationController;
@property (nonatomic, weak) NSObject<MailSetupDelegate> *mailSetupDelegate;

- (id)initWithFrame:(CGRect)frame productNavController:(UIViewController *)productNavController mailSetupDelegate:(NSObject<MailSetupDelegate> *)aMailSetupDelegate withTabs:(BOOL)displayTabs andContentProduct:(id<ContentViewBehavior>)aContentProduct;

- (id)initWithFrame:(CGRect)frame productNavController:(UIViewController *)productNavController mailSetupDelegate:(NSObject<MailSetupDelegate> *)aMailSetupDelegate andContentProduct:(id<ContentViewBehavior>)aContentProduct;

- (id) initWithFrame:(CGRect)frame productNavController: (UIViewController *)productNavController andContentProduct:(id<ContentViewBehavior>) aContentProduct;

- (void) loadPreviews: (NSString *) resourceTitle withResources: (NSArray *) aResourcePathList;

- (void) onPreviewTapped:(UITapGestureRecognizer *) tapGesture;

- (BOOL) allPreviewsLoaded;
@end

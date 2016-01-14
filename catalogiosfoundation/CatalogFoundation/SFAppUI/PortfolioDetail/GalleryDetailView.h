//
//  GalleryDetailView.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 1/30/15.
//  Copyright (c) 2015 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentViewBehavior.h"
#import "DetailFavoritesViewControllerDelegate.h"
#import "DetailSearchViewControllerDelegate.h"
#import "HierarchyNavigationViewControllerDelegate.h"
#import "ResourceGridPreviewView.h"
#import "ExpandOverlayViewController.h"
#import "ContentInfoToolbarView.h"
#import "CustomBadge.h"

@interface GalleryDetailView : UIView {

    id<ContentViewBehavior> contentGallery;
    ResourceGridPreviewView *resourcePreviewView;
    
    ContentInfoToolbarView *contentToolbar;
    
    UINavigationController *__weak productNavigationController;
    ExpandOverlayViewController *__weak overlayController;
    
    UIPopoverController *detailFavoritesPopover;
    UIPopoverController *detailSearchPopover;
    UIPopoverController *hierarchyPopover;
    UIPopoverController *setupPopover;
    
}

@property (nonatomic) id<ContentViewBehavior> contentGallery;
@property (nonatomic, weak) UINavigationController *productNavigationController;
@property (nonatomic, weak) ExpandOverlayViewController *overlayController;
@property (nonatomic) UIPopoverController *detailFavoritesPopover;
@property (nonatomic) UIPopoverController *detailSearchPopover;
@property (nonatomic) UIPopoverController *hierarchyPopover;
@property (nonatomic) UIPopoverController *setupPopover;
@property (nonatomic) ContentInfoToolbarView *contentToolbar;
@property (nonatomic) ResourceGridPreviewView *resourcePreviewView;

- (id) initWithFrame:(CGRect)frame productNavController: (UINavigationController *) productNavController andContentGallery: (id<ContentViewBehavior>) aContentGallery;
- (void) hideToolbarPopover;
- (void) updateBadgeText: (NSString *) newBadgeText;
- (void) stopLoadingPreviews;
- (void) addViewsOnAppear;
- (void) removeViewsOnDisappear;
- (void) resizeBadge: (CGSize)screenSize;

@end

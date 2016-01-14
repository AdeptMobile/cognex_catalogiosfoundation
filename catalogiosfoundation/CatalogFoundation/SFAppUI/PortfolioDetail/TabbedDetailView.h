//
//  DSDetailView.h
//  Torit
//
//  Created by Nate Flink on 8/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContentViewBehavior.h"
#import "DetailFavoritesViewControllerDelegate.h"
#import "DetailSearchViewControllerDelegate.h"
#import "HierarchyNavigationViewControllerDelegate.h"

#import "ResourceTabMenuView.h"
#import "ProductPhotoView.h"
#import "TabbedPortfolioFeaturesView.h"
#import "ResourceListPreviewView.h"
#import "ExpandOverlayViewController.h"
#import "ContentInfoToolbarView.h"
#import "CustomBadge.h"

@interface TabbedDetailView  : UIView<ResourceTabMenuViewDelegate> {
    id<ContentViewBehavior> contentProduct;
    
    ProductPhotoView *productPhotoView;
    TabbedPortfolioFeaturesView *productFeaturesView;
    
    ResourceTabMenuView *resourceMenuView;
    
    ResourceListPreviewView *resourcePreviewView;
    
    ContentInfoToolbarView *contentToolbar;
    
    UINavigationController *__weak productNavigationController;
    ExpandOverlayViewController *__weak overlayController;
    
    NSInteger currentResourceMenuSelection;
    
    UIPopoverController *detailFavoritesPopover;
    UIPopoverController *detailSearchPopover;
    UIPopoverController *hierarchyPopover;
    UIPopoverController *setupPopover;
    
    NSString * onlineCatalogResourceUrl;
}

@property (nonatomic) id<ContentViewBehavior> contentProduct;
@property (nonatomic, weak) UINavigationController *productNavigationController;
@property (nonatomic, weak) ExpandOverlayViewController *overlayController;
@property (nonatomic) UIPopoverController *detailFavoritesPopover;
@property (nonatomic) UIPopoverController *detailSearchPopover;
@property (nonatomic) UIPopoverController *hierarchyPopover;
@property (nonatomic) UIPopoverController *setupPopover;
@property (nonatomic) ContentInfoToolbarView *contentToolbar;
@property (nonatomic) ResourceTabMenuView *resourceMenuView;
@property (nonatomic) ResourceListPreviewView *resourcePreviewView;

- (id) initWithFrame:(CGRect)frame productNavController: (UINavigationController *) productNavController andContentProduct: (id<ContentViewBehavior>) aContentProduct;
- (void) hideToolbarPopover;
- (void) updateBadgeText: (NSString *) newBadgeText;
- (void) stopLoadingPreviews;
- (void) addViewsOnAppear;
- (void) removeViewsOnDisappear;
- (void) resizeBadge: (CGSize)screenSize;

@end

//
//  ProductDetailView.h
//  ToloApp
//
//  Created by Torey Lomenda on 6/3/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContentViewBehavior.h"
#import "DetailFavoritesViewControllerDelegate.h"
#import "DetailSearchViewControllerDelegate.h"
#import "HierarchyNavigationViewControllerDelegate.h"

#import "ResourceButtonMenuView.h"
#import "ProductPhotoView.h"
#import "PortfolioFeaturesView.h"
#import "ResourceListPreviewView.h"
#import "ExpandOverlayViewController.h"
#import "ContentInfoToolbarView.h"
#import "CustomBadge.h"
#import "MailSetupDelegate.h"

@interface PortfolioDetailView : UIView<ResourceButtonMenuDelegate, ContentInfoToolbarDelegate, DetailFavoritesViewControllerDelegate, DetailSearchViewControllerDelegate, MailSetupDelegate> {
    id<ContentViewBehavior> contentProduct;
    
    UIImageView *logoView;
    
    ProductPhotoView *productPhotoView;
    PortfolioFeaturesView *productFeaturesView;
    
    ResourceButtonMenuView *resourceMenuView;
    
    ResourceListPreviewView *resourcePreviewView;
    
    ContentInfoToolbarView *contentToolbar;
    
    UINavigationController *__weak productNavigationController;
    ExpandOverlayViewController *__weak overlayController;
    
    NSInteger currentResourceMenuSelection;
    
    CGPoint previewScrollOrigin;
    
    UIPopoverController *detailFavoritesPopover;
    UIPopoverController *detailSearchPopover;
    UIPopoverController *hierarchyPopover;
    UIPopoverController *setupPopover;
    
}

@property (nonatomic, strong) id<ContentViewBehavior> contentProduct;
@property (nonatomic, weak) UINavigationController *productNavigationController;
@property (nonatomic, weak) ExpandOverlayViewController *overlayController;
@property (nonatomic, strong) UIPopoverController *detailFavoritesPopover;
@property (nonatomic, strong) UIPopoverController *detailSearchPopover;
@property (nonatomic, strong) UIPopoverController *hierarchyPopover;
@property (nonatomic, strong) UIPopoverController *setupPopover;
@property (nonatomic, strong) ContentInfoToolbarView *contentToolbar;

@property (nonatomic, strong) ProductPhotoView *productPhotoView;
@property (nonatomic, strong) ResourceListPreviewView *resourcePreviewView;
@property (nonatomic, strong) ResourceButtonMenuView *resourceMenuView;

@property (nonatomic, strong) UIImageView *logoView;

- (id) initWithFrame:(CGRect)frame productNavController: (UINavigationController *) productNavController andContentProduct: (id<ContentViewBehavior>) aContentProduct;
- (void) hideToolbarPopover;
- (void) updateBadgeText: (NSString *) newBadgeText;
- (void) stopLoadingPreviews;

- (void) addViewsOnAppear;
- (void) removeViewsOnDisappear;

@end

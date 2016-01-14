//
//  BasicCategoryViewController.h
//  CatalogFoundation
//
//  Created by Torey Lomenda on 1/29/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import "AbstractCategoryViewController.h"

#import "ContentLookupBehavior.h"
#import "ContentViewBehavior.h"

#import "PortfolioLevelView.h"
#import "DetailFavoritesViewControllerDelegate.h"
#import "DetailSearchViewControllerDelegate.h"
#import "HierarchyNavigationViewControllerDelegate.h"
#import "SFAppSetupViewController.h"

#import "ContentSyncManager.h"

@interface BasicCategoryViewController : AbstractCategoryViewController<
    PortfolioLevelViewDelegate,
    ContentSyncDelegate,
    ProductThumbnailDelegate,
    DetailFavoritesViewControllerDelegate,
    DetailSearchViewControllerDelegate,
    HierarchyNavigationViewControllerDelegate,
    SFAppSetupViewControllerDelegate> {
        
        id<ContentViewBehavior> categoryPath;
        
        ExpandOverlayViewController *overlayController;
        
        UIPopoverController *detailFavoritesPopover;
        UIPopoverController *detailSearchPopover;
        UIPopoverController *hierarchyPopover;
        UIPopoverController *setupPopover;
}

@property (nonatomic, strong) id<ContentViewBehavior> categoryPath;
@property (nonatomic, strong) ExpandOverlayViewController *overlayController;
@property (nonatomic, strong) UIPopoverController *detailFavoritesPopover;
@property (nonatomic, strong) UIPopoverController *detailSearchPopover;
@property (nonatomic, strong) UIPopoverController *hierarchyPopover;
@property (nonatomic, strong) UIPopoverController *setupPopover;

- (id) initWithCategoryPath: (id<ContentViewBehavior>) path;

@end

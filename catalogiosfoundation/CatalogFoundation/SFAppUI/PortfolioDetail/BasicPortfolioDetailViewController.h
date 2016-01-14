//
//  BasicPortfolioDetailViewController.h
//  CatalogFoundation
//
//  Created by Torey Lomenda on 1/29/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import "AbstractPortfolioViewController.h"

#import "ContentViewBehavior.h"

#import "ContentInfoToolbarView.h"
#import "DetailFavoritesViewControllerDelegate.h"
#import "DetailSearchViewControllerDelegate.h"
#import "HierarchyNavigationViewControllerDelegate.h"
#import "SFAppSetupViewController.h"
#import "PortfolioDetailView.h"
#import "ContentSyncManager.h"

@interface BasicPortfolioDetailViewController : AbstractPortfolioViewController<ContentInfoToolbarDelegate, DetailFavoritesViewControllerDelegate, DetailSearchViewControllerDelegate, HierarchyNavigationViewControllerDelegate, ContentSyncDelegate, SFAppSetupViewControllerDelegate> {
    
    id<ContentViewBehavior> contentProduct;
}

@property (nonatomic, strong) id<ContentViewBehavior> contentProduct;

- (id) initWithContentProduct:(id<ContentViewBehavior>) aContentProduct;

@end

//
//  GalleryDetailViewController.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 1/30/15.
//  Copyright (c) 2015 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractPortfolioViewController.h"

#import "ContentViewBehavior.h"

#import "ContentInfoToolbarView.h"
#import "DetailFavoritesViewControllerDelegate.h"
#import "DetailSearchViewControllerDelegate.h"
#import "HierarchyNavigationViewControllerDelegate.h"
#import "ContentSyncManager.h"
#import "TabbedPortfolioDetailViewConfig.h"
#import "MailSetupDelegate.h"
#import "SFAppSetupViewController.h"

@interface GalleryDetailViewController : AbstractPortfolioViewController<ContentInfoToolbarDelegate, DetailFavoritesViewControllerDelegate, DetailSearchViewControllerDelegate, HierarchyNavigationViewControllerDelegate, ContentSyncDelegate, MailSetupDelegate, SFAppSetupViewControllerDelegate> {

    id<ContentViewBehavior> contentGallery;
    
}

@property (nonatomic, strong) id<ContentViewBehavior> contentGallery;
@property (nonatomic, assign) BOOL moviePlaying;

- (id) initWithContentGallery:(id<ContentViewBehavior>) aContentGallery;

@end

//
//  DSDetailViewController.h
//  Torit
//
//  Created by Nate Flink on 8/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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

@interface TabbedDetailViewController : AbstractPortfolioViewController<ContentInfoToolbarDelegate, DetailFavoritesViewControllerDelegate, DetailSearchViewControllerDelegate, HierarchyNavigationViewControllerDelegate, ContentSyncDelegate, MailSetupDelegate,
    SFAppSetupViewControllerDelegate> {
    
    id<ContentViewBehavior> contentProduct;
    
}

@property (nonatomic, strong) id<ContentViewBehavior> contentProduct;
@property (nonatomic, assign) BOOL moviePlaying;

- (id) initWithContentProduct:(id<ContentViewBehavior>) aContentProduct;

@end



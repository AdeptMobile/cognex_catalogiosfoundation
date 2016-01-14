//
//  ProductViewController.h
//  DonaldsonEngineApp
//
//  Created by Chris Pflepsen on 8/27/12.
//
//


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AFNetworking/AFNetworking.h>
#import "UIProgressView+AFNetworking.h"
#import "AbstractPortfolioViewController.h"
#import "ContentViewBehavior.h"
#import "ContentInfoToolbarView.h"

#import "ExpandOverlayViewController.h"
#import "PortfolioLevelView.h"
#import "ProductThumbnailView.h"
#import "DetailFavoritesViewControllerDelegate.h"
#import "DetailSearchViewControllerDelegate.h"
#import "HierarchyNavigationViewControllerDelegate.h"
#import "SFAppSetupViewController.h"
#import "ContentSyncManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AlertProgressHUD.h"

@interface PortfolioDetailVideoController : AbstractPortfolioViewController<ProductThumbnailDelegate, ContentInfoToolbarDelegate, DetailFavoritesViewControllerDelegate, DetailSearchViewControllerDelegate, HierarchyNavigationViewControllerDelegate,
    ContentSyncDelegate, SFAppSetupViewControllerDelegate>{
    MPMoviePlayerController * player;
    AlertProgressHUD *downloadProgressView;
    UIView *downloadCustomView;
    UILabel *downloadProgressLabel;
    UIProgressView *downloadProgress;
    UIButton *downloadCancelButton;
    AFHTTPRequestOperation *currentOperation;
}

-(id)initWithlevelPath:(id<ContentViewBehavior>)path;

@property (nonatomic, strong) UIPopoverController *detailFavoritesPopover;
@property (nonatomic, strong) UIPopoverController *detailSearchPopover;
@property (nonatomic, strong) UIPopoverController *hierarchyPopover;
@property (nonatomic, strong) UIPopoverController *setupPopover;

@end

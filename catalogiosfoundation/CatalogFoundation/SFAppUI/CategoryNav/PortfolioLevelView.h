//
//  ProductLevelView.h
//  SickApp
//
//  Created by Steven McCoole on 2/13/12.
//  Copyright (c) 2012 Object Partners Inc. All rights reserved.
//

#import "UIViewWithLayout.h"

#import "ContentViewBehavior.h"

#import "ContentInfoToolbarView.h"

#import "ToloContentProgressView.h"
#import "ProductLevelScrollView.h"
#import "ProductThumbnailView.h"

// Temporary views to use for layout
#import "PlaceHolderView.h"

@protocol PortfolioLevelViewDelegate <NSObject>

- (void) toolbarButtonTapped:(id)toolbarButton;
- (void) longPressOnToolbarButton:(id)toolbarButton;

// sync related delegate methods
- (void) selectedSyncAction: (SyncActionType) syncAction;

@end
@interface PortfolioLevelView : UIViewWithLayout<ContentInfoToolbarDelegate> {
    id<PortfolioLevelViewDelegate> __weak delegate;
    id<ProductThumbnailDelegate> __weak thumbnailDelegate;
    UINavigationController *__weak navController;
    
    id<ContentViewBehavior> levelPath;
    
    UIImageView *logoView;
    UIImageView *bgImageView;
    ContentInfoToolbarView *toolbarView;
    ToloContentProgressView *progressView;
    
    ProductLevelScrollView *levelView;
}
@property (nonatomic, weak) id<PortfolioLevelViewDelegate> delegate;
@property (nonatomic, weak) id<ProductThumbnailDelegate> thumbnailDelegate;
@property (nonatomic, weak) UINavigationController *navController;

@property (nonatomic, strong) id<ContentViewBehavior> levelPath;

@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) ContentInfoToolbarView *toolbarView;
@property (nonatomic, strong) ToloContentProgressView *progressView;

@property (nonatomic, strong) ProductLevelScrollView *levelView;

- (id) initWithFrame:(CGRect)frame navController:(UINavigationController *)controller andLevelPath:(id<ContentViewBehavior>)path;
- (void) updateBadgeText: (NSString *) newBadgeText;
- (void) loadLevelThumbnails;

@end

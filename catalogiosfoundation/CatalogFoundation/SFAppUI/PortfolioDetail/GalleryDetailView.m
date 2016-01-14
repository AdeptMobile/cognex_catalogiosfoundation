//
//  GalleryDetailView.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 1/30/15.
//  Copyright (c) 2015 Object Partners Inc. All rights reserved.
//

#import "GalleryDetailView.h"
#import "GalleryDetailViewControllerConfig.h"

#import "ContentUtils.h"
#import "SFAppConfig.h"
#import "AlertUtils.h"
#import "ContentLookup.h"

#import "ContentSyncManager.h"

#import "UIView+ViewLayout.h"
#import "UIView+ImageRender.h"
#import "UIColor+Chooser.h"
#import "UIImage+Resize.h"
#import "UIImage+Extensions.h"
#import "NSFileManager+Utilities.h"
#import "NSBundle+CatalogFoundationResource.h"
#import "UIImage+CatalogFoundationResourceImage.h"
#import "UIScreen+Helpers.h"

#import "DetailFavoritesViewController.h"
#import "DetailSearchViewController.h"
#import "HierarchyNavigationViewController.h"
#import "HierarchyNavigationViewControllerDelegate.h"
#import "SFAppSetupViewController.h"
#import "CompanyWebViewController.h"
#import "BasicCategoryViewController.h"

#import "FXLabel.h"

#define TOOLBAR_WIDTH 13 * 44.0f
#define TOOLBAR_HEIGHT 44.0f

@interface GalleryDetailView() {
    CGPoint previewScrollOrigin;
    CGFloat yOffset;
    GalleryDetailViewControllerConfig *config;
}

- (void) setupResourcePreviewView;

- (void) dismissOnTap:(UITapGestureRecognizer *) tapGesture;
- (void) logoTapped:(UITapGestureRecognizer *) tapGesture;
- (void) dismissPopovers;

- (void) backToMain;

@end

@implementation GalleryDetailView

@synthesize contentGallery;
@synthesize productNavigationController;
@synthesize overlayController;
@synthesize detailFavoritesPopover;
@synthesize detailSearchPopover;
@synthesize hierarchyPopover;
@synthesize setupPopover;
@synthesize contentToolbar;
@synthesize resourcePreviewView;

- (id)initWithFrame:(CGRect)frame productNavController:(UINavigationController *)productNavController andContentGallery:(id<ContentViewBehavior>)aContentGallery {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        // This view is landscape only.
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        CGRect screen = [UIScreen rectForScreenView:orientation];
        
        yOffset = 0.0f;
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            // For iOS 7 or later.  This moves things out from under the status bar.
            yOffset = 20.0f;
        }
        
        config = [[SFAppConfig sharedInstance] getGalleryDetailViewConfig];
        UIImageView *backgroundImageView;
        if (config.mainBgImageNamed) {
            backgroundImageView = [[UIImageView alloc] initWithFrame:screen];
            backgroundImageView.image = [UIImage contentFoundationResourceImageNamed:config.mainBgImageNamed];
        } else {
            self.backgroundColor = config.mainBgColor;
        }
        
        // init logo
        NSString *logoLeft = config.leftLogoNamed;
        UIImageView *logoView;
        
        if (logoLeft) {
            logoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8 + yOffset, 130, 43)];
            logoView.userInteractionEnabled = YES;
            logoView.image = [UIImage contentFoundationResourceImageNamed:config.leftLogoNamed];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(homeButtonPressed:)];
            tapGesture.numberOfTapsRequired = 1;
            tapGesture.numberOfTouchesRequired = 1;
            [logoView addGestureRecognizer:tapGesture];
        } else {
            logoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8 + yOffset, 146, 63)];
            logoView.userInteractionEnabled = YES;
            logoView.image = [UIImage contentFoundationResourceImageNamed:@"logo.png"];
        }
        
        if (config.mainBgImageNamed) {
            [self addSubview:backgroundImageView];
        }
        [self addSubview:logoView];
        
        FXLabel *productLabel = [[FXLabel alloc] initWithFrame:CGRectMake(30, 72 + yOffset, 964, config.mainTitleFontSize)];
        productLabel.font = [UIFont fontWithName:config.mainTitleFont size:config.mainTitleFontSize];
        productLabel.text = [[aContentGallery contentTitle] uppercaseString];
        productLabel.backgroundColor = [UIColor clearColor];
        productLabel.textColor = config.mainTitleFontColor;
        [self addSubview:productLabel];
        
        FXLabel *infoText = [[FXLabel alloc] initWithFrame:CGRectMake(30, 128 + yOffset, 388, 90)];
        infoText.text = [aContentGallery contentInfoText];
        [infoText setLineBreakMode:NSLineBreakByWordWrapping];
        [infoText setNumberOfLines:0];
        [infoText setBackgroundColor:[UIColor clearColor]];
        [infoText setFont:[UIFont fontWithName:config.mainInfoTextFont size:config.mainInfoTextFontSize]];
        [infoText setTextColor:config.mainInfoTextFontColor];
        [infoText setTextAlignment:config.mainInfoTextHorizontalAlignment];
        [infoText setContentMode:config.mainInfoTextVerticalAlignment];
        [self addSubview:infoText];
        
        
        if (config.mainBottomBarImageNamed) {
            UIImage *bottomImage = [UIImage contentFoundationResourceImageNamed:config.mainBottomBarImageNamed];
            UIImageView *bottomBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 720 + yOffset, 1024, 28)];
            bottomBarImageView.image = bottomImage;
            
            [self addSubview:bottomBarImageView];
        }
        
        self.contentGallery = aContentGallery;
        
        productNavigationController = productNavController;
        
        // Add the toolbar
        contentToolbar = [[ContentInfoToolbarView alloc] initWithFrame:CGRectMake(180, 8 + yOffset, 832, 44)];
        [self addSubview:contentToolbar];
        
        DetailFavoritesViewController *detailFavoritesController = [[DetailFavoritesViewController alloc] init];
        self.detailFavoritesPopover = [[UIPopoverController alloc] initWithContentViewController:detailFavoritesController];
        
        DetailSearchViewController *detailSearchController = [[DetailSearchViewController alloc] init];
        self.detailSearchPopover = [[UIPopoverController alloc] initWithContentViewController:detailSearchController];
        
        HierarchyNavigationViewController *hierarchyController = [[HierarchyNavigationViewController alloc] init];
        hierarchyController.rootLevelVCAtTop = NO;
        self.hierarchyPopover = [[UIPopoverController alloc] initWithContentViewController:hierarchyController];
        
        SFAppSetupViewController *setupController = [[SFAppSetupViewController alloc] init];
        self.setupPopover = [[UIPopoverController alloc] initWithContentViewController:setupController];
        
    }
    
    return self;
        
}

#pragma mark -
#pragma mark Public Methods
- (void) hideToolbarPopover {
    [contentToolbar dismissPopover];
}

- (void) updateBadgeText: (NSString *) newBadgeText {
    [contentToolbar updateBadgeText:newBadgeText];
}

- (void) addViewsOnAppear {
    if (resourcePreviewView == nil) {
        [self setupResourcePreviewView];
        
        // Do I need to force layout?
        [resourcePreviewView layoutSubviews];
        
        if (resourcePreviewView.loadPreviewsQueue.operationCount > 0) {
            [[resourcePreviewView loadPreviewsQueue] cancelAllOperations];
        }
        if ([contentGallery hasResourceItems]) {
            [resourcePreviewView loadPreviews:nil withResources:[contentGallery contentResourceItems]];
        }
        
    }
    [self setNeedsLayout];
}

- (void) removeViewsOnDisappear {
    previewScrollOrigin = resourcePreviewView.docPreviewCollectionView.contentOffset;
    [resourcePreviewView removeFromSuperview];
    resourcePreviewView = nil;
}

#pragma mark -
#pragma mark ContentInfoToolbarDelegate Methods


- (void) longPressOnToolbarButton:(id)toolbarButton {
    // View controller will pick up the button press
}

- (void) selectedSyncAction:(SyncActionType)syncAction {
    if (syncAction == SYNC_CONTENT_NOW) {
        [[ContentSyncManager sharedInstance] performSync];
    } else if (syncAction == SYNC_APPLY_CHANGES) {
        [ContentSyncManager sharedInstance].syncDoApplyChanges = YES;
        [self backToMain];
    }
}

#pragma mark - DetailFavoritesViewControllerDelegate methods
- (id<ContentViewBehavior>) detailForFavorites {
    return contentGallery;
}

#pragma mark -
#pragma mark layout methods

- (void) layoutSubviews {
    [super layoutSubviews];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect screen = [UIScreen rectForScreenView:orientation];
    CGSize size = screen.size;
    
    [self resizeBadge:size];
}

#pragma mark -
#pragma mark Accessor Methods
//===========================================================
// - setProductNavigationController:
//===========================================================
- (void)setProductNavigationController:(UINavigationController *)aProductNavigationController {
    if (productNavigationController != aProductNavigationController) {
        // This is an assign (no retain required)
        productNavigationController = aProductNavigationController;
        
        if (resourcePreviewView) {
            resourcePreviewView.productNavigationController = aProductNavigationController;
        }
    }
}

#pragma mark - Public Methods
- (void) stopLoadingPreviews {
    // Stop loading all previews.
    if (resourcePreviewView && resourcePreviewView.loadPreviewsQueue) {
        [[resourcePreviewView loadPreviewsQueue] cancelAllOperations];
    }
}

#pragma mark - Private Methods
- (void) setupResourcePreviewView {
    if ([contentGallery hasResourceItems]) {
        resourcePreviewView = [[ResourceGridPreviewView alloc] initWithFrame:CGRectMake(30, 128 + yOffset, 970, 582) productNavController:self.productNavigationController andContentGallery:contentGallery];
        [self addSubview:resourcePreviewView];
    }
}

- (void) resizeBadge:(CGSize)screenSize {
    [contentToolbar resizeBadge];
}

-(void) dismissOnTap:(UITapGestureRecognizer *)tapGesture {
    if (overlayController) {
        [overlayController dismissOverlay];
    }
}

- (void) logoTapped:(UITapGestureRecognizer *)tapGesture {
    NSString *urlString = [[SFAppConfig sharedInstance] getGalleryDetailViewConfig].leftLogoLink;
    
    CompanyWebViewController *webViewController = [[CompanyWebViewController alloc] initWithUrl:[NSURL URLWithString:urlString] andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
    webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [productNavigationController presentViewController:webViewController animated:YES completion:NULL];
}

- (void) dismissPopovers {
    if (detailFavoritesPopover && detailFavoritesPopover.isPopoverVisible) {
        [detailFavoritesPopover dismissPopoverAnimated:NO];
    }
    if (detailSearchPopover && detailSearchPopover.isPopoverVisible) {
        [detailSearchPopover dismissPopoverAnimated:NO];
    }
    if (hierarchyPopover && hierarchyPopover.isPopoverVisible) {
        [hierarchyPopover dismissPopoverAnimated:NO];
    }
}

- (void) backToMain {
    if (productNavigationController.navigationController) {
        CATransition* transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction
                                     functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionReveal;
        [productNavigationController.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [productNavigationController.navigationController popToRootViewControllerAnimated:NO];
    }
}

-(void) homeButtonPressed:(id)sender; {
    [self backToMain];
}


@end

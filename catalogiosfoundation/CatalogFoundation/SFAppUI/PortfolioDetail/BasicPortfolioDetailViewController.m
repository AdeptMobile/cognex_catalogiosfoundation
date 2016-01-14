//
//  BasicPortfolioDetailViewController.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 1/29/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import "BasicPortfolioDetailViewController.h"

#import "OPIFoundation.h"
#import "DetailFavoritesViewController.h"
#import "DetailSearchViewController.h"
#import "HierarchyNavigationViewController.h"
#import "SFAppSetupViewController.h"
#import "SFDownloadConfigViewController.h"
#import "SFChangePasswordViewController.h"
#import "SFLoginViewController.h"
#import "GalleryDetailViewController.h"

#import "CompanyWebViewController.h"
#import "SketchPadController.h"

#import "ContentViewBehavior.h"
#import "ContentLookup.h"

#import "SFAppConfig.h"

#import "Reachability.h"
#import "AlertUtils.h"

#import "NSNotificationCenter+MainThread.h"
#import "NSDictionary+ContentViewBehavior.h"
#import "UIView+ImageRender.h"
#import "UIImage+Resize.h"

#define TOOLBAR_HEIGHT 44.0f

@interface BasicPortfolioDetailViewController ()

- (void) dismissPopovers;
- (void) backToMain;

- (PortfolioDetailView *) contentView;

@end

@implementation BasicPortfolioDetailViewController
@synthesize contentProduct;

#pragma mark - init/dealloc
- (id) initWithContentProduct:(id<ContentViewBehavior>)aContentProduct {
    self = [super init];
    if (self) {
        contentProduct = aContentProduct;
        
        // Set up title for use in the hierarchy navigation
        NSString *pathTitle = [aContentProduct contentTitle];
        [self setTitle:pathTitle];
        [[self navigationItem] setTitle:pathTitle];
    }
    return self;
}


#pragma mark - View Lifecycle Methods
- (void) loadView {
    // Do any additional setup after loading the view.
    PortfolioDetailView *detailView = [[PortfolioDetailView alloc] initWithFrame:CGRectZero productNavController:(UINavigationController *)self andContentProduct:contentProduct];
    
    detailView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    detailView.contentToolbar.delegate = self;
    
    DetailFavoritesViewController *favController = (DetailFavoritesViewController *)detailView.detailFavoritesPopover.contentViewController;
    favController.delegate = self;
    
    DetailSearchViewController *searchController = (DetailSearchViewController *)detailView.detailSearchPopover.contentViewController;
    searchController.delegate = self;
    
    HierarchyNavigationViewController *hierarchyController = (HierarchyNavigationViewController *)detailView.hierarchyPopover.contentViewController;
    hierarchyController.delegate = self;
    
    SFAppSetupViewController *setupController = (SFAppSetupViewController *)detailView.setupPopover.contentViewController;
    setupController.delegate = self;
    
    self.view = detailView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void) viewWillAppear:(BOOL)animated {
    PortfolioDetailView *detailView = (PortfolioDetailView *)self.view;
    HierarchyNavigationViewController *hierarchyController = (HierarchyNavigationViewController *)detailView.hierarchyPopover.contentViewController;
    hierarchyController.navController = self.navigationController;
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"contentProductViewed" object:self userInfo:[NSDictionary dictionaryFromContentViewBehavior:contentProduct]];
    
    // Re-add some of the views on the detail view
    [detailView addViewsOnAppear];
    
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
    
    // We need register as a sync delegate and initialize the badge count
    ContentSyncManager *syncMgr = [ContentSyncManager sharedInstance];
    [syncMgr registerSyncDelegate:self];
    
    // Let us sychronize here just in case we are in progress
    @synchronized(syncMgr) {
        if ([syncMgr isSyncInProgress] || [syncMgr hasSyncItemsToApply]) {
            // Initialize the badge
            [self syncStarted:syncMgr isFullSync:NO];
            [self syncActionsInitialized:syncMgr.syncActions];
        }
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    // Unregister as a sync delegate (This ensures the controller will be deallocated)
    [[ContentSyncManager sharedInstance] unRegisterSyncDelegate:self];
    
    PortfolioDetailView *pdv = [self contentView];
    [pdv stopLoadingPreviews];
    
    // Call super last
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    //Call super first
    [super viewDidDisappear:animated];
    
    // Re-add some of the views on the detail view
    PortfolioDetailView *detailView = (PortfolioDetailView *)self.view;
    [detailView removeViewsOnDisappear];
}

#pragma mark - Rotation Support
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[SFAppConfig sharedInstance] getPortfolioDetailViewControllerLandscapeOnly]) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[SFAppConfig sharedInstance] getPortfolioDetailViewControllerLandscapeOnly]) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return YES;
    }
}

#pragma mark - Memory Warning Support
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Accessor Methods

#pragma mark - Public Methods

#pragma mark - ContentInfoToolbarDelegate Methods
- (void) toolbarButtonTapped:(id)toolbarButton {
    switch ([toolbarButton tag]) {
        case 7:
        {
            [self dismissPopovers];
            UIButton *button = (UIButton *)toolbarButton;
            PortfolioDetailView *pdv = (PortfolioDetailView *)self.view;
            [pdv.setupPopover presentPopoverFromRect:button.frame inView:pdv.contentToolbar permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            break;
        }
        case 6:
        {
            // Home button
            [self dismissPopovers];
            [self backToMain];
            break;
        }
        case 5:
        {
            // Back button
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 4:
        {
            // Partner Portal button
            CompanyWebViewController *webViewController = [[CompanyWebViewController alloc] initWithUrl:[NSURL URLWithString:[[SFAppConfig sharedInstance] getContentInfoToolbarConfig].webBtnLink]
                                                                                              andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
            webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self.navigationController presentViewController:webViewController animated:YES completion:NULL];
            break;
        }
        case 3:
        {
            // Product Favorites button
            [self dismissPopovers];
            PortfolioDetailView *pdv = (PortfolioDetailView *)self.view;
            UIButton *button = (UIButton *)toolbarButton;
            [pdv.detailFavoritesPopover presentPopoverFromRect:button.frame inView:pdv.contentToolbar permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            break;
        }
        case 2:
        {
            // Product Search button
            [self dismissPopovers];
            PortfolioDetailView *pdv = (PortfolioDetailView *)self.view;
            UIButton *button = (UIButton *)toolbarButton;
            [pdv.detailSearchPopover presentPopoverFromRect:button.frame inView:pdv.contentToolbar permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            break;
        }
        case 1:
        {
            // Sketch button
            UIImage *previewImage = [[self.view imageFromView] resizedImage:CGSizeMake(self.view.bounds.size.width - 20*2,
                                                                                       self.view.bounds.size.height-TOOLBAR_HEIGHT-20*2) interpolationQuality:kCGInterpolationHigh];
            SketchPadController *sketchPadController = [[SketchPadController alloc]
                                                        initWithImage:previewImage
                                                        tintColor:[[SFAppConfig sharedInstance] getSketchViewTintColor]
                                                        titleFont:nil
                                                        brand:[[SFAppConfig sharedInstance] getBrandTitle]
                                                        andBgColor:[[SFAppConfig sharedInstance] getSketchViewBgColor]];
            
            [self.navigationController presentViewController:sketchPadController animated:YES completion:NULL];
        }
        default:
        {
            break;
        }
    }
}

- (void) longPressOnToolbarButton:(id)toolbarButton {
    switch ([toolbarButton tag]) {
            // Only do something with the back button on long press.  Show hierarchy.
        case 5:
        {
            [self dismissPopovers];
            PortfolioDetailView *pdv = (PortfolioDetailView *)self.view;
            UIButton *button = (UIButton *)toolbarButton;
            [pdv.hierarchyPopover presentPopoverFromRect:button.frame
                                                  inView:pdv.contentToolbar
                                permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            break;
        }
        default:
        {
            break;
        }
    }
}

#pragma mark - ContentSyncDelegate Methods
- (void) syncStarted:(ContentSyncManager *)syncManager isFullSync:(BOOL)isFullSync {
    if (isFullSync) {
        Reachability *internetReach = [Reachability reachabilityForInternetConnection];
        if ([internetReach isReachableViaWiFi]) {
            [self backToMain];
        }
    } else {
        // Show the badge by bringing it to the front
        [[[self contentView] contentToolbar] showBadge];
    }
}

- (void) syncActionsInitialized:(ContentSyncActions *)syncActions {
    // Change badge text to show all items to apply - downloads remaining
    NSInteger changesBeforeDownload = [syncActions totalItemsToApply] - [syncActions totalItemsToDownload];
    [[self contentView] updateBadgeText:[NSString stringWithFormat:@"%ld", (long)changesBeforeDownload]];
}

- (void) syncProgress:(ContentSyncManager *)syncManager currentChange:(NSInteger)currentChangeIndex totalChanges:(NSInteger)totalChangeCount {
    // Change badge text to show all items to apply - downloads remaining
    [[self contentView ]updateBadgeText:[NSString stringWithFormat:@"%ld", (long)currentChangeIndex]];
}

- (void) syncCompleted:(ContentSyncManager *)syncManager syncStatus:(SyncCompletionStatus)syncStatus {
    if (syncStatus == SYNC_STATUS_OK) {
        if ([[[[self contentView] contentToolbar] badgeText] isEqualToString:@"0"]) {
            [AlertUtils showModalAlertMessage:@"No Changes since last update." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
            [[[self contentView] contentToolbar] hideBadge];
        }
    } else if (syncStatus == SYNC_NO_WIFI) {
        [AlertUtils showModalAlertMessage:@"A WIFI Connection is required to sync." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
        [[[self contentView] contentToolbar] hideBadge];
    }
    else if (syncStatus == SYNC_STATUS_FAILED) {
        NSString *titleStr = [[SFAppConfig sharedInstance] getAppAlertTitle];
        [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Cannot update %@ content at this time due to connection failure.  Please contact %@ if problem persists.", titleStr, titleStr] withTitle:titleStr];
        [[[self contentView] contentToolbar] hideBadge];
    }
    else if (syncStatus == SYNC_AUTHORIZATION_FAILED) {
        NSString *titleStr = [[SFAppConfig sharedInstance] getAppAlertTitle];
        [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Cannot update %@ content at this time due to authorization failure.  Please check your username and password and contact %@ if problem persists.", titleStr, titleStr] withTitle:titleStr];
        [[[self contentView] contentToolbar] hideBadge];
    }
    
    [[[self contentView] contentToolbar] dismissPopover];
}

- (void) selectedSyncAction:(SyncActionType)syncAction {
    if (syncAction == SYNC_CONTENT_NOW) {
        [[ContentSyncManager sharedInstance] performSync];
    } else if (syncAction == SYNC_APPLY_CHANGES) {
        [ContentSyncManager sharedInstance].syncDoApplyChanges = YES;
        [self backToMain];
    }
}

#pragma mark - HierarchyNavigationViewControllerDelegate methods
- (id<ContentViewBehavior>) contentForNavigationDisplay {
    return contentProduct;
}

- (void) hierarchyNavigationController:(HierarchyNavigationViewController *)hnvc didSelectControllerIndex:(NSInteger)controllerIndex {
    [self dismissPopovers];
    NSArray *viewControllers = [[self navigationController] viewControllers];
    if (viewControllers && [viewControllers count] > 0 && (controllerIndex >= 0 && controllerIndex < [viewControllers count])) {
        UIViewController *vc = (UIViewController *)[viewControllers objectAtIndex:controllerIndex];
        [[self navigationController] popToViewController:vc animated:YES];
    }
}

#pragma mark - DetailFavoritesViewControllerDelegate methods
- (id<ContentViewBehavior>) detailForFavorites {
    return contentProduct;
}

- (void)favoritesViewController:(DetailFavoritesViewController *)pfvc didRequestProduct:(NSString *)productId {
    [self dismissPopovers];
    
    id<ContentViewBehavior> product = [[[ContentLookup sharedInstance] impl] lookupProduct:productId];
    
    if (product) {
        AbstractPortfolioViewController *pdvc = (AbstractPortfolioViewController *) [[SFAppConfig sharedInstance] getPortfolioDetailViewController:product];
        [self.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested product not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
}

- (void)favoritesViewController:(DetailFavoritesViewController *)pfvc didRequestGallery:(NSString *)galleryId {
    [self dismissPopovers];
    
    id<ContentViewBehavior> gallery = [[[ContentLookup sharedInstance] impl] lookupGallery:galleryId];
    
    if (gallery) {
        GalleryDetailViewController *pdvc = [[GalleryDetailViewController alloc] initWithContentGallery:gallery];
        [self.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested gallery not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
    
}

- (BOOL) canAddFavorite {
    // You can add a favorite at the portfolio detail view
    return YES;
}

#pragma mark - DetailSearchViewControllerDelegate methods
- (void) searchViewController:(DetailSearchViewController *)psvc didRequestProduct:(NSString *)productId {
    [self dismissPopovers];
    
    id<ContentViewBehavior> product = [[[ContentLookup sharedInstance] impl] lookupProduct:productId];
    
    if (product) {
        AbstractPortfolioViewController *pdvc = (AbstractPortfolioViewController *) [[SFAppConfig sharedInstance] getPortfolioDetailViewController:product];
        [self.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested product not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
}

- (void) searchViewController:(DetailSearchViewController *)psvc didRequestIndustry:(NSString *)industryId {
    [self dismissPopovers];
    
    id<ContentViewBehavior> industry = [[[ContentLookup sharedInstance] impl] lookupProduct:industryId];
    
    if (industry) {
        AbstractPortfolioViewController *pdvc = (AbstractPortfolioViewController *) [[SFAppConfig sharedInstance] getPortfolioDetailViewController:industry];
        [self.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested industry not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
}

- (void) searchViewController:(DetailSearchViewController *)psvc didRequestGallery:(NSString *)galleryId {
    [self dismissPopovers];
    
    id<ContentViewBehavior> gallery = [[[ContentLookup sharedInstance] impl] lookupGallery:galleryId];
    
    if (gallery) {
        GalleryDetailViewController *pdvc = [[GalleryDetailViewController alloc] initWithContentGallery:gallery];
        [self.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested gallery not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
}

#pragma mark - SFAppSetupViewController Delegate Methods
- (void) setupChangeDownloadPressed {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self dismissViewControllerAnimated:NO completion:^{
            SFDownloadConfigViewController *downloadSetupViewController = [[SFDownloadConfigViewController alloc] initAsModal];
            [self presentViewController:downloadSetupViewController animated:YES completion:nil];
        }];
    } else {
        [self dismissPopovers];
        SFDownloadConfigViewController *downloadSetupViewController = [[SFDownloadConfigViewController alloc] initAsModal];
        [self presentViewController:downloadSetupViewController animated:YES completion:nil];
    }
}

- (void) setupChangePasswordPressed {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self dismissViewControllerAnimated:NO completion:^{
            SFChangePasswordViewController *changePwViewController = [[SFChangePasswordViewController alloc] init];
            [self presentViewController:changePwViewController animated:YES completion:nil];
        }];
    } else {
        [self dismissPopovers];
        SFChangePasswordViewController *changePwViewController = [[SFChangePasswordViewController alloc] init];
        [self presentViewController:changePwViewController animated:YES completion:nil];
    }
}

- (void) setupLogoutPressed {
    [self dismissPopovers];
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:1];
    SFLoginViewController *loginVC = [[SFLoginViewController alloc] init];
    [viewControllers addObject:loginVC];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

#pragma mark - Private methods
- (void) dismissPopovers {
    PortfolioDetailView *pdv = (PortfolioDetailView *)self.view;
    if (pdv.detailFavoritesPopover && pdv.detailFavoritesPopover.isPopoverVisible) {
        [pdv.detailFavoritesPopover dismissPopoverAnimated:NO];
    }
    if (pdv.detailSearchPopover && pdv.detailSearchPopover.isPopoverVisible) {
        [pdv.detailSearchPopover dismissPopoverAnimated:NO];
    }
    if (pdv.hierarchyPopover && pdv.hierarchyPopover.isPopoverVisible) {
        [pdv.hierarchyPopover dismissPopoverAnimated:NO];
    }
    if (pdv.setupPopover && pdv.setupPopover.isPopoverVisible) {
        [pdv.setupPopover dismissPopoverAnimated:NO];
    }
}

- (void) backToMain {
    if (self.navigationController) {
        CATransition* transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction
                                     functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionReveal;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (PortfolioDetailView *) contentView {
    return (PortfolioDetailView *)self.view;
}

@end

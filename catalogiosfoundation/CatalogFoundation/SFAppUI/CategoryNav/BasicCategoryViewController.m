//
//  BasicCategoryViewController.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 1/29/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import "BasicCategoryViewController.h"
#import "OPIFoundation.h"

#import "AbstractPortfolioViewController.h"

#import "DetailFavoritesViewController.h"
#import "DetailSearchViewController.h"
#import "HierarchyNavigationViewController.h"

#import "CompanyWebViewController.h"
#import "SketchPadController.h"
#import "SFLoginViewController.h"
#import "SFDownloadConfigViewController.h"
#import "SFChangePasswordViewController.h"
#import "GalleryDetailViewController.h"

#import "SFAppConfig.h"

#import "ContentLookup.h"

#import "Reachability.h"
#import "AlertUtils.h"
#import "UIImage+CatalogFoundationResourceImage.h"

@interface BasicCategoryViewController ()

- (void) backToMain;
- (void) dismissPopovers;

@end

@implementation BasicCategoryViewController
@synthesize categoryPath;
@synthesize overlayController;
@synthesize detailFavoritesPopover;
@synthesize detailSearchPopover;
@synthesize hierarchyPopover;
@synthesize setupPopover;

#pragma mark - init/dealloc
- (id) initWithCategoryPath:(id<ContentViewBehavior>)path {
    self = [super init];
    if (self) {
        if (path) {
            categoryPath = path;
        } else {
            categoryPath = nil;
        }
        
        // Set up title for use in the hierarchy navigation
        NSString *pathTitle = [categoryPath contentTitle];
        [self setTitle:pathTitle];
        [[self navigationItem] setTitle:pathTitle];
        
        overlayController = [[ExpandOverlayViewController alloc] init];
        overlayController.dismissButton = nil;
        
        // Set up the product favorites popover
        DetailFavoritesViewController *detailFavoritesController = [[DetailFavoritesViewController alloc] init];
        detailFavoritesController.delegate = self;
        self.detailFavoritesPopover = [[UIPopoverController alloc] initWithContentViewController:detailFavoritesController];
        
        // Set up the product search popover
        DetailSearchViewController *detailSearchController = [[DetailSearchViewController alloc] init];
        detailSearchController.delegate = self;
        self.detailSearchPopover = [[UIPopoverController alloc] initWithContentViewController:detailSearchController];
        
        // Set up the hierarchy navigation popover
        HierarchyNavigationViewController *hierarchyController = [[HierarchyNavigationViewController alloc] init];
        hierarchyController.delegate = self;
        hierarchyController.rootLevelVCAtTop = NO;
        self.hierarchyPopover = [[UIPopoverController alloc] initWithContentViewController:hierarchyController];
        
        SFAppSetupViewController *setupViewController = [[SFAppSetupViewController alloc] init];
        setupViewController.delegate = self;
        self.setupPopover = [[UIPopoverController alloc] initWithContentViewController:setupViewController];
    }
    return self;
}



#pragma mark - View Lifecycle Methods
- (void) loadView {
    PortfolioLevelView *mainView = [[PortfolioLevelView alloc] initWithFrame:CGRectZero navController:[self navigationController] andLevelPath:categoryPath];
    
    BasicCategoryViewConfig *catConfig = [[SFAppConfig sharedInstance] getBasicCategoryViewConfig];
    
    if (catConfig.mainViewBgImageNamed) {
        mainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage contentFoundationResourceImageNamed:catConfig.mainViewBgImageNamed]];
    } else {
        mainView.backgroundColor = catConfig.mainViewBgColor;
    }
    
    mainView.delegate = self;
    mainView.thumbnailDelegate = self;
    
    [self setView:mainView];
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
    HierarchyNavigationViewController *hnvc = (HierarchyNavigationViewController *)self.hierarchyPopover.contentViewController;
    hnvc.navController = self.navigationController;
    
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
    
    //[[self contentView] loadLevelThumbnails];
    
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
    
    // Call super last
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    //Call super first
    [super viewDidDisappear:animated];
}

#pragma mark - Rotation Support
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[SFAppConfig sharedInstance] getCategoryNavViewControllerLandscapeOnly]) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[SFAppConfig sharedInstance] getCategoryNavViewControllerLandscapeOnly]) {
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

#pragma mark -
#pragma mark ContentThumbnailDelegate Methods
- (void) thumbnailTapped:(ProductThumbnailView *)tappedThumbnailView {
    id<ContentViewBehavior> itemPath = tappedThumbnailView.itemContentPath;
    NSLog(@"Title for tapped thumbnail: %@", [itemPath contentTitle]);
    
    BOOL isProductDetailPath = [[itemPath contentType] isEqualToString:CONTENT_TYPE_PRODUCT];
    BOOL isIndustryDetailPath = [[itemPath contentType] isEqualToString:CONTENT_TYPE_INDUSTRY];
    BOOL isGalleryDetailPath = [[itemPath contentType] isEqualToString:CONTENT_TYPE_GALLERY];
    
    NSLog(@"Path %@ a product detail path.", (isProductDetailPath == YES) ? @"is" : @"is not");
    NSLog(@"Path %@ a industry detail path.", (isIndustryDetailPath == YES) ? @"is" : @"is not");
    NSLog(@"Path %@ a gallery detail path.", (isGalleryDetailPath == YES) ? @"is" : @"is not");
    
    if (isProductDetailPath || isIndustryDetailPath) {
        AbstractPortfolioViewController *pdvc = (AbstractPortfolioViewController *) [[SFAppConfig sharedInstance] getPortfolioDetailViewController:itemPath];
        [self.navigationController pushViewController:pdvc animated:YES];
        // Bring it to the front
        if (![[[self contentView] toolbarView] badgeHidden]) {
            [[[self contentView] toolbarView] showBadge];
        }
    } else if (isGalleryDetailPath) {
        AbstractPortfolioViewController *pdvc = (AbstractPortfolioViewController *) [[SFAppConfig sharedInstance]getPortfolioGalleryViewController:itemPath];
        [self.navigationController pushViewController:pdvc animated:YES];
        // Bring it to the front
        if (![[[self contentView] toolbarView] badgeHidden]) {
            [[[self contentView] toolbarView] showBadge];
        }
        
    } else {
        AbstractCategoryViewController *nextLevel = (AbstractCategoryViewController *) [[SFAppConfig sharedInstance] getCategoryNavViewController:itemPath];
        [[self navigationController] pushViewController:nextLevel animated:YES];
    }
    
}

#pragma mark -
#pragma mark ContentSyncDelegate Methods
- (void) syncStarted:(ContentSyncManager *)syncManager isFullSync:(BOOL)isFullSync {
    if (isFullSync) {
        Reachability *internetReach = [Reachability reachabilityForInternetConnection];
        if ([internetReach isReachableViaWiFi]) {
            [self backToMain];
        }
    } else {
        // Show the badge by bringing it to the front
        [[[self contentView] toolbarView] showBadge];
    }
}

- (void) syncActionsInitialized:(ContentSyncActions *)syncActions {
    // Change badge text to show all items to apply - downloads remaining
    NSInteger changesBeforeDownload = [syncActions totalItemsToApply] - [syncActions totalItemsToDownload];
    [[self contentView] updateBadgeText:[NSString stringWithFormat:@"%ld", (long)changesBeforeDownload]];
    
    if ([[self contentView]progressView]) {
        [[[self contentView] progressView] setTotalContentChanges:[syncActions totalItemsToApply]];
        [[[self contentView] progressView] setAppliedContentChanges:changesBeforeDownload];
    }
}

- (void) syncProgress:(ContentSyncManager *)syncManager currentChange:(NSInteger)currentChangeIndex totalChanges:(NSInteger)totalChangeCount {
    // Change badge text to show all items to apply - downloads remaining
    [[self contentView ]updateBadgeText:[NSString stringWithFormat:@"%ld", (long)currentChangeIndex]];
    
    if ([[self contentView] progressView]) {
        [[[self contentView] progressView] setAppliedContentChanges:currentChangeIndex];
    }
}

- (void) syncCompleted:(ContentSyncManager *)syncManager syncStatus:(SyncCompletionStatus)syncStatus {
    if (syncStatus == SYNC_STATUS_OK) {
        if ([[[[self contentView] toolbarView] badgeText] isEqualToString:@"0"]) {
            [AlertUtils showModalAlertMessage:@"No Changes since last update." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
            [[[self contentView] toolbarView] hideBadge];
        }
    } else if (syncStatus == SYNC_NO_WIFI) {
        [AlertUtils showModalAlertMessage:@"A WIFI Connection is required to sync." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
        [[[self contentView] toolbarView] hideBadge];
    }
    else if (syncStatus == SYNC_STATUS_FAILED) {
        NSString *titleStr = [[SFAppConfig sharedInstance] getAppAlertTitle];
        [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Cannot update %@ content at this time due to connection failure.  Please contact %@ if problem persists.", titleStr, titleStr] withTitle:titleStr];
        [[[self contentView] toolbarView] hideBadge];
    }
    else if (syncStatus == SYNC_AUTHORIZATION_FAILED) {
        NSString *titleStr = [[SFAppConfig sharedInstance] getAppAlertTitle];
        [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Cannot update %@ content at this time due to authorization failure.  Please check your username and password and contact %@ if problem persists.", titleStr, titleStr] withTitle:titleStr];
        [[[self contentView] toolbarView] hideBadge];
    }
    
    [[[self contentView] toolbarView] dismissPopover];
    
    // Is the overlay (Product Details View) present.  Make sure that toolbar is dismissed as well.
    // TODO
//    if (overlayController.overlayView && [overlayController.overlayView isMemberOfClass:[ProductDetailView class]]) {
//        [((ProductDetailView *) overlayController.overlayView) hideToolbarPopover];
//    }
}

#pragma mark - PortfolioLevelViewDelegate methods
- (void) toolbarButtonTapped:(id)toolbarButton {
    switch ([toolbarButton tag]) {
        case 7:
        {
            [self dismissPopovers];
            UIButton *button = (UIButton *)toolbarButton;
            [setupPopover presentPopoverFromRect:button.frame inView:[[[self contentView] toolbarView] rightInsetView] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            break;
        }
        case 6:
        {
            [self dismissPopovers];
            [self backToMain];
            break;
        }
        case 5:
        {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 4:
        {
            CompanyWebViewController *webViewController = [[CompanyWebViewController alloc]
                                                           initWithUrl: [NSURL URLWithString:[[SFAppConfig sharedInstance] getContentInfoToolbarConfig].webBtnLink ]
                                                           andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
            webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:webViewController animated:YES completion:NULL];
            break;
        }
        case 3:
        {
            [self dismissPopovers];
            UIButton *button = (UIButton *)toolbarButton;
            [detailFavoritesPopover presentPopoverFromRect:button.frame inView:[[[self contentView] toolbarView] rightInsetView] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            break;
        }
        case 2:
        {
            [self dismissPopovers];
            UIButton *button = (UIButton *)toolbarButton;
            [detailSearchPopover presentPopoverFromRect:button.frame inView:[[[self contentView] toolbarView] rightInsetView] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            break;
        }
        case 1:
        {
            SketchPadController *sketchPadController = [[SketchPadController alloc]
                                                        initWithImage:nil
                                                        tintColor:[[SFAppConfig sharedInstance] getSketchViewTintColor]
                                                        titleFont:nil
                                                        brand:[[SFAppConfig sharedInstance] getBrandTitle]
                                                        andBgColor:[[SFAppConfig sharedInstance] getSketchViewBgColor]];
            
            [self presentViewController:sketchPadController animated:YES completion:NULL];
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
            UIButton *button = (UIButton *)toolbarButton;
            [hierarchyPopover presentPopoverFromRect:button.frame
                                              inView:[[self contentView] toolbarView]
                            permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            break;
        }
        default:
        {
            break;
        }
    }
}

-(void) selectedSyncAction:(SyncActionType)syncAction {
    if (syncAction == SYNC_CONTENT_NOW) {
        [[ContentSyncManager sharedInstance] performSync];
    } else if (syncAction == SYNC_APPLY_CHANGES) {
        [ContentSyncManager sharedInstance].syncDoApplyChanges = YES;
        [self backToMain];
    }
}

#pragma mark - HierarchyNavigationViewControllerDelegate methods
- (id<ContentViewBehavior>) contentForNavigationDisplay {
    return categoryPath;
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
- (void)favoritesViewController:(DetailFavoritesViewController *)pfvc didRequestProduct:(NSString *)productId {
    
    [self dismissPopovers];
    id<ContentViewBehavior> product = [[[ContentLookup sharedInstance] impl] lookupProduct:productId];
    
    if (product) {
        AbstractPortfolioViewController *pdvc = (AbstractPortfolioViewController *) [[SFAppConfig sharedInstance] getPortfolioDetailViewController:product];
        //pdvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        //[self.navigationController presentModalViewController:pdvc animated:YES];
        [self.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested product not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
    
}

- (void)favoritesViewController:(DetailFavoritesViewController *)pfvc didRequestIndustry:(NSString *)industryId {
    
    [self dismissPopovers];
    id<ContentViewBehavior> industry = [[[ContentLookup sharedInstance] impl] lookupIndustry:industryId];
    
    if (industry) {
        AbstractPortfolioViewController *pdvc = (AbstractPortfolioViewController *) [[SFAppConfig sharedInstance] getPortfolioDetailViewController:industry];
        //pdvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        //[self.navigationController presentModalViewController:pdvc animated:YES];
        [self.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested industry not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
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
    // Categories cannot be added as favorites at this time
    return NO;
}

#pragma mark - DetailSearchViewControllerDelegate methods
- (void) searchViewController:(DetailSearchViewController *)psvc didRequestProduct:(NSString *)productId {
    
    [self dismissPopovers];
    id<ContentViewBehavior> product = [[[ContentLookup sharedInstance] impl] lookupProduct:productId];
    
    if (product) {
        AbstractPortfolioViewController *pdvc = (AbstractPortfolioViewController *) [[SFAppConfig sharedInstance] getPortfolioDetailViewController:product];
        //pdvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        //[self.navigationController presentModalViewController:pdvc animated:YES];
        [self.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested product not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
    
}

- (void) searchViewController:(DetailSearchViewController *)psvc didRequestIndustry:(NSString *)industryId {
    
    [self dismissPopovers];
    id<ContentViewBehavior> industry = [[[ContentLookup sharedInstance] impl] lookupIndustry:industryId];
    
    if (industry) {
        AbstractPortfolioViewController *pdvc = (AbstractPortfolioViewController *) [[SFAppConfig sharedInstance] getPortfolioDetailViewController:industry];
        //pdvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        //[self.navigationController presentModalViewController:pdvc animated:YES];
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

#pragma mark - Accessor Methods
- (PortfolioLevelView *) contentView {
    return (PortfolioLevelView *)[self view];
}

#pragma mark - Public Methods

- (void) backToMain {
    if (self.navigationController) {
        CATransition* transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction
                                     functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionReveal;
        
        // disable all the views (so no tapping is allowed)
        [[[self contentView] toolbarView] setUserInteractionEnabled:NO];
        // categoryMainView.userInteractionEnabled = NO;
        // overlayController.overlayView.userInteractionEnabled = NO;
        
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
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
    if (setupPopover && setupPopover.isPopoverVisible) {
        [setupPopover dismissPopoverAnimated:NO];
    }
}


@end

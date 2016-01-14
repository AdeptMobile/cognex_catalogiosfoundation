//
//  TabbedDetailViewController.m
//  CatalogFoundation
//
//  Created by Steve McCoole on 4/10/13.
//  Copyright (c) 2013 Object Partners Inc. All rights reserved.
//

#import "TabbedDetailViewController.h"
#import "OPIFoundation.h"

#import "SFAppConfig.h"
#import "ContentSyncManager.h"
#import "ContentLookup.h"

#import "UIImage+Extensions.h"
#import "UIImage+Resize.h"
#import "UIView+ImageRender.h"
#import "NSNotificationCenter+MainThread.h"
#import "NSDictionary+ContentViewBehavior.h"
#import "UIScreen+Helpers.h"

#import "TabbedDetailView.h"
#import "DetailFavoritesViewController.h"
#import "DetailSearchViewController.h"
#import "HierarchyNavigationViewController.h"
#import "CompanyWebViewController.h"
#import "SketchPadController.h"
#import "AlertUtils.h"
#import "Reachability.h"
#import "PortfolioDetailVideoController.h"
#import "PortfolioDetailVideoControllerConfig.h"
#import "TabbedPortfolioDetailViewConfig.h"
#import "ResourceMoviePlayer.h"
#import "SFLoginViewController.h"
#import "SFDownloadConfigViewController.h"
#import "SFChangePasswordViewController.h"
#import "GalleryDetailViewController.h"

#define TOOLBAR_HEIGHT 44.0f

@interface TabbedDetailViewController ()

- (TabbedDetailView *) contentView;
- (void) moviePlayBackEnd:(NSNotification *)notification;
- (void) moviePlayBackStatus:(NSNotification *)notification;

@end

@implementation TabbedDetailViewController

@synthesize contentProduct;

- (id) initWithContentProduct:(id<ContentViewBehavior>)aContentProduct {
    self = [super init];
    if (self) {
        contentProduct = aContentProduct;
        
        // Set up title for use in the hierarchy navigation
        NSString *pathTitle = [aContentProduct contentTitle];
        [self setTitle:pathTitle];
        [[self navigationItem] setTitle:pathTitle];
        self.moviePlaying = NO;
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (TabbedDetailView *) contentView {
    return (TabbedDetailView *)self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.    
    TabbedDetailView *detailView = [[TabbedDetailView alloc] initWithFrame:CGRectZero productNavController:(UINavigationController *)self andContentProduct:contentProduct];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackEnd:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStatus:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
}


- (void) viewWillAppear:(BOOL)animated {
    TabbedDetailView *detailView = (TabbedDetailView *)self.view;
    HierarchyNavigationViewController *hierarchyController = (HierarchyNavigationViewController *)detailView.hierarchyPopover.contentViewController;
    hierarchyController.navController = self.navigationController;
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"contentProductViewed" object:self userInfo:[NSDictionary dictionaryFromContentViewBehavior:contentProduct]];

    if (self.moviePlaying == NO) {
        [detailView addViewsOnAppear];
        detailView.resourcePreviewView.mailSetupDelegate = self;
    }
    
	// Call super last
	[super viewWillAppear:animated];

    [[[self contentView] resourceMenuView] updateMenuSelection];

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
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect screen = [UIScreen rectForScreenView:orientation];
    CGSize size = screen.size;
    
    [[self contentView] resizeBadge:size];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    // Unregister as a sync delegate (This ensures the controller will be deallocated)
    [[ContentSyncManager sharedInstance] unRegisterSyncDelegate:self];
    
    [[self contentView] stopLoadingPreviews];
    
    // Call super last
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    //Call super first
    [super viewDidDisappear:animated];
    
    if (self.moviePlaying == NO) {
        TabbedDetailView *detailView = (TabbedDetailView *)self.view;
        [detailView removeViewsOnDisappear];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - NSNotification Methods
- (void) moviePlayBackStatus:(NSNotification *)notification {
    self.moviePlaying = YES;
}

- (void) moviePlayBackEnd:(NSNotification *)notification {
    self.moviePlaying = NO;
}

#pragma mark - MailSetupDelegate Methods
- (MFMailComposeViewController *)setupEmailForContentItem:(ContentItem *)contentItem {
    TabbedPortfolioDetailViewConfig *config = [[SFAppConfig sharedInstance] getTabbedPortfolioDetailViewConfig];
    
    MFMailComposeViewController *emailDialog = nil;
    if ([contentProduct hasResources]) {
        for (id<ContentViewBehavior>resourceGroup in [contentProduct contentResources]) {
            if (config.mailResourceGroup && [[resourceGroup contentTitle] caseInsensitiveCompare:config.mailResourceGroup] == NSOrderedSame) {
                if ([resourceGroup hasResourceItems]) {
                    for (id<ContentViewBehavior>resourceItem in [resourceGroup contentResourceItems]) {
                        if ([[resourceItem contentFilePath] hasSuffix:contentItem.path]) {
                            emailDialog = [[MFMailComposeViewController alloc] init];
                            if (config.mailRecipient) {
                                [emailDialog setToRecipients:[NSArray arrayWithObject:config.mailRecipient]];
                            }
                            [emailDialog setSubject:[NSString stringWithFormat:config.mailSubjectTemplate, contentItem.name]];
                            NSString *emailBody = [NSString
                                                   stringWithFormat:config.mailTemplate,
                                                   [resourceItem contentTitle]];
                            [emailDialog setMessageBody:emailBody isHTML:YES];
                        }
                    }
                }
            }
        }
    }
    return emailDialog;
}

#pragma mark -
#pragma mark ContentInfoToolbarDelegate Methods
- (void) toolbarButtonTapped:(id)toolbarButton {
    switch ([toolbarButton tag]) {
        case 7:
        {
            TabbedDetailView *pdv = (TabbedDetailView *)self.view;
            [self dismissPopovers];
            UIButton *button = (UIButton *)toolbarButton;
            [pdv.setupPopover presentPopoverFromRect:button.frame inView:pdv.contentToolbar.rightInsetView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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
            NSURL *webUrl = [NSURL URLWithString:[[[SFAppConfig sharedInstance] getContentInfoToolbarConfig] webBtnLink]];
            CompanyWebViewController *webViewController = [[CompanyWebViewController alloc] initWithUrl:webUrl andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig] ];
            webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self.navigationController presentViewController:webViewController animated:YES completion:NULL];
            break;
        }
        case 3:
        {      
            // Product Favorites button
            [self dismissPopovers];
            TabbedDetailView *pdv = (TabbedDetailView *)self.view;
            UIButton *button = (UIButton *)toolbarButton;
            [pdv.detailFavoritesPopover presentPopoverFromRect:button.frame inView:pdv.contentToolbar.rightInsetView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            break;
        }
        case 2:
        {
            // Product Search button
            [self dismissPopovers];
            TabbedDetailView *pdv = (TabbedDetailView *)self.view;
            UIButton *button = (UIButton *)toolbarButton;
            [pdv.detailSearchPopover presentPopoverFromRect:button.frame inView:pdv.contentToolbar.rightInsetView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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
            TabbedDetailView *pdv = (TabbedDetailView *)self.view;
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
        if ([syncManager hasSyncItemsToApply] == NO) {
            if (self.isViewLoaded && self.view.window) {
                [AlertUtils showModalAlertMessage:@"No changes since last update." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
            }
            [[[self contentView] contentToolbar] hideBadge];
        }
    } else if (syncStatus == SYNC_NO_WIFI) {
        if (self.isViewLoaded && self.view.window) {
            NSString *alertTitle = [[SFAppConfig sharedInstance] getAppAlertTitle];
            [AlertUtils showModalAlertMessage:@"A WIFI Connection is required to sync." withTitle:alertTitle];
        }
        [[[self contentView] contentToolbar] hideBadge];
    }
    else if (syncStatus == SYNC_STATUS_FAILED) {
        if (self.isViewLoaded && self.view.window) {
            NSString *titleStr = [[SFAppConfig sharedInstance] getAppAlertTitle];
            [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Cannot update %@ content at this time due to connection failure.  Please contact %@ if problem persists.", titleStr, titleStr] withTitle:titleStr];
        }
        [[[self contentView] contentToolbar] hideBadge];
    }
    else if (syncStatus == SYNC_AUTHORIZATION_FAILED) {
        if (self.isViewLoaded && self.view.window) {
            NSString *titleStr = [[SFAppConfig sharedInstance] getAppAlertTitle];
            [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Cannot update %@ content at this time due to auhtorization failure.  Please check username and password and contact %@ if problem persists.", titleStr, titleStr] withTitle:titleStr];
        }
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
    
    PortfolioDetailVideoControllerConfig *videoConfig = [[SFAppConfig sharedInstance] getPortfolioDetailVideoControllerConfig];
    
    id<ContentViewBehavior> product = [[[ContentLookup sharedInstance] impl] lookupProduct:productId];
    id<ContentViewBehavior> topCategory = [[[ContentLookup sharedInstance] impl] mainCategoryForProduct:productId];
    
    if (product && ([[product contentTitle] rangeOfString:videoConfig.videoTopCategoryNamed].location != NSNotFound ||
                    [[topCategory contentTitle] rangeOfString:videoConfig.videoTopCategoryNamed].location != NSNotFound)) {
        
        PortfolioDetailVideoController * nextLevel = [[PortfolioDetailVideoController alloc] initWithlevelPath:product];
        [[self navigationController] pushViewController:nextLevel animated:YES];
        
    } else if (product) {
        TabbedDetailViewController *pdvc = [[TabbedDetailViewController alloc] initWithContentProduct:product];
        [self.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested product not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
}

- (void)favoritesViewController:(DetailFavoritesViewController *)pfvc didRequestIndustry:(NSString *)industryId {
    [self dismissPopovers];
    
    PortfolioDetailVideoControllerConfig *videoConfig = [[SFAppConfig sharedInstance] getPortfolioDetailVideoControllerConfig];
    
    id<ContentViewBehavior> industry = [[[ContentLookup sharedInstance] impl] lookupIndustry:industryId];
    id<ContentViewBehavior> topCategory = [[[ContentLookup sharedInstance] impl] mainCategoryForIndustry:industryId];
    
    if (industry && ([[industry contentTitle] rangeOfString:videoConfig.videoTopCategoryNamed].location != NSNotFound ||
                    [[topCategory contentTitle] rangeOfString:videoConfig.videoTopCategoryNamed].location != NSNotFound)) {
        
        PortfolioDetailVideoController * nextLevel = [[PortfolioDetailVideoController alloc] initWithlevelPath:industry];
        [[self navigationController] pushViewController:nextLevel animated:YES];
        
    } else if (industry) {
        TabbedDetailViewController *pdvc = [[TabbedDetailViewController alloc] initWithContentProduct:industry];
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
    // Products can be added as favorites
    return YES;
}

#pragma mark - DetailSearchViewControllerDelegate methods
- (void) searchViewController:(DetailSearchViewController *)psvc didRequestProduct:(NSString *)productId {
    [self dismissPopovers];
    
    PortfolioDetailVideoControllerConfig *videoConfig = [[SFAppConfig sharedInstance] getPortfolioDetailVideoControllerConfig];
    
    id<ContentViewBehavior> product = [[[ContentLookup sharedInstance] impl] lookupProduct:productId];
    id<ContentViewBehavior> topCategory = [[[ContentLookup sharedInstance] impl] mainCategoryForProduct:productId];
    
    if (product && ([[product contentTitle] rangeOfString:videoConfig.videoTopCategoryNamed].location != NSNotFound ||
                    [[topCategory contentTitle] rangeOfString:videoConfig.videoTopCategoryNamed].location != NSNotFound)) {
        
        PortfolioDetailVideoController * nextLevel = [[PortfolioDetailVideoController alloc] initWithlevelPath:product];
        [[self navigationController] pushViewController:nextLevel animated:YES];
        
    } else if (product) {
        TabbedDetailViewController *pdvc = [[TabbedDetailViewController alloc] initWithContentProduct:product];
        //pdvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        //[self presentModalViewController:pdvc animated:YES];
        [self.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested product not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
}

- (void) searchViewController:(DetailSearchViewController *)psvc didRequestIndustry:(NSString *)industryId {
    [self dismissPopovers];
    
    PortfolioDetailVideoControllerConfig *videoConfig = [[SFAppConfig sharedInstance] getPortfolioDetailVideoControllerConfig];
    
    id<ContentViewBehavior> industry = [[[ContentLookup sharedInstance] impl] lookupIndustry:industryId];
    id<ContentViewBehavior> topCategory = [[[ContentLookup sharedInstance] impl] mainCategoryForIndustry:industryId];
    
    if (industry && ([[industry contentTitle] rangeOfString:videoConfig.videoTopCategoryNamed].location != NSNotFound ||
                    [[topCategory contentTitle] rangeOfString:videoConfig.videoTopCategoryNamed].location != NSNotFound)) {
        
        PortfolioDetailVideoController * nextLevel = [[PortfolioDetailVideoController alloc] initWithlevelPath:industry];
        [[self navigationController] pushViewController:nextLevel animated:YES];
        
    } else if (industry) {
        TabbedDetailViewController *pdvc = [[TabbedDetailViewController alloc] initWithContentProduct:industry];
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
    TabbedDetailView *pdv = (TabbedDetailView *)self.view;
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

@end

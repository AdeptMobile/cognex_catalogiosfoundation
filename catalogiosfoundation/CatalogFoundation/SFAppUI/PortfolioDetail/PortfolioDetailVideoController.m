//
//  PortfolioDetailVideoController.h
//  CatalogFoundation
//
//  Created by Chris Pflepsen on 8/27/12.
//
//

#import "PortfolioDetailVideoController.h"
#import "PortfolioDetailVideoControllerConfig.h"

#import "OPIFoundation.h"
#import "ProductLevelScrollView.h"
#import "ContentInfoToolbarView.h"

#import "UIScreen+Helpers.h"
#import "UIImage+Extensions.h"
#import "UIImage+CatalogFoundationResourceImage.h"
#import "UIImage+Alpha.h"
#import "UIApplication+WindowOverlay.h"
#import "NSString+StringFormatters.h"
#import "SFAppConfig.h"
#import "DetailFavoritesViewController.h"
#import "DetailSearchViewController.h"
#import "ContentSyncManager.h"

#import "ContentUtils.h"
#import "ContentViewBehavior.h"
#import "ContentLookup.h"

#import "Reachability.h"
#import "NSNotificationCenter+MainThread.h"
#import "NSDictionary+ContentViewBehavior.h"

#import "CompanyWebViewController.h"
#import "AlertUtils.h"
#import "SketchPadController.h"
#import "DetailFavoritesViewController.h"
#import "DetailSearchViewController.h"
#import "HierarchyNavigationViewController.h"
#import "SFLoginViewController.h"
#import "SFDownloadConfigViewController.h"
#import "SFChangePasswordViewController.h"
#import "GalleryDetailViewController.h"

#import "TabbedDetailViewController.h"
#import "PortfolioDetailVideoController.h"

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@interface PortfolioDetailVideoController (){
    ContentInfoToolbarView *toolbar;
    DetailFavoritesViewController *detailFavoritesController;
    CGFloat yOffset;
}

-(void)popToMainViewController;
- (AFHTTPRequestOperation *) downloadDocument:(NSString *)contentPath Then:(void(^)(AFHTTPRequestOperation *, BOOL, NSError *))block;
- (void) dismissDownloadProgress;
- (void) cancelDownload:(UIButton *)sender;
- (void) playVideo:(id<ContentViewBehavior>)itemPath;

@property (nonatomic, strong) id<ContentViewBehavior> levelPath;

@end

@implementation PortfolioDetailVideoController

@synthesize levelPath, detailFavoritesPopover, detailSearchPopover, hierarchyPopover, setupPopover;

- (id)initWithlevelPath:(id)path{
    self = [super init];
    if (self) {
        // Custom initialization
        PortfolioDetailVideoControllerConfig *config = [[SFAppConfig sharedInstance] getPortfolioDetailVideoControllerConfig];
        
        levelPath = path;
        
        yOffset = 0.0f;
        UIImageView *backgroundImageView;
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            // For iOS 7 or later.  This moves things out from under the status bar.
            yOffset = 20.0f;
            backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        } else {
            backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)];
        }
        
        if (config.mainBgImageNamed) {
            backgroundImageView.image = [UIImage contentFoundationResourceImageNamed:config.mainBgImageNamed];
        } else {
            self.view.backgroundColor = config.mainBgColor;
        }
        
        UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 8 + yOffset, 120, 44)];
        logoView.userInteractionEnabled = YES;
        logoView.image = [UIImage contentFoundationResourceImageNamed:config.leftLogoNamed];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(home:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [logoView addGestureRecognizer:tapGesture];
        
        toolbar = [[ContentInfoToolbarView alloc] initWithFrame:CGRectMake(162, 8 + yOffset, 832, 44)];
        toolbar.delegate = self;
        
        UILabel *productsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 112 + yOffset, 964, 40)];
        productsLabel.font = [UIFont fontWithName:config.mainTitleFont size:40.0f];
        productsLabel.text = [[levelPath contentTitle] uppercaseString];
        productsLabel.backgroundColor = [UIColor clearColor];
        productsLabel.textColor = config.mainTitleFontColor;
        
        UIImage *bottomImage = [UIImage contentFoundationResourceImageNamed:config.mainBottomBarImageNamed];
        UIImageView *bottomBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 720 + yOffset, 1024, 28)];
        bottomBarImageView.image = bottomImage;
        
        
        ProductLevelScrollView *productScrollView = [[ProductLevelScrollView alloc] initWithFrame:CGRectMake(0, 172 + yOffset, 1024, 576) levelPath:levelPath];
        productScrollView.backgroundColor = [UIColor clearColor];
        productScrollView.numThumbsPortrait = config.numThumbsPortrait;
        productScrollView.numThumbsLandscape = config.numThumbsLandscape;
        productScrollView.thumbnailDelegate = self;
        
        UIView *activeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 10)];
        activeView.backgroundColor = config.activeBgColor;
        
        UIView *inactiveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 10)];
        inactiveView.backgroundColor = config.inactiveBgColor;
        
        UIImage *activeImage = nil;
        UIImage *inactiveImage = nil;
        
        UIGraphicsBeginImageContext(activeView.bounds.size);
        [activeView.layer renderInContext:UIGraphicsGetCurrentContext()];
        activeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIGraphicsBeginImageContext(inactiveView.bounds.size);
        [inactiveView.layer renderInContext:UIGraphicsGetCurrentContext()];
        inactiveImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [productScrollView.levelPageControl setActiveImage:activeImage];
        [productScrollView.levelPageControl setInactiveImage:inactiveImage];
        
        [self.view addSubview:backgroundImageView];
        [self.view addSubview:logoView];
        [self.view addSubview:toolbar];
        [self.view addSubview:productsLabel];
        [self.view addSubview:bottomBarImageView];
        [self.view addSubview:productScrollView];
        
        // Set up the product favorites popover
        detailFavoritesController = [[DetailFavoritesViewController alloc] init];
        detailFavoritesController.delegate = self;
        self.detailFavoritesPopover = [[UIPopoverController alloc] initWithContentViewController:detailFavoritesController];
        
        // Set up the product search popover
        DetailSearchViewController *detailSearchController = [[DetailSearchViewController alloc] init];
        detailSearchController.delegate = self;
        self.detailSearchPopover = [[UIPopoverController alloc] initWithContentViewController:detailSearchController];
        
        // Set up the hierarchy navigation popover
        HierarchyNavigationViewController *hierarchyController = [[HierarchyNavigationViewController alloc] init];
        hierarchyController.rootLevelVCAtTop = NO;
        hierarchyController.delegate = self;
        self.hierarchyPopover = [[UIPopoverController alloc] initWithContentViewController:hierarchyController];
        
        SFAppSetupViewController *setupViewController = [[SFAppSetupViewController alloc] init];
        setupViewController.delegate = self;
        self.setupPopover = [[UIPopoverController alloc] initWithContentViewController:setupViewController];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    HierarchyNavigationViewController *hnvc = (HierarchyNavigationViewController *)self.hierarchyPopover.contentViewController;
    hnvc.navController = self.navigationController;
    
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
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect screen = [UIScreen rectForScreenView:orientation];
    CGSize size = screen.size;
    
    [self resizeBadge:size];
}

- (void) viewWillDisappear:(BOOL)animated {
    // Unregister as a sync delegate (This ensures the controller will be deallocated)
    [[ContentSyncManager sharedInstance] unRegisterSyncDelegate:self];
    
    // Call super last
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Public Methods

- (void) updateBadgeText: (NSString *) newBadgeText {
    [toolbar updateBadgeText:newBadgeText];
}

- (void) resizeBadge:(CGSize)screenSize {
    [toolbar resizeBadge];
}

#pragma mark - Navigation

-(void)popToMainViewController{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - ContentSyncDelegate Methods
#pragma mark - ContentSyncDelegate Methods
- (void) syncStarted:(ContentSyncManager *)syncManager isFullSync:(BOOL)isFullSync {
    if (isFullSync) {
        Reachability *internetReach = [Reachability reachabilityForInternetConnection];
        if ([internetReach isReachableViaWiFi]) {
            [self backToMain];
        }
    } else {
        [toolbar showBadge];
    }
}

- (void) syncActionsInitialized:(ContentSyncActions *)syncActions {
    // Change badge text to show all items to apply - downloads remaining
    NSInteger changesBeforeDownload = [syncActions totalItemsToApply] - [syncActions totalItemsToDownload];
    [self updateBadgeText:[NSString stringWithFormat:@"%ld", (long)changesBeforeDownload]];
}

- (void) syncProgress:(ContentSyncManager *)syncManager currentChange:(NSInteger)currentChangeIndex totalChanges:(NSInteger)totalChangeCount {
    // Change badge text to show all items to apply - downloads remaining
    [self updateBadgeText:[NSString stringWithFormat:@"%ld", (long)currentChangeIndex]];
}

- (void) syncCompleted:(ContentSyncManager *)syncManager syncStatus:(SyncCompletionStatus)syncStatus {
    if (syncStatus == SYNC_STATUS_OK) {
        if ([syncManager hasSyncItemsToApply] == NO) {
            if (self.isViewLoaded && self.view.window) {
                [AlertUtils showModalAlertMessage:@"No changes since last update." withTitle:[[SFAppConfig  sharedInstance] getAppAlertTitle]];
            }
            [toolbar hideBadge];
        }
    } else if (syncStatus == SYNC_NO_WIFI) {
        if (self.isViewLoaded && self.view.window) {
            NSString *alertTitle = [[SFAppConfig sharedInstance] getAppAlertTitle];
            [AlertUtils showModalAlertMessage:@"A WIFI Connection is required to sync." withTitle:alertTitle];
        }
        [toolbar hideBadge];
    }
    else if (syncStatus == SYNC_STATUS_FAILED) {
        if (self.isViewLoaded && self.view.window) {
            NSString *titleStr = [[SFAppConfig sharedInstance] getAppAlertTitle];
            [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Cannot update %@ content at this time due to connection failure.  Please contact %@ if problem persists.", titleStr, titleStr] withTitle:titleStr];
        }
        [toolbar hideBadge];
    }
    else if (syncStatus == SYNC_AUTHORIZATION_FAILED) {
        if (self.isViewLoaded && self.view.window) {
            NSString *titleStr = [[SFAppConfig sharedInstance] getAppAlertTitle];
            [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Cannot update %@ content at this time due to authorization failure.  Please check your username and password and contact %@ if problem persists.", titleStr, titleStr] withTitle:titleStr];
        }
        [toolbar hideBadge];
    }
    
    [self dismissPopovers];
}

- (void) selectedSyncAction:(SyncActionType)syncAction {
    if (syncAction == SYNC_CONTENT_NOW) {
        [[ContentSyncManager sharedInstance] performSync];
    } else if (syncAction == SYNC_APPLY_CHANGES) {
        [ContentSyncManager sharedInstance].syncDoApplyChanges = YES;
        [self backToMain];
    }
}


#pragma mark - PortfolioLevelViewDelegate methods
- (void) toolbarButtonTapped:(id)toolbarButton {
    ContentInfoToolbarConfig *config = [[SFAppConfig sharedInstance] getContentInfoToolbarConfig];
    
    switch ([toolbarButton tag]) {
        case 7:
        {
            [self dismissPopovers];
            UIButton *button = (UIButton *)toolbarButton;
            [self.setupPopover presentPopoverFromRect:button.frame inView:toolbar.rightInsetView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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
            CompanyWebViewController *webViewController = [[CompanyWebViewController alloc] initWithUrl:[NSURL URLWithString:config.webBtnLink] andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
            webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:webViewController animated:YES completion:NULL];
            break;
        }
        case 3:
        {
            [self dismissPopovers];
            UIButton *button = (UIButton *)toolbarButton;
            [detailFavoritesPopover presentPopoverFromRect:button.frame inView:toolbar.rightInsetView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            break;
        }
        case 2:
        {
            [self dismissPopovers];
            UIButton *button = (UIButton *)toolbarButton;
            [detailSearchPopover presentPopoverFromRect:button.frame inView:toolbar.rightInsetView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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
                                              inView:toolbar
                            permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            break;
        }
        default:
        {
            break;
        }
    }
}

#pragma mark - HierarchyNavigationViewControllerDelegate methods
- (id<ContentViewBehavior>) contentForNavigationDisplay {
    return levelPath;
}

- (void) hierarchyNavigationController:(HierarchyNavigationViewController *)hnvc didSelectControllerIndex:(NSInteger)controllerIndex {
    [self dismissPopovers];
    NSArray *viewControllers = [[self navigationController] viewControllers];
    if (viewControllers && [viewControllers count] > 0 && (controllerIndex >= 0 && controllerIndex < [viewControllers count])) {
        UIViewController *vc = (UIViewController *)[viewControllers objectAtIndex:controllerIndex];
        [[self navigationController] popToViewController:vc animated:YES];
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

#pragma mark - Private Methods
- (void) backToMain {
    if (self.navigationController) {
        CATransition* transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction
                                     functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionReveal;
        
        // disable all the views (so no tapping is allowed)
        [toolbar setUserInteractionEnabled:NO];
        // categoryMainView.userInteractionEnabled = NO;
        // overlayController.overlayView.userInteractionEnabled = NO;
        
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

-(void) home:(id)sender; {
    [self backToMain];
}

#pragma mark - Private methods
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

#pragma mark -
#pragma mark ContentThumbnailDelegate Methods
- (void) thumbnailTapped:(ProductThumbnailView *)tappedThumbnailView {
    id<ContentViewBehavior> itemPath = tappedThumbnailView.itemContentPath;
    NSLog(@"Title for tapped thumbnail: %@", [itemPath contentTitle]);
    BOOL isProductDetailPath = [itemPath contentType] && [[itemPath contentType] caseInsensitiveCompare:CONTENT_TYPE_PRODUCT] == NSOrderedSame;
    BOOL isVideo = [itemPath contentType] && [[itemPath contentType] caseInsensitiveCompare:CONTENT_TYPE_MOVIE] == NSOrderedSame;
    NSLog(@"Path %@ a product detail path.", (isProductDetailPath == YES) ? @"is" : @"is not");
    if (isProductDetailPath) {
        //Product View
        NSLog(@"Product Level View");
        PortfolioDetailVideoController *categoryVC = [[PortfolioDetailVideoController alloc]initWithlevelPath:itemPath];
        [self.navigationController pushViewController:categoryVC animated:YES];
        
        
    } else if (isVideo) {
        if ([ContentUtils fileExists:[itemPath contentFilePath]]) {
            [self playVideo:itemPath];
        } else {
            // Make sure we don't have a sync going or ready to unpack.
            ContentSyncManager *manager = [ContentSyncManager sharedInstance];
            if (manager.isSyncInProgress == YES || manager.isSyncDoApplyChanges == YES || manager.hasSyncItemsToApply == YES) {
                [AlertUtils showModalAlertMessage:@"Current Sync must finish and be applied before downloading file." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
                return;
            }
            // Download document and then try to open it.
            currentOperation = [self downloadDocument:[itemPath contentFilePath] Then:^(AFHTTPRequestOperation *operation, BOOL cancelled, NSError *error) {
                if (error == nil && cancelled == NO) {
                    if ([itemPath contentThumbNail]) {
                        tappedThumbnailView.thumbnailImage.image = [UIImage imageWithContentsOfFile:[itemPath contentThumbNail]];
                    } else {
                        tappedThumbnailView.thumbnailImage.image = [ContentUtils itemContentPreviewImage:[itemPath contentFilePath]];
                    }
                    [self playVideo:itemPath];
                    currentOperation = nil;
                } else {
                    if (cancelled) {
                        [AlertUtils showModalAlertMessage:@"Download Cancelled" withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
                    } else {
                        NSString *msg = [NSString stringWithFormat:@"Error: %@ downloading file.", error.localizedDescription];
                        [AlertUtils showModalAlertMessage:msg withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
                    }
                    [ContentUtils removeFile:[itemPath contentFilePath]];
                    currentOperation = nil;
                }
            }];
            
        }
    }
    else {
        //Category View
        PortfolioDetailVideoController *categoryVC = [[PortfolioDetailVideoController alloc]initWithlevelPath:itemPath];
        [self.navigationController pushViewController:categoryVC animated:YES];
    }
    
}

- (void) playVideo:(id<ContentViewBehavior>)itemPath {
    NSLog(@"Video: %@", [itemPath contentFilePath]);
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"contentResourceItemViewed" object:self userInfo:[NSDictionary dictionaryFromContentViewBehavior:itemPath]];
    
    NSURL * url = [NSURL fileURLWithPath: [itemPath contentFilePath]];
    
    player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    //[player setScalingMode:MPMovieScalingModeAspectFit];
    player.view.frame = CGRectMake(0, -20 + yOffset, 1024, 768);
    [player setControlStyle:MPMovieControlStyleFullscreen];
    [player setShouldAutoplay:YES];
    [player setFullscreen:YES];
    [player prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    
    [self.view addSubview:player.view];
}

- (void) moviePlayerLoadStateChanged:(NSNotification *)notification {
    NSLog(@"moviePlayerLoadStateChanged");
}

- (void) moviePlayBackDidFinish:(NSNotification *)notification {
    NSLog(@"moviePlayBackDidFinish");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerDidExitFullscreenNotification
                                                  object:nil];
    
    [player stop];
    [player.view removeFromSuperview];
}

- (void) searchViewController:(DetailSearchViewController *)psvc didRequestProduct:(NSString *)productId {
    [self dismissPopovers];
    
    PortfolioDetailVideoControllerConfig *config = [[SFAppConfig sharedInstance] getPortfolioDetailVideoControllerConfig];
    
    id<ContentViewBehavior> product = [[[ContentLookup sharedInstance] impl] lookupProduct:productId];
    id<ContentViewBehavior> topCategory = [[[ContentLookup sharedInstance] impl] mainCategoryForProduct:productId];
    
    if (product && ([[product contentTitle] rangeOfString:config.videoTopCategoryNamed].location != NSNotFound ||
                    [[topCategory contentTitle] rangeOfString:config.videoTopCategoryNamed].location != NSNotFound)) {
        
        PortfolioDetailVideoController * nextLevel = [[PortfolioDetailVideoController alloc] initWithlevelPath:product];
        [[self navigationController] pushViewController:nextLevel animated:YES];
        
    } else if (product) {
        AbstractPortfolioViewController *pdvc = [[SFAppConfig sharedInstance] getPortfolioDetailViewController:product];
        [self.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested product not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
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

#pragma mark - DetailFavoritesViewControllerDelegate methods
- (void)favoritesViewController:(DetailFavoritesViewController *)pfvc didRequestProduct:(NSString *)productId {
    [self dismissPopovers];
    
    PortfolioDetailVideoControllerConfig *config = [[SFAppConfig sharedInstance] getPortfolioDetailVideoControllerConfig];
    
    id<ContentViewBehavior> product = [[[ContentLookup sharedInstance] impl] lookupProduct:productId];
    id<ContentViewBehavior> topCategory = [[[ContentLookup sharedInstance] impl] mainCategoryForProduct:productId];
    
    if (product && ([[product contentTitle] rangeOfString:config.videoTopCategoryNamed].location != NSNotFound ||
                    [[topCategory contentTitle] rangeOfString:config.videoTopCategoryNamed].location != NSNotFound)) {
        
        PortfolioDetailVideoController * nextLevel = [[PortfolioDetailVideoController alloc] initWithlevelPath:product];
        [[self navigationController] pushViewController:nextLevel animated:YES];
        
    } else if (product) {
        AbstractPortfolioViewController *pdvc = [[SFAppConfig sharedInstance] getPortfolioDetailViewController:product];
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

- (id<ContentViewBehavior>) detailForFavorites { //this is swizzled
    return levelPath;
}

- (BOOL) canAddFavorite {
    // If we have resources then we can be added as a favorite (leaf/product view), otherwise we don't
    // allow it (category view).
    if ([levelPath hasResources]) {
        return YES;
    } else {
        return NO;
    }
}

- (AFHTTPRequestOperation *) downloadDocument:(NSString *)contentPath Then:(void (^)(AFHTTPRequestOperation *, BOOL, NSError *))block {
    
    ContentMetaData *metadata = [[ContentSyncManager sharedInstance] getAppContentMetaData];
    
    if (contentPath) {
        ContentItem *item = [metadata getContentItemAtPath:contentPath];
        
        if (item) {
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            downloadProgressView = [[AlertProgressHUD alloc] initWithFrame:[UIScreen rectForScreenView:orientation]];
            [downloadProgressView setTitle:@"Download"];
            [downloadProgressView setMessage:[NSString stringWithFormat:@"Downloading %@", [item name]]];
            downloadCustomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [downloadProgressView defaultContentWidth], 95.0f)];
            [downloadCustomView setAutoresizingMask:UIViewAutoresizingNone];
            
            
            downloadProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [downloadProgressView defaultContentWidth], 21)];
            [downloadProgressLabel setBackgroundColor:[UIColor clearColor]];
            [downloadProgressLabel setTextColor:[downloadProgressView defaultTextColor]];
            [downloadProgressLabel setTextAlignment:NSTextAlignmentCenter];
            [downloadProgressLabel setText:[NSString stringWithFormat:@"%@ of %@",@"0",@"0"]];
            [downloadProgressLabel setAutoresizingMask:UIViewAutoresizingNone];
            [downloadCustomView addSubview:downloadProgressLabel];
            
            downloadProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
            downloadProgress.frame = CGRectMake(0.0f, 31.0f, [downloadProgressView defaultContentWidth], 10.0f);
            downloadProgress.progressTintColor = [UIColor colorWithRed:0.0f/255.0f green:51.0f/255.0f blue:171.0f/255.0f alpha:1.0f];
            [downloadProgress setAutoresizingMask:UIViewAutoresizingNone];
            [downloadProgress setProgress:0.0f];
            [downloadProgress setBackgroundColor:[UIColor clearColor]];
            [downloadCustomView addSubview:downloadProgress];
            
            downloadCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 51.0f, [downloadProgressView defaultContentWidth], 43.0f)];
            downloadCancelButton.titleLabel.textColor = [downloadProgressView defaultTextColor];
            downloadCancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            [downloadCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
                // For iOS 6.1 or earlier
                UIImage *buttonImage = [UIImage imageResource:@"AlertProgressCancelButtonBackground.png"];
                UIImage *stretchImage = [buttonImage stretchableImageWithLeftCapWidth:buttonImage.size.width / 2.0f topCapHeight:buttonImage.size.height / 2.0f];
                [downloadCancelButton setBackgroundImage:stretchImage forState:UIControlStateNormal];
                UIImage *highlightImage = [UIImage imageResource:@"AlertProgressButtonBackground_Hightlighted.png"];
                UIImage *hightlightStretchImage = [highlightImage stretchableImageWithLeftCapWidth:highlightImage.size.width / 2.0f topCapHeight:highlightImage.size.height / 2.0f];
                [downloadCancelButton setBackgroundImage:hightlightStretchImage forState:UIControlStateHighlighted];
            } else {
                downloadCancelButton.backgroundColor = [UIColor redColor];
            }
            
            [downloadCancelButton addTarget:self action:@selector(cancelDownload:) forControlEvents:UIControlEventTouchUpInside];
            [downloadCustomView addSubview:downloadCancelButton];
            
            downloadProgressView.customView = downloadCustomView;
            
            [[UIApplication sharedApplication] addWindowOverlay:downloadProgressView];
            
            // Make sure parent directory exists before downloading the file
            [ContentUtils createDirForFile:contentPath];
            
            NSURL *downloadUrl = [NSURL URLWithString:[item.downloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSURLRequest *request = [NSURLRequest requestWithURL:downloadUrl];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.outputStream = [NSOutputStream outputStreamToFileAtPath:contentPath append:NO];
            
            [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                long long expectedBytes = (totalBytesExpectedToRead == -1) ? item.fileSize : totalBytesExpectedToRead;
                float progress = (float)((float)totalBytesRead / (float)expectedBytes);
                //NSLog(@"bytesRead: %lu totalBytesRead: %lld totalBytesExpectedToRead %lld expectedBytes: %lld progress: %f", (unsigned long)bytesRead, totalBytesRead, totalBytesExpectedToRead, expectedBytes, progress);
                [downloadProgress setProgress:progress];
                [downloadProgressLabel setText:[NSString stringWithFormat:@"%@ of %@",[NSString formatAsFileSize:totalBytesRead], [NSString formatAsFileSize:expectedBytes]]];
            }];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                // worked
                [self dismissDownloadProgress];
                if (block) {
                    block(operation, NO, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                // didn't work
                [self dismissDownloadProgress];
                if (block) {
                    block(operation, [operation isCancelled], error);
                }
            }];
            
            [operation start];
            return operation;
        }
    }
    return nil;
}

- (void)cancelDownload:(UIButton *)sender {
    if (currentOperation) {
        [currentOperation cancel];
    }
}

- (void) dismissDownloadProgress {
    if (downloadCancelButton) {
        [downloadCancelButton removeFromSuperview];
        downloadCancelButton = nil;
    }
    if (downloadProgress) {
        [downloadProgress removeFromSuperview];
        downloadProgress = nil;
    }
    if (downloadProgressLabel) {
        [downloadProgressLabel removeFromSuperview];
        downloadProgressLabel = nil;
    }
    if (downloadCustomView) {
        [downloadCustomView removeFromSuperview];
        downloadCustomView = nil;
    }
    if (downloadProgressView) {
        [downloadProgressView removeFromSuperview];
        downloadProgressView = nil;
    }
}


@end


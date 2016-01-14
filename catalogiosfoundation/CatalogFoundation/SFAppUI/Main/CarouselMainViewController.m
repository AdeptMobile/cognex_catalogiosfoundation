//
//  CarouselMainViewController.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 1/29/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import "CarouselMainViewController.h"

#import "AbstractCategoryViewController.h"

#import "CompanyInfoHtmlViewController.h"
#import "CompanyWebViewController.h"

// Content Lookup
#import "ContentLookupCoreData.h"
#import "ContentLookup.h"

#import "AlertUtils.h"

#import "UIView+ImageRender.h"
#import "UIView+ViewLayout.h"
#import "UIScreen+Helpers.h"
#import "UIImage+Extensions.h"
#import "NSString+Extensions.h"
#import "NSArray+Helpers.h"
#import "UIImage+Resize.h"

#define INITIAL_CAROUSEL_ARRAY_SIZE 6

#define ELEC_PRODUCT_VIEW_INDEX 0
#define PT_PRODUCT_VIEW_INDEX 1
#define TOLODIFFERENCE_VIEW_INDEX 2
#define TOLOCUSTOM_VIEW_INDEX 3
#define PNEU_PRODUCT_VIEW_INDEX 4

#define ITEMVIEW_WIDTH 467.0f
#define ITEMVIEW_HEIGHT 350.0f
#define ITEMVIEW_REFLECTION_HEIGHT 100.0f

#define CAROUSEL_WIDTH 748.0f
#define CAROUSEL_HEIGHT_WITH_REFLECTION ITEMVIEW_HEIGHT + ITEMVIEW_REFLECTION_HEIGHT
#define CAROUSEL_HEIGHT_NO_REFLECTION ITEMVIEW_HEIGHT

#define PROGRESS_VIEW_HEIGHT 200.0f
#define PROGRESS_VIEW_WIDTH 600.0f

@interface CarouselMainViewController ()

-(void) showProgressBar;
-(void) hideProgressBar;

- (void) resizeView: (UIInterfaceOrientation) interfaceOrientation;

- (void) leftLogoTapped:(UITapGestureRecognizer *) tapGesture;
- (void) rightLogoTapped:(UITapGestureRecognizer *) tapGesture;

- (void) doSyncChanges:(id) selector;

- (void) presentWebView: (NSURL *) url;

- (void) presentCarousel;

- (BOOL)haveDisplayItems;

- (BOOL)initialImageAvailable;

@end


@implementation CarouselMainViewController

#pragma mark - init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        // Custom initialization
        doScrollBy = YES;
        unpackedData = NO;
        
        // Handle to the config
        mainConfig = [[SFAppConfig sharedInstance] getMainCarouselConfig];
        
        // Initally we may have only one fixed item in the array.  Half a dozen is a good starting point
        // for capacity, it will expand as needed.
        carouselItems = [NSMutableArray arrayWithCapacity:INITIAL_CAROUSEL_ARRAY_SIZE];
        
        // Set up title for use in the hierarchy navigation
        NSString *pathTitle = @"Home";
        [self setTitle:pathTitle];
        [[self navigationItem] setTitle:pathTitle];
        
        // SMM Initialize our content lookup strategy.  Right now it can be filesystem based like the
        // original Tolomatic application or use the content-structure.json file and Core Data like
        // SICK.  It is entirely possible that there isn't any content available at this point on the
        // device so the implementations must be able to handle this and respond appropriately.  The
        // app will call for a reload of the data when it unpacks or finishes a sync with the server
        // in order to update everything.
        
        // Choose filesystem or content-structure.json/Core Data based lookups.
        //ContentLookupBase<ContentLookupBehavior> *contentLookupImpl = [[ContentLookupFileSystem alloc] init];
        ContentLookupBase<ContentLookupBehavior> *contentLookupImpl = [[ContentLookupCoreData alloc] init];
        
        [[ContentLookup sharedInstance] setImpl:contentLookupImpl];
        // ContentLookup holds a reference to the implementation so make sure to release it here!
        
        // Read in any data currently available.  If there isn't any at the moment the implementation
        // should respond to a reload later after the data is unpacked or downloaded to the device.
        [[[ContentLookup sharedInstance] impl] setup];
        
    }
    
    return self;
}

- (void)dealloc {
    carouselItems = nil;
    
    mainConfig = nil;
    
}

#pragma mark - View Lifecycle Methods
- (void) loadView {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect frame = [UIScreen rectForScreenView:orientation];
    
    UIView *mainView = [[UIView alloc] initWithFrame:frame];
    
    mainBackgroundImageView = [[UIImageView alloc] initWithFrame:frame];
    mainBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [mainView addSubview:mainBackgroundImageView];
    
    // Configure the Tolomatic logo (add a tap gesture)
    NSString *logoLeft = mainConfig.leftLogoNamed;
    
    if ([NSString isNotEmpty:logoLeft]) {
        UIImage *leftLogoImage = [UIImage imageResource:logoLeft];
        UIImageView *leftLogoImageView = [[UIImageView alloc] initWithImage:leftLogoImage];
        leftIconView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, leftLogoImage.size.width, leftLogoImage.size.height)];
        [leftIconView addSubview:leftLogoImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(leftLogoTapped:)];
        tap.numberOfTapsRequired = 1;
        [leftIconView addGestureRecognizer: tap];
    }
    // Configure the ToloNet logo
    NSString *logoRight = mainConfig.rightLogoNamed;
    
    if ([NSString isNotEmpty:logoRight]) {
        UIImage *rightLogoImage = [UIImage imageResource:logoRight];
        UIImageView *rightLogoImageView = [[UIImageView alloc] initWithImage:rightLogoImage];
        rightIconView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, rightLogoImage.size.width, rightLogoImage.size.height)];
        [rightIconView addSubview:rightLogoImageView];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(rightLogoTapped:)];
        tap2.numberOfTapsRequired = 1;
        [rightIconView addGestureRecognizer: tap2];
    }
    
    [mainView addSubview:leftIconView];
    [mainView addSubview:rightIconView];
 
    mainCarousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    mainCarousel.contentOffset = CGSizeMake(0, 0);
    mainCarousel.delegate = self;
    mainCarousel.type = mainConfig.carouselType;
    mainCarousel.hidden = YES;
 
    mainCarousel.dataSource = self;
 
    [mainView addSubview:mainCarousel];
    
    // Configure the content progress indicator
    contentProgressView = [[ToloContentProgressView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [contentProgressView setupForUnpackContentProgress];
    contentProgressView.totalContentChanges = 0;
    contentProgressView.hidden = YES;
    [mainView addSubview:contentProgressView];
    
    // Configure the sync progress indicator
    syncProgressView = [[SyncProgressHudView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
    syncProgressView.totalSyncFiles = 0;
    syncProgressView.hidden = YES;
    syncProgressView.delegate = self;
    [mainView addSubview:syncProgressView];
    
    // Add the View to highlight when thumbnail is selected
    highlightedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ITEMVIEW_WIDTH, ITEMVIEW_HEIGHT)];
    highlightedView.backgroundColor = [UIColor grayColor];
    highlightedView.alpha = 0.4;
    highlightedView.hidden = YES;
    [mainView addSubview:highlightedView];
    
    [self setView:mainView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showProgressBar)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideProgressBar)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDown];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void) viewWillAppear:(BOOL)animated {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self resizeView:orientation];
    
    // Make sure we hide the progess view
    syncProgressView.hidden = YES;
    
    // See if we need to unpack the contents
    ContentSyncManager *syncMgr = [ContentSyncManager sharedInstance];
    
    [syncMgr registerSyncDelegate:self];
    [syncMgr setUnpackDelegate:self];
    [syncMgr setApplyChangesDelegate:self];
    
    if (syncMgr.syncDoUnpack) {
        [syncMgr unpackContents];
    }
    
    // Determine if we need to apply any changes
    if (syncMgr.syncDoApplyChanges) {
        [syncMgr applyChanges];
    }
    
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
    
    // If there is a sync started show the progress HUD
    ContentSyncManager *syncMgr = [ContentSyncManager sharedInstance];
    if ([syncMgr isSyncInProgress]) {
        [self showProgressBar];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [[ContentSyncManager sharedInstance] unRegisterSyncDelegate:self];
    [[ContentSyncManager sharedInstance] setUnpackDelegate:nil];
    [[ContentSyncManager sharedInstance] setApplyChangesDelegate:nil];
    
    // Call super last
    [super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    //Call super first
    [super viewDidDisappear:animated];
}

#pragma mark - Rotation Support
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self resizeView:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[SFAppConfig sharedInstance] getMainViewControllerLandscapeOnly]) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[SFAppConfig sharedInstance] getMainViewControllerLandscapeOnly]) {
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

#pragma mark - iOS 7 Related methods
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

#pragma mark - Accessor Methods

#pragma mark - Public Methods

#pragma mark -
#pragma mark ContentUnpackDelegate Methods
- (void) unpackItemsDetected:(BOOL)doUnpack {
    if (doUnpack) {
        contentProgressView.hidden = NO;
        mainCarousel.hidden = YES;
    } else {
        [self unpackItemsComplete];
        
        // There are no items to unpack so let us try and kickoff a sync
        [[ContentSyncManager sharedInstance] kickoffScheduledOrOngoingSync];
    }
}

- (void) totalItemsToUnpack:(NSInteger)itemsToUnpack {
    // This will let us know to refresh the carousel when we are done.
    if (itemsToUnpack > 0) {
        unpackedData = YES;
    }
    
    // Hide the carousel
    mainCarousel.hidden = YES;
    
    // Setup the content progress
    [contentProgressView setupForUnpackContentProgress];
    contentProgressView.totalContentChanges = itemsToUnpack;
    contentProgressView.hidden = NO;
}
- (void) unpackedItemsProgress:(NSInteger)currentFileIndex total:(NSInteger)totalFileCount {
    contentProgressView.appliedContentChanges = currentFileIndex;
}

- (void) unpackItemsComplete {
    contentProgressView.hidden = YES;
    contentProgressView.totalContentChanges = 0;
    
    // There are no items to unpack
    [ContentSyncManager sharedInstance].syncDoUnpack = NO;
    
    if (unpackedData) {
        [[[ContentLookup sharedInstance] impl] refresh];
        // Reload data since we just did a sync or unpack.
        if ([self numberOfItemsInCarousel:mainCarousel] > 0) {
            [mainCarousel reloadData];
        }
        
    }
    
    [self presentCarousel];
}

#pragma mark -
#pragma mark ContentSyncApplyChangesDelegate
- (void) applyChangesStarted:(ContentSyncManager *)syncManager {
    mainCarousel.hidden = YES;
    
    [contentProgressView setupForApplySyncChancesProgress];
    contentProgressView.totalContentChanges = [syncManager.syncActions totalItemsToApply];
    contentProgressView.hidden = NO;
}

- (void) applyChangesProgress:(ContentSyncManager *)syncManager currentChange:(NSInteger)currentChangeIndex totalChanges:(NSInteger)totalChangeCount {
    contentProgressView.appliedContentChanges = currentChangeIndex;
}

- (void) applyChangesComplete:(ContentSyncManager *)syncManager {
    // syncButton.enabled = NO;
    
    syncProgressView.hidden = YES;
    contentProgressView.hidden = YES;
    contentProgressView.totalContentChanges = 0;
    
    [[[ContentLookup sharedInstance] impl] refresh];
    // Reload data since we just did a sync or unpack.
    [mainCarousel reloadData];
    
    [self presentCarousel];
    
    [AlertUtils showModalAlertMessage:@"Applying changes is complete!" withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
}

#pragma mark -
#pragma mark ContentSyncDelegate Methods
- (void) syncStarted:(ContentSyncManager *)syncManager isFullSync:(BOOL)isFullSync {
    void (^showSyncStarted)(void) = ^{
        if (isFullSync) {
            syncProgressView.progressLabel.text = @"Full Content Download in Progress...";
        } else {
            syncProgressView.progressLabel.text = @"Content Download in Progress...";
        }
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        showSyncStarted();
    });
}

- (void) syncResetContentDirectory:(ContentSyncManager *)syncManager {
    // We have cleared out all the data, reload the carousel back to the defaults.
    mainCarousel.hidden = YES;
    [[[ContentLookup sharedInstance] impl] refresh];
    [mainCarousel reloadData];
    [self presentCarousel];
}

- (void) syncActionsInitialized:(ContentSyncActions *)syncActions {
    NSInteger changesDownloaded = [syncActions totalItemsToApply] - [syncActions totalItemsToDownload];
    syncProgressView.totalSyncFiles = [syncActions totalItemsToApply];
    syncProgressView.downloadedSyncFiles = changesDownloaded;
}

- (void) syncProgress:(ContentSyncManager *)syncManager currentChange:(NSInteger)currentChangeIndex totalChanges:(NSInteger)totalChangeCount {
    if (syncProgressView.hidden == YES) {
        syncProgressView.totalSyncFiles = totalChangeCount;
        [self showProgressBar];
    }
    
    syncProgressView.downloadedSyncFiles = currentChangeIndex;
}

- (void) syncCompleted:(ContentSyncManager *)syncManager syncStatus:(SyncCompletionStatus)syncStatus {
    
    if ([self haveDisplayItems] == NO && [self initialImageAvailable] == YES ) {
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        // Set the background for the view
        if (mainConfig.bgImagePortrait && UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            mainBackgroundImageView.image = [UIImage imageNamed:mainConfig.bgImagePortrait];
        } else if (mainConfig.bgImageLandscape && UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            mainBackgroundImageView.image = [UIImage imageNamed:mainConfig.bgImageLandscape];
        } else if (mainConfig.bgImage) {
            mainBackgroundImageView.image = [UIImage imageNamed:mainConfig.bgImageLandscape];
        } else {
            if (mainConfig.bgColor) {
                self.view.backgroundColor = mainConfig.bgColor;
            } else {
                self.view.backgroundColor = [UIColor whiteColor];
            }
        }
    }
    
    if (syncStatus == SYNC_STATUS_OK && [syncManager hasSyncItemsToApply] == YES) {
        // Determine if there are errors.  If there are, you should retry
        if ([NSArray isNotEmpty:syncManager.downloadErrorList] > 0) {
            syncProgressView.progressLabel.text = @"Download Completed with errors.  Some downloads failed.  Press and hold icon to send error report.";
            syncProgressView.applyChangesButton.enabled = YES;
        } else {
            syncProgressView.progressLabel.text = @"Download Complete.  Apply Changes by tapping icon on right.";
            syncProgressView.applyChangesButton.enabled = YES;
        }
    } else if (syncStatus == SYNC_STATUS_OK && [syncManager hasSyncItemsToApply] == NO) {
        syncProgressView.progressLabel.text = @"No Changes Since Last Update";
    } else if (syncStatus == SYNC_NO_WIFI) {
        syncProgressView.progressLabel.text = @"A WIFI Connection is required to sync";
    }
    else if (syncStatus == SYNC_STATUS_FAILED) {
        syncProgressView.progressLabel.text = @"Cannot Update at this time due to connection failure";
    }
    else if (syncStatus == SYNC_AUTHORIZATION_FAILED) {
        syncProgressView.progressLabel.text = @"Cannot Update at this time due to authorization failure";
    }

}

#pragma mark - SyncProgressHudViewDelegate methods
- (void) syncProgressHudView:(SyncProgressHudView *)aSyncProgressView applyChangesButtonPressed:(id)applyChangesButton {
    
    // The front page is where the initial sync will be applied.  Allow a partial sync to be applied
    // so a small amount of download errors do not prevent the user from getting started with the app.
    if ([[ContentSyncManager sharedInstance] hasSyncItemsToApply]) {
        syncProgressView.applyChangesButton.enabled = NO;
        syncProgressView.hidden = YES;
        
        ContentSyncManager *syncMgr = [ContentSyncManager sharedInstance];
        syncMgr.syncDoApplyChanges = YES;
        [syncMgr applyChanges];
    }
    else{
        [[ContentSyncManager sharedInstance] performSync];
        syncProgressView.applyChangesButton.enabled = NO;
        syncProgressView.progressLabel.hidden = NO;
    }
    
}

- (void) syncProgressHudView:(SyncProgressHudView *)aSyncProgressView applyChangesButtonLongPressed:(id)applyChangesButton {
    ContentSyncManager * syncMgr = [ContentSyncManager sharedInstance];
    
    if ([NSArray isNotEmpty:syncMgr.detailedDownloadErrorList] > 0) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:[NSString stringWithFormat:@"%@: Download Error Report", [[SFAppConfig sharedInstance] getAppAlertTitle]]];
        [mailViewController setMessageBody:[[syncMgr detailedDownloadErrorList] componentsJoinedByString:@"\n"]  isHTML:NO];
        mailViewController.modalPresentationStyle = UIModalPresentationPageSheet;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:mailViewController animated:YES completion:NULL];
        });
    }
    
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark iCarousel Datasource methods
- (NSUInteger) numberOfItemsInCarousel:(iCarousel *)carousel {
    // NSArray *mainCategories = [[[ContentLookup sharedInstance] impl] mainCategoryPaths];
    // return (mainCategories != nil) ? [mainCategories count] + 1 : 1;
    NSArray *spinners = [[[ContentLookup sharedInstance] impl] mainSpinnerPanels];
    return (spinners != nil) ? [spinners count] : 0;
}

- (UIView *) carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    // Need to double check that there are items in the carousel.  iCarousel calls this method even when there are no items.
    if ([self numberOfItemsInCarousel:carousel] > 0) {
        CGFloat reflectionHeight = 0;
        
        if (mainConfig.isReflectionOn) {
            reflectionHeight = ITEMVIEW_REFLECTION_HEIGHT;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ITEMVIEW_WIDTH, ITEMVIEW_HEIGHT+reflectionHeight)];

        
        // Create the Preview View
        UIView *previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ITEMVIEW_WIDTH, ITEMVIEW_HEIGHT)];
        UIImage *previewImage = nil;
        
        NSArray *mainSpinners = [[[ContentLookup sharedInstance] impl] mainSpinnerPanels];
        
        // Two fixed informational entries
       if (mainSpinners && [mainSpinners count] > 0) {
            id<ContentViewBehavior> contentView = (id<ContentViewBehavior>)[mainSpinners objectAtIndex:index];
            if ([contentView hasImages]) {
                NSString *imagePath = (NSString *)[[contentView contentImages] objectAtIndex:0];
                NSLog(@"Carousel index: %lu using image path: %@", (unsigned long)index, imagePath);
                previewImage = [UIImage imageWithContentsOfFile:imagePath];
            } else {
                previewImage = [UIImage imageResource:@"CarouselDefaultImage.png"];
            }
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, ITEMVIEW_WIDTH-10, ITEMVIEW_HEIGHT-10)];
        imageView.image = [previewImage resizedImage:CGSizeMake(imageView.bounds.size.width, imageView.bounds.size.height) interpolationQuality:kCGInterpolationHigh];
        
        [previewView addSubview:imageView];
        
        previewView.backgroundColor = mainConfig.itemBgColor;
        [previewView applyRoundedStyle: mainConfig.itemBorderColor withShadow:YES];
        
        [view addSubview:previewView];
        
        // Add the reflection view
        if (mainConfig.isReflectionOn) {
            UIImageView *reflectionView =
                [[UIImageView alloc] initWithFrame:CGRectMake(5, ITEMVIEW_HEIGHT, ITEMVIEW_WIDTH-10, ITEMVIEW_REFLECTION_HEIGHT)];
            reflectionView.image = [imageView reflectedImage:ITEMVIEW_REFLECTION_HEIGHT alpha: 1.0];
            
            [view addSubview:reflectionView];
        }

        
        // This is causing the items to be shown transparently in the new version of
        // iCarousel after a sync update.  Don't think we need it.  SMM
        //view.alpha = 0.4;
        
        [carouselItems addObject:view];
        return view;
    }
    
    return nil;
}

#pragma mark -
#pragma mark iCarousel Delegate methods
- (CGFloat) carouselItemWidth:(iCarousel *)carousel {
    return ITEMVIEW_WIDTH;
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel {
    return YES;
}

- (void) carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index; {
    NSInteger currentIndex = carousel.currentItemIndex;
    
    if (index == currentIndex) {
        
        // This serves the purpose of highlighting the thumbnail before the details are expanded into view.
        // Could use a NSOperation as well, but might be overkill for this :-)
        [UIView animateWithDuration:0.1 animations:^ {
            highlightedView.hidden = NO;
        }completion:^(BOOL finished) {
            UIViewController *viewController = nil;
            
            NSArray *mainSpinners = [[[ContentLookup sharedInstance] impl] mainSpinnerPanels];
            id<ContentViewBehavior> selectedSpinner = nil;
            
            // TRL:  Took out the default About Us Spinner and everything is based on the content & structure
            // from the server.
            if (mainSpinners && [mainSpinners count] > 0) {
                selectedSpinner = (id<ContentViewBehavior>)[mainSpinners objectAtIndex:index];
                if ([CONTENT_TYPE_HTML isEqualToString:[selectedSpinner contentType]]) {
                    viewController = [[CompanyInfoHtmlViewController alloc] initWithHtmlPath:[selectedSpinner contentFilePath]
                                                                                   andConfig:[[SFAppConfig sharedInstance] getCompanyInfoHtmlViewConfig]];
                } else {
                    viewController = (AbstractCategoryViewController *) [[SFAppConfig sharedInstance] getCategoryNavViewController:selectedSpinner];
                }
            }
            
            if (viewController) {
                CATransition* transition = [CATransition animation];
                transition.duration = 0.5;
                transition.timingFunction = [CAMediaTimingFunction
                                             functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                transition.subtype = kCATransitionReveal;
                [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
                
                [self.navigationController pushViewController:viewController animated:NO];
            }
            
            highlightedView.hidden = YES;
        }];
    }
}

#pragma mark - Private Methods
-(void) showProgressBar{
    if (syncProgressView.hidden) {
        CGRect startFrame = syncProgressView.frame;
        CGRect offScreen = startFrame;
        
        ContentSyncManager *syncMgr = [ContentSyncManager sharedInstance];
        
        offScreen.origin.y = offScreen.origin.y + offScreen.size.height;
        
        syncProgressView.frame = offScreen;
        syncProgressView.hidden = NO;
        
        if ([NSArray isNotEmpty:syncMgr.downloadErrorList] > 0) {
            syncProgressView.progressLabel.text = @"Download Completed with errors.  Some downloads failed.  Please try again.";
            syncProgressView.applyChangesButton.enabled = YES;
            [syncProgressView.progressView setProgress:1.0];
        } else if ([syncMgr isSyncDoApplyChanges] || (![syncMgr isSyncInProgress] && [syncMgr hasSyncItemsToApply])) {
            syncProgressView.applyChangesButton.enabled = YES;
            syncProgressView.progressLabel.text = @"Download Complete.  Apply Changes by tapping icon on right.";
            [syncProgressView.progressView setProgress:1.0];
        } else if ([syncMgr isSyncInProgress]) {
            syncProgressView.totalSyncFiles = [syncMgr.syncActions totalItemsToApply];
            syncProgressView.downloadedSyncFiles = [syncMgr.syncActions totalItemsToApply] - [syncMgr.syncActions totalItemsToDownload];
            syncProgressView.applyChangesButton.enabled = NO;
            syncProgressView.progressLabel.hidden = NO;
        } else {
            syncProgressView.progressLabel.text = @"Refresh Documents by tapping icon on right.";
            syncProgressView.applyChangesButton.enabled = YES;
            [syncProgressView.progressView setProgress:0.0];
        }
        void (^showProgress)(void) = ^{
            [UIView animateWithDuration:0.25 animations:^{
                [syncProgressView setFrame:startFrame];
            }];
        };
        
        dispatch_async(dispatch_get_main_queue(), ^{
            showProgress();
        });
    }
}

-(void) hideProgressBar{
    
    if (!syncProgressView.hidden  && ![[ContentSyncManager sharedInstance] isSyncInProgress]
        && ![[ContentSyncManager sharedInstance] hasSyncItemsToApply]) {
        CGRect startFrame = syncProgressView.frame;
        CGRect offScreen = startFrame;
        offScreen.origin.y = offScreen.origin.y + offScreen.size.height;
        
        [UIView animateWithDuration:0.25 animations:^{
            [syncProgressView setFrame:offScreen];
        }completion:^(BOOL finished){
            syncProgressView.progressLabel.hidden = NO;
            [syncProgressView.progressView setProgress:0.0];
            [syncProgressView setFrame:startFrame];
            syncProgressView.hidden = YES;
            
        }];
    }
}

- (void) resizeView:(UIInterfaceOrientation)interfaceOrientation {
    CGRect screenFrame = [UIScreen rectForScreenView:interfaceOrientation];
    CGSize size = CGSizeMake(screenFrame.size.width, screenFrame.size.height);
    CGFloat yOffset = 0.0f;
    
    CGRect frame = self.view.frame;
    frame.size = size;
    self.view.frame = frame;
    
    BOOL showInitialBackground = [self haveDisplayItems] == NO && [self initialImageAvailable] == YES;
    
    mainBackgroundImageView.image = nil;
    mainBackgroundImageView.frame = frame;
    
    if (mainConfig.bgImagePortrait && UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        NSString *imageName = showInitialBackground == YES ? mainConfig.initialBgImagePortrait : mainConfig.bgImagePortrait;
        mainBackgroundImageView.image = [UIImage imageNamed:imageName];
    } else if (mainConfig.bgImageLandscape && UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        NSString *imageName = showInitialBackground == YES ? mainConfig.initialBgImageLandscape : mainConfig.bgImageLandscape;
        mainBackgroundImageView.image = [UIImage imageNamed:imageName];
    } else if (mainConfig.bgImage) {
        NSString *imageName = showInitialBackground == YES ? mainConfig.initialBgImage : mainConfig.bgImage;
        mainBackgroundImageView.image = [UIImage imageNamed:imageName];
    } else {
        if (mainConfig.bgColor) {
            self.view.backgroundColor = mainConfig.bgColor;
        } else {
            self.view.backgroundColor = [UIColor whiteColor];
        }
    }

    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        // This interface was originally designed before iOS 7 when the frame
        // automatically excluded the status bar.  This allows us to adjust the
        // heights and y offset's so that the interface looks the same even through
        // the view extends up under the statusbar in iOS 7+.  SMM  12/18/13
        // (TRL 03/19/14 - Just set the yOffset and then adjust size accordingly)
        yOffset = [UIScreen statusBarHeight];
        
        size.height -= yOffset;
    }
    
    // Set the origin for the highlight View
    CGRect highlightViewFrame = highlightedView.frame;
    CGFloat carouselHeight = CAROUSEL_HEIGHT_WITH_REFLECTION;
    
    if (mainConfig.isReflectionOn == NO) {
        carouselHeight = CAROUSEL_HEIGHT_NO_REFLECTION;
    }

    highlightViewFrame.origin = CGPointMake((size.width - ITEMVIEW_WIDTH)/2,
                                            ((size.height - (carouselHeight))/2) + yOffset);
    
    highlightedView.frame = highlightViewFrame;
    
    // Set the frame for the carousel
    mainCarousel.frame = CGRectMake((size.width - CAROUSEL_WIDTH)/2,
                                    ((size.height - (carouselHeight))/2) + yOffset, CAROUSEL_WIDTH, carouselHeight);
    
    // Setup the content progress view frame
    contentProgressView.frame = CGRectMake((size.width - PROGRESS_VIEW_WIDTH)/2, ((size.height - PROGRESS_VIEW_HEIGHT)/2) + yOffset, PROGRESS_VIEW_WIDTH, PROGRESS_VIEW_HEIGHT);
    
    if (leftIconView) {
        CGRect leftLogoFrame = leftIconView.frame;
        leftLogoFrame.origin.y = 10.0f + yOffset;
        leftIconView.frame = leftLogoFrame;
    }
    
    // Position Right side logo
    if (rightIconView) {
        CGRect rightLogoFrame = rightIconView.frame;
        rightLogoFrame.origin = CGPointMake(size.width - rightLogoFrame.size.width - 10.0f, 10.0f + yOffset);
        rightIconView.frame = rightLogoFrame;
    }
    
    CGSize fullSize = CGSizeMake(screenFrame.size.width, screenFrame.size.height);
    CGRect syncProgressFrame = CGRectMake(0.0f, fullSize.height - 60.0f, fullSize.width, 60.0f);
    syncProgressView.frame = syncProgressFrame;

}

- (void) leftLogoTapped:(UITapGestureRecognizer *)tapGesture {
    NSString *urlString = mainConfig.leftLogoLink;
    
    if ([NSString isNotEmpty:urlString]) {
        [self presentWebView:[NSURL URLWithString:urlString]];
    }
}

- (void) rightLogoTapped:(UITapGestureRecognizer *)tapGesture {
    NSString *urlString = mainConfig.rightLogoLink;
    
    if ([NSString isNotEmpty:urlString]) {
        [self presentWebView:[NSURL URLWithString:urlString]];
    }
}

- (void) doSyncChanges:(id)selector {
    ContentSyncManager *syncMgr = [ContentSyncManager sharedInstance];
    syncMgr.syncDoApplyChanges = YES;
    [syncMgr applyChanges];
}

- (void) presentWebView:(NSURL *)url {
    CompanyWebViewController *webViewController = [[CompanyWebViewController alloc] initWithUrl:url andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
    
    webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:webViewController animated:YES completion:NULL];
}

- (void) presentCarousel {
    mainCarousel.hidden = NO;
    NSInteger numItems = [carouselItems count];
    
    // Make sure there are items in the carousel before continuing
    if (numItems > 0) {
        if (doScrollBy) {
            BOOL found = NO;
            CarouselMainConfig *config = [[SFAppConfig sharedInstance] getMainCarouselConfig];
            if (config.defaultItemTitle) {
                NSArray *mainSpinners = [[[ContentLookup sharedInstance] impl] mainSpinnerPanels];

                for (int i = 0; i < [mainSpinners count]; i++) {
                    id<ContentViewBehavior>spinner = (id<ContentViewBehavior>)[mainSpinners objectAtIndex:i];
                    NSLog(@"Content Title for Spinner %i is %@", i, [spinner contentTitle]);
                    if ([[spinner contentTitle] caseInsensitiveCompare:config.defaultItemTitle] == NSOrderedSame) {
                        // This just goes to the chosen index by the shortest route.  Doesn't do anything like
                        // a full spin.
                        [mainCarousel scrollToItemAtIndex:i duration:2];
                        found = YES;
                        break;
                    }
                }
            }
            
            if (found == NO) {
                [mainCarousel scrollByNumberOfItems:numItems duration:2];
            }
            doScrollBy = NO;
        }
        
        // Bring all carousel view alphas to 1.0
        
        [UIView animateWithDuration:2 animations:^{
            for (UIView *view in carouselItems) {
                view.alpha = 1.0;
            }
        }];
    }
}

- (BOOL)haveDisplayItems {
    return ([[[[ContentLookup sharedInstance] impl] mainCategoryPaths] count] > 0 && [[[[ContentLookup sharedInstance] impl] mainInfoPanels] count] > 0);
}

- (BOOL) initialImageAvailable {
    if (mainConfig.initialBgImage || mainConfig.initialBgImageLandscape || mainConfig.initialBgImagePortrait) {
        return YES;
    }
    return NO;
}

@end

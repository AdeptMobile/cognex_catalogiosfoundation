//
//  MainViewController.m
//  DonaldsonEngineApp
//
//  Created by Chris Pflepsen on 7/30/12.
//
//

#import "GridMainViewController.h"

#import "SFAppConfig.h"
#import "ContentUtils.h"
#import "AlertUtils.h"
#import "ContentConstants.h"

#import "ContentSyncManager.h"

#import "UIView+ViewLayout.h"
#import "UIView+ImageRender.h"
#import "UIColor+Chooser.h"
#import "UIImage+Resize.h"
#import "UIImage+Extensions.h"
#import "UIScreen+Helpers.h"
#import "NSArray+Helpers.h"
#import "NSString+Extensions.h"

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

// SMM
#import "ContentLookupCoreData.h"
#import "ContentLookup.h"

#import "AbstractCategoryViewController.h"
#import "CompanyWebViewController.h"
#import "CompanyInfoHtmlViewController.h"
#import "PortfolioDetailVideoController.h"

#define PROGRESS_VIEW_HEIGHT 200.0f
#define PROGRESS_VIEW_WIDTH 600.0f

#define VIEW_MARGIN 20.0f

@interface GridMainViewController(){
    NSTimer *transitionTimer;
    NSMutableArray *backgroundArray;
    CGFloat yOffset;
}

@property (nonatomic, strong) UIButton *reSyncButton;

- (void) resizeView: (UIInterfaceOrientation) interfaceOrientation;
- (void) logoTapped:(UITapGestureRecognizer *) tapGesture;
- (void) tolonetTapped:(UITapGestureRecognizer *) tapGesture;
- (void) doSyncChanges:(id) selector;

- (void) leftLogoTapped:(UITapGestureRecognizer *) tapGesture;
- (void) rightLogoTapped:(UITapGestureRecognizer *) tapGesture;

- (void) presentWebView: (NSURL *) url;

- (void) showProgressBar;

- (void) transitionBackgroundViews;
- (UIImage *) getNextBackgroundImage;

- (NSArray *)displayArray;
- (BOOL)haveDisplayItems;

@end

@implementation GridMainViewController

@synthesize contentProgressView, syncProgressView,productScrollView, logoView, mainBackgroundImageView, headerImageView, bottomBarImageView, reSyncButton, config, leftIconView, rightIconView;


- (id) init {
    self = [super init];
    
    if (self) {
        // Custom initialization
        doScrollBy = YES;
        unpackedData = NO;

        config = [[SFAppConfig sharedInstance] getMainGridConfig];
        
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    logoView = nil;
    headerImageView = nil;
    mainBackgroundImageView = nil;
    bottomBarImageView = nil;
    
    productScrollView = nil;
    
    syncProgressView = nil;
    contentProgressView = nil;
    
    rightIconView = nil;
    leftIconView = nil;
}

#pragma mark -
#pragma mark Public Methods

#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    
    BOOL hasMasthead = YES;
    //Setup image Array for rotating images
    
    if (config.titleImageArray != nil && config.titleImageArray.count > 0) {
        backgroundArray = [[NSMutableArray alloc] init];
        for (NSString *imgName in config.titleImageArray) {
            [backgroundArray addObject:[UIImage imageResource:imgName]];
        }
    } else {
       
        hasMasthead = NO;
    }
    
    UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    yOffset = 0.0f;
    
    if (config.statusBarColor) {
        mainView.backgroundColor = config.statusBarColor;
        yOffset = 20.0f;
    }
    
    mainBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, 1024, 768 - yOffset)];
    NSString *bgImageName;
    if ([self haveDisplayItems] == NO && [config.initialDownloadImageName isEmpty] == NO) {
        bgImageName = [NSString stringWithString:config.initialDownloadImageName];
    } else {
        bgImageName = [NSString stringWithString:config.bgImageName];
    }
    
    mainBackgroundImageView.image = [UIImage imageNamed:bgImageName];
    
    [mainView addSubview:mainBackgroundImageView];
    
    if (hasMasthead) {
        
        UIImage *backgroundImage = [self getNextBackgroundImage];
        headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, 1024, 243)];
        headerImageView.image = backgroundImage;
        [mainView addSubview:headerImageView];

    } else {
        
        NSString *logoLeft = config.leftLogoNamed;
        
        if ([NSString isNotEmpty:logoLeft]) {
            UIImage *leftLogoImage = [UIImage imageResource:logoLeft];
            UIImageView *leftLogoImageView = [[UIImageView alloc] initWithImage:leftLogoImage];
            leftIconView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, leftLogoImage.size.width, leftLogoImage.size.height)];
            [leftIconView addSubview:leftLogoImageView];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(leftLogoTapped:)];
            tap.numberOfTapsRequired = 1;
            [leftIconView addGestureRecognizer: tap];
        }

        NSString *logoRight = config.rightLogoNamed;
        
        if ([NSString isNotEmpty:logoRight]) {
            UIImage *rightLogoImage = [UIImage imageResource:logoRight];
            UIImageView *rightLogoImageView = [[UIImageView alloc] initWithImage:rightLogoImage];
            rightIconView = [[UIView alloc] initWithFrame:CGRectMake(100, 10, rightLogoImage.size.width, rightLogoImage.size.height)];
            [rightIconView addSubview:rightLogoImageView];
            
            UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(rightLogoTapped:)];
            tap2.numberOfTapsRequired = 1;
            [rightIconView addGestureRecognizer: tap2];
        }
        
        [mainView addSubview:leftIconView];
        [mainView addSubview:rightIconView];
    }

    CGFloat initialOffset = (config.scrollViewFrameOffset == nil) ? 232.0f : config.scrollViewFrameOffset.floatValue;
    CGFloat frameHeight = (config.mainViewScrollFrameHeight == nil) ? 516.0f : config.mainViewScrollFrameHeight.floatValue;

    productScrollView = [[ProductLevelScrollView alloc] initWithFrame:CGRectMake(0, initialOffset + yOffset, 1024, frameHeight)
                                                       mainPanelArray:[self displayArray]];
    productScrollView.numThumbsLandscape = config.thumbsPerPageLandscape;
    productScrollView.numThumbsPortrait = config.thumbsPerPagePortrait;
    
    productScrollView.thumbnailDelegate = self;
    productScrollView.backgroundColor = config.scrollBgColor;
    [mainView addSubview:productScrollView];
    
    UIView *activeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 10)];
    activeView.backgroundColor = config.pageControlActiveColor;
    
    UIView *inactiveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 10)];
    inactiveView.backgroundColor = config.pageControlInactiveColor;
    
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
    
    // Configure the content progress indicator
    contentProgressView = [[ToloContentProgressView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [contentProgressView setupForUnpackContentProgress];
    contentProgressView.totalContentChanges = 0;
    contentProgressView.hidden = YES;
    [mainView addSubview:contentProgressView];
    
    // Configure the sync progress indicator
    syncProgressView = [[SyncProgressHudView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
    syncProgressView.totalSyncFiles = 0;
    //syncProgressView.hidden = YES;
    syncProgressView.delegate = self;
    [mainView addSubview:syncProgressView];
    
    [self setView:mainView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showProgressBar)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideProgressBar)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDown];
    
    ContentSyncManager *syncMgr = [ContentSyncManager sharedInstance];
    
    [syncMgr registerSyncDelegate:self];
    [syncMgr setUnpackDelegate:self];
    [syncMgr setApplyChangesDelegate:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    for (UIGestureRecognizer *gr in [self.view gestureRecognizers]) {
        [self.view removeGestureRecognizer:gr];
    }
    
    [[ContentSyncManager sharedInstance] unRegisterSyncDelegate:self];
    [[ContentSyncManager sharedInstance] setUnpackDelegate:nil];
    [[ContentSyncManager sharedInstance] setApplyChangesDelegate:nil];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self resizeView:orientation];
    
    // Make sure we hide the progess view
    syncProgressView.hidden = YES;
    
    // See if we need to unpack the contents
    ContentSyncManager *syncMgr = [ContentSyncManager sharedInstance];
    
    if (syncMgr.syncDoUnpack) {
        [syncMgr unpackContents];
    }
    
    // Determine if we need to apply any changes
    if (syncMgr.syncDoApplyChanges) {
        [syncMgr applyChanges];
    }
    
    if ([syncMgr hasSyncItemsToApply]) {
        [self showProgressBar];
    }

    if (config.titleImageArray != nil && config.titleImageArray.count > 0) {

        transitionTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(transitionBackgroundViews) userInfo:nil repeats:YES];
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
    
    if (transitionTimer && [transitionTimer isValid]) {
        [transitionTimer invalidate];
        transitionTimer = nil;
    }
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self resizeView:toInterfaceOrientation];
}

#pragma mark -
#pragma mark UnpackContentDelegate Methods
- (void) unpackItemsDetected:(BOOL)doUnpack {
    if (doUnpack) {
        contentProgressView.hidden = NO;
        //Donaldson: hide icon display
        productScrollView.hidden = YES;
        if ([self haveDisplayItems] == NO && [config.initialDownloadImageName isEmpty] == NO) {
            mainBackgroundImageView.image = [UIImage imageNamed:config.bgImageName];
        }
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
    
    //Donaldson: hide icon display
    productScrollView.hidden = YES;
    
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
        //Donaldson: Reload Display
        productScrollView.mainPanelArray = [self displayArray];
        [productScrollView layoutSubviews];
        productScrollView.hidden = NO;
    }
}

#pragma mark -
#pragma mark ContentSyncApplyChangesDelegate
- (void) applyChangesStarted:(ContentSyncManager *)syncManager {
    productScrollView.hidden = YES;
    
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
    //Donaldson: reload display

    productScrollView.mainPanelArray = [self displayArray];
    [productScrollView layoutSubviews];
    productScrollView.hidden = NO;
    
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
    productScrollView.hidden = YES;
    
    // We have cleared out all the data, reload the carousel back to the defaults.
    [[[ContentLookup sharedInstance] impl] refresh];
    
    //Donaldson: reload data
    productScrollView.mainPanelArray = [self displayArray];
    [productScrollView layoutSubviews];
    productScrollView.hidden = NO;
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
        // TODO: Check if we need to hide the productScrollView
        // productScrollView.hidden = YES;
    }
    syncProgressView.downloadedSyncFiles = currentChangeIndex;
}

- (void) syncCompleted:(ContentSyncManager *)syncManager syncStatus:(SyncCompletionStatus)syncStatus {
    
    if ([self haveDisplayItems] == NO && [config.initialDownloadImageName isEmpty] == NO) {
        mainBackgroundImageView.image = [UIImage imageNamed:config.bgImageName];
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
    
    //determine the functionality of the sync button here
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
#pragma mark Private Methods
-(NSArray *)displayArray{ NSLog(@"cat paths: %@", [[[ContentLookup sharedInstance] impl] mainCategoryPaths]);
    NSArray *tempArray = [NSArray arrayWithArrays:[[[ContentLookup sharedInstance] impl] mainCategoryPaths],[[[ContentLookup sharedInstance] impl] mainInfoPanels], nil];
    return tempArray;
}

-(BOOL)haveDisplayItems {
    return ([[[[ContentLookup sharedInstance] impl] mainCategoryPaths] count] > 0 && [[[[ContentLookup sharedInstance] impl] mainInfoPanels] count] > 0);
}

- (void) doSyncChanges:(id)selector {
    ContentSyncManager *syncMgr = [ContentSyncManager sharedInstance];
    syncMgr.syncDoApplyChanges = YES;
    [syncMgr applyChanges];
}

- (void) resizeView:(UIInterfaceOrientation)interfaceOrientation {
    CGRect screenFrame = [UIScreen rectForScreenView:interfaceOrientation];
    CGSize size = CGSizeMake(screenFrame.size.width, screenFrame.size.height);
    
    // Setup the content progress view frame
    contentProgressView.frame = CGRectMake((size.width - PROGRESS_VIEW_WIDTH)/2, ((size.height - PROGRESS_VIEW_HEIGHT)/2) + yOffset, PROGRESS_VIEW_WIDTH, PROGRESS_VIEW_HEIGHT);
    
    CGRect frame = self.view.frame;
    frame.size = size;
    self.view.frame = frame;
    
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

    
    // Position Tolonet logo
    CGRect syncProgressFrame = CGRectMake(0.0f, size.height - 60.0f, size.width, 60.0f);
    syncProgressView.frame = syncProgressFrame;
    
    // Set the background for the view
    //Donaldson: Set background image
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageResource:@"Default-Landscape~ipad.png"]];
    } else {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageResource:@"Default-Portrait~ipad.png"]];
    }
}

- (void) logoTapped:(UITapGestureRecognizer *)tapGesture {
    // Donaldson now webview to present here.
}
- (void) tolonetTapped:(UITapGestureRecognizer *)tapGesture {
    // Donaldson no webview to present here.
}

- (void) leftLogoTapped:(UITapGestureRecognizer *)tapGesture {
    NSString *urlString = config.leftLogoLink;
    
    if ([NSString isNotEmpty:urlString]) {
        [self presentWebView:[NSURL URLWithString:urlString]];
    }
}

- (void) rightLogoTapped:(UITapGestureRecognizer *)tapGesture {
    NSString *urlString = config.rightLogoLink;
    
    if ([NSString isNotEmpty:urlString]) {
        [self presentWebView:[NSURL URLWithString:urlString]];
    }
}


- (void) presentWebView:(NSURL *)url {
    CompanyWebViewController *webViewController = [[CompanyWebViewController alloc] initWithUrl:url andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
    
    webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:webViewController animated:YES completion:NULL];

}

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

#pragma mark -
#pragma mark ContentThumbnailDelegate Methods
- (void) thumbnailTapped:(ProductThumbnailView *)tappedThumbnailView {
    id<ContentViewBehavior> itemPath = tappedThumbnailView.itemContentPath;
    NSLog(@"Title for tapped thumbnail: %@", [itemPath contentTitle]);
    BOOL isProductDetailPath = [[itemPath contentType] isEqualToString:CONTENT_TYPE_PRODUCT];
    NSLog(@"Path %@ a product detail path.", (isProductDetailPath == YES) ? @"is" : @"is not");
    if ([CONTENT_TYPE_HTML isEqualToString:[itemPath contentType]]) {
        CompanyWebViewController *webViewController = [[CompanyWebViewController alloc] initWithUrl:[NSURL fileURLWithPath:[itemPath contentFilePath]] andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
        [self presentViewController:webViewController animated:YES completion:nil];
    }
    else if ([[itemPath contentTitle] isEqualToString:@"Videos"]) {
         PortfolioDetailVideoController* nextLevel = [[PortfolioDetailVideoController alloc] initWithlevelPath:itemPath];
         [[self navigationController] pushViewController:nextLevel animated:YES];
    }
    else if (isProductDetailPath) {
        //Product View
         NSLog(@"Product Level View");
    } else {
        //Category View
        NSLog(@"Category Level View");
        AbstractCategoryViewController *categoryVC = [[SFAppConfig sharedInstance] getCategoryNavViewController:itemPath];
        [self.navigationController pushViewController:categoryVC animated:YES];
    }
    
}

#pragma mark -
#pragma mark Transition Background Images
-(void) transitionBackgroundViews{
    [self crossDisolveTransition];
}

-(void)changeImagesNoTransitions{
    headerImageView.image = [self getNextBackgroundImage];
}

-(void) slideTransistion{
    NSLog(@"Slide Transition");
    
    //Background
    CGRect backgroundDestFrame = headerImageView.frame;
    CGRect backgroundCurrentFrame = headerImageView.frame;
    
    backgroundDestFrame.origin.x = -backgroundDestFrame.size.width;
    
    CGRect backgroundTempFrame = headerImageView.frame;
    backgroundTempFrame.origin.x = backgroundTempFrame.size.width;
    
    UIImage *backgroundTempImage = [self getNextBackgroundImage];
    UIImageView *tempBackgroundImageView = [[UIImageView alloc] initWithFrame:backgroundTempFrame];
    tempBackgroundImageView.image = backgroundTempImage;
    [self.view insertSubview:tempBackgroundImageView belowSubview:headerImageView];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [headerImageView setFrame:backgroundDestFrame];
        [tempBackgroundImageView setFrame:backgroundCurrentFrame];
        
    }completion:^(BOOL finished){
        [tempBackgroundImageView removeFromSuperview];
        [headerImageView setImage:backgroundTempImage];
        [headerImageView setFrame:backgroundCurrentFrame];
    }];
    
    
}

-(void)crossDisolveTransition{
    NSLog(@"Cross Disolve Transition");
    
    CGRect backgroundFrame = headerImageView.frame;
    
    UIImage *tempBackgroundImage = [self getNextBackgroundImage];
    UIImageView *tempBackgroundImageView = [[UIImageView alloc] initWithFrame:backgroundFrame];
    tempBackgroundImageView.image = tempBackgroundImage;
    [self.view insertSubview:tempBackgroundImageView belowSubview:headerImageView];
    tempBackgroundImageView.alpha = 0.0;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [headerImageView setAlpha:0.0];
        [tempBackgroundImageView setAlpha:1.0];
        
    }completion:^(BOOL finished){
        [tempBackgroundImageView removeFromSuperview];
        [headerImageView setAlpha:1.0];
        [headerImageView setImage:tempBackgroundImage];
    }];
}

-(UIImage *)getNextBackgroundImage{
    if (!backgroundArray) {
        
        if([config.defaultMastheadImage isEmpty] == NO) {
            return [UIImage imageResource:config.defaultMastheadImage];
        } else {

            UIGraphicsBeginImageContextWithOptions(CGSizeMake(headerImageView.frame.size.height, headerImageView.frame.size.width), YES, 0.0);
            UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            return blank;
        }
    }
    
    
    NSInteger index = [backgroundArray indexOfObject:headerImageView.image];
    index++;
    
    if (index >= [backgroundArray count] ||
        index < 0) {
        index = 0;
    }
    
    
    return [backgroundArray objectAtIndex:index];
}

@end

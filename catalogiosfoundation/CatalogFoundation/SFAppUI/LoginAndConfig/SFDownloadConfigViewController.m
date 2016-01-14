//
//  SFDownloadConfigViewController.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/6/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import "SFDownloadConfigViewController.h"
#import "AbstractMainViewController.h"

#import "SFAppConfig.h"
#import "ContentUtils.h"

@interface SFDownloadConfigViewController ()

@end

@implementation SFDownloadConfigViewController

- (id)init {
    self = [super init];
    if (self) {
        self.modal = NO;
    }
    return self;
}

- (id)initAsModal {
    self = [super init];
    if (self) {
        self.modal = YES;
    }
    return self;
}


#pragma mark - View Lifecycle Methods
- (void)loadView {
    SFDownloadConfigView *dlView = [[SFDownloadConfigView alloc] initWithFrame:CGRectZero];
    dlView.delegate = self;
    [self setView:dlView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
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
    if ([[[SFAppConfig sharedInstance] getDownloadViewConfig] landscapeOnly]) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[[SFAppConfig sharedInstance] getDownloadViewConfig] landscapeOnly]) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return YES;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SFDownloadConfigViewDelegate methods
- (void) doneButtonTapped:(id)doneButton {
    SFDownloadConfigView *configView = (SFDownloadConfigView *)self.view;
    
    BOOL shouldSuppressVideos;
    BOOL shouldSuppressPresentations;
    if ([[SFAppConfig sharedInstance] isVideoFilteringEnabled] == NO) {
        shouldSuppressVideos = NO;
    } else {
        shouldSuppressVideos = !(configView.allVideoSwitch.isOn);
    }
    
    if ([[SFAppConfig sharedInstance] isPresentationFilteringEnabled] == NO) {
        shouldSuppressPresentations = NO;
    } else {
        shouldSuppressPresentations = !(configView.allPresentationSwitch.isOn);
    }
    
    BOOL videoCurrentlySuppressed = [ContentUtils isVideoSyncDisabled];
    BOOL presentationCurrentlySuppressed = [ContentUtils isPresentationSyncDisabled];
    
    BOOL doCleanVideo = NO;
    BOOL doCleanPresentation = NO;
    BOOL allowIndividualVideoDeletion = configView.individualVideoDeletion;
    
    // Set up only to clean a category of files if we were previously not
    // suppressed but now we are.
    if (videoCurrentlySuppressed == NO && shouldSuppressVideos == YES) {

        if(allowIndividualVideoDeletion) {
            doCleanVideo = NO;
        } else {
            doCleanVideo = YES;
        }
    }
    
    if (presentationCurrentlySuppressed == NO && shouldSuppressPresentations == YES) {
        doCleanPresentation = YES;
    }
    
    // Clean up the existing files on the iPad if any
    [ContentUtils cleanContentVideos:doCleanVideo andPresentations:doCleanPresentation];
    
    [ContentUtils setVideoSyncDisabled:shouldSuppressVideos];
    [ContentUtils setPresentationSyncDisabled:shouldSuppressPresentations];
    [ContentUtils setAppConfigured:YES];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(enableScheduledSyncOnActive)]) {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(enableScheduledSyncOnActive)];
    }
#pragma clang diagnostic pop
    
    if (self.modal == YES) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        // Go to the main view controller, removing this one from the stack so
        // we don't pop back to it.
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [viewControllers removeLastObject];
        AbstractMainViewController *mainController = [[SFAppConfig sharedInstance] getMainViewController];
        [viewControllers addObject:mainController];
        [self.navigationController setViewControllers:viewControllers animated:YES];
    }
    
}

@end

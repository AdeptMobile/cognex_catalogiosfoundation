//
//  SyncActionViewController.m
//  ToloApp
//
//  Created by Torey Lomenda on 7/12/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "SyncActionViewController.h"
#import "OPIFoundation.h"

#import "ContentSyncManager.h"

#import "UIView+ViewLayout.h"
#import "UIImage+Extensions.h"
#import "MOGlassButton.h"

#define POPOVER_WIDTH 250.0f

#define POPOVER_SYNC_NOW_HEIGHT 44.0f + 18.0f + 8.0f
#define POPOVER_SYNC_INPROGRESS_HEIGHT 44.0f + 18.0f + 8.0f
#define POPOVER_SYNC_RESULTS_NO_ERRORS_HEIGHT 184.0f
#define POPOVER_SYNC_RESULTS_ERRORS_HEIGHT 330.0f

#define LABEL_SPACING 8.0f
#define LABEL_HEIGHT 18.0f
#define LABEL_WIDTH 250.0f
#define BUTTON_HEIGHT 44.0f
#define BUTTON_WIDTH 250.f
#define BUTTON_SPACING 8.0f

#define RESULTS_SUMMARY_HEIGHT 96.0f // 3 label heights + label spacing * 2
#define DOWNLOAD_ERRORS_HEIGHT 148.0f
#define DOWNLOAD_ERRORS_TABLE_HEIGHT 118.0f

#import "AlertUtils.h"
@interface SyncActionViewController() 

- (void) handleSyncNowButton: (id) sender;
- (void) handleApplyChanges: (id) sender;

- (void) addSyncNowView;
- (void) addUpdateInProgressView;
- (void) addSyncResultsView;

@end

@implementation SyncActionViewController

@synthesize delegate;

- (id)init {
    self = [super init];
    
    if (self) {
        // Custom initialization
        ContentSyncManager *syncMgr = [ContentSyncManager sharedInstance];
        
        if ([syncMgr isSyncInProgress]) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                self.preferredContentSize = CGSizeMake(POPOVER_WIDTH, POPOVER_SYNC_INPROGRESS_HEIGHT);
            } else {
                self.contentSizeForViewInPopover = CGSizeMake(POPOVER_WIDTH, POPOVER_SYNC_INPROGRESS_HEIGHT);
            }
        } else if ([syncMgr hasSyncItemsToApply]) {
            if ([syncMgr.downloadErrorList count] > 0) {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                    self.preferredContentSize = CGSizeMake(POPOVER_WIDTH, POPOVER_SYNC_RESULTS_ERRORS_HEIGHT);
                } else {
                    self.contentSizeForViewInPopover = CGSizeMake(POPOVER_WIDTH, POPOVER_SYNC_RESULTS_ERRORS_HEIGHT);
                }
            } else {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                    self.preferredContentSize = CGSizeMake(POPOVER_WIDTH, POPOVER_SYNC_RESULTS_NO_ERRORS_HEIGHT);
                } else {
                    self.contentSizeForViewInPopover = CGSizeMake(POPOVER_WIDTH, POPOVER_SYNC_RESULTS_NO_ERRORS_HEIGHT);
                }
            }
        } else if (![syncMgr isSyncInProgress] && ![syncMgr hasSyncItemsToApply]) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                self.preferredContentSize = CGSizeMake(POPOVER_WIDTH, POPOVER_SYNC_NOW_HEIGHT);
            } else {
                self.contentSizeForViewInPopover = CGSizeMake(POPOVER_WIDTH, POPOVER_SYNC_NOW_HEIGHT);
            }
        }
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    UIView *mainView;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.preferredContentSize.width, self.preferredContentSize.height)];
    } else {
        mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentSizeForViewInPopover.width, self.contentSizeForViewInPopover.height)];
    }
    
    // Setup the label
    lastUpdateLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, LABEL_WIDTH, LABEL_HEIGHT)];
    lastUpdateLabel.backgroundColor = [UIColor clearColor];
    lastUpdateLabel.font = [UIFont systemFontOfSize: LABEL_HEIGHT - 4.0f];
    lastUpdateLabel.textColor = [UIColor lightGrayColor];
    lastUpdateLabel.textAlignment = NSTextAlignmentCenter;
    
    // Setup the sync and apply buttons
    [mainView addSubview:lastUpdateLabel];
                   
    
    [self setView:mainView];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    ContentSyncManager *syncMgr = [ContentSyncManager sharedInstance];
    
    lastUpdateLabel.text = [NSString stringWithFormat:@"Updated On:  %@", [syncMgr getLastUpdateDateAsString]];
    
    if ([syncMgr isSyncInProgress]) {
        [self addUpdateInProgressView];
    } else if ([syncMgr hasSyncItemsToApply]) {
        [self addSyncResultsView];
    } else if (![syncMgr isSyncInProgress] && ![syncMgr hasSyncItemsToApply]) {
        [self addSyncNowView];
    }
    
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
    
    if (failedDownloadsTableView) {
        [failedDownloadsTableView reloadData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark Failed Downloads UITableViewDelegate
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 16.0f;
//}

#pragma mark -
#pragma mark Failed Downloads UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[ContentSyncManager sharedInstance].downloadErrorList count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"downloadErrorCell-%ld", (long)indexPath.row];
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;

        cell.textLabel.font = [UIFont italicSystemFontOfSize:LABEL_HEIGHT - 4.0f];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        [cell.textLabel setText: (NSString *) [[ContentSyncManager sharedInstance].downloadErrorList objectAtIndex:indexPath.row]];
    }
    
	return cell;
}


#pragma mark -
#pragma mark Private Methods
- (void) handleSyncNowButton:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(selectedSyncAction:)]) {
        [delegate selectedSyncAction:SYNC_CONTENT_NOW];
    }
}

- (void) handleApplyChanges:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(selectedSyncAction:)]) {
        [delegate selectedSyncAction:SYNC_APPLY_CHANGES];
    }
}

- (void) addSyncNowView {
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        syncButton = [[UIButton alloc] initWithFrame:CGRectMake(0, LABEL_HEIGHT + BUTTON_SPACING, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [syncButton setBackgroundColor:[UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f]];
        [syncButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [syncButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [syncButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    } else {
        syncButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(0, LABEL_HEIGHT + BUTTON_SPACING, BUTTON_WIDTH, BUTTON_HEIGHT)];
            [((MOGlassButton *)syncButton) setupAsGrayButton];
    }
    [syncButton setTitle:@"Update Resources Now" forState:UIControlStateNormal];
    [syncButton addTarget:self action:@selector(handleSyncNowButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:syncButton];
}

- (void) addUpdateInProgressView {
    UIView *inProgressView = [[UIView alloc] initWithFrame:CGRectMake(0, LABEL_HEIGHT + BUTTON_SPACING, BUTTON_WIDTH, BUTTON_HEIGHT)];
    inProgressView.backgroundColor = [UIColor whiteColor];
    // Add Activity indicator and label
    inProgressIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    inProgressIndicatorView.center = CGPointMake(inProgressIndicatorView.bounds.size.width/2 + LABEL_SPACING, inProgressView.bounds.size.height / 2.0);
    
    inProgressIndicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(inProgressIndicatorView.bounds.size.width + LABEL_SPACING*2, 
                                                                         inProgressView.bounds.size.height/2 - LABEL_HEIGHT/2, 
                                                                         LABEL_WIDTH-inProgressIndicatorView.bounds.size.width - LABEL_SPACING*2, LABEL_HEIGHT)];
    inProgressIndicatorLabel.backgroundColor = [UIColor clearColor];
    inProgressIndicatorLabel.font = [UIFont systemFontOfSize: LABEL_HEIGHT - 4.0f];
    inProgressIndicatorLabel.textColor = [UIColor grayColor];
    inProgressIndicatorLabel.textAlignment = NSTextAlignmentLeft;
    
    
    ContentSyncManager *syncMgr = [ContentSyncManager sharedInstance];
    inProgressIndicatorLabel.text = [NSString stringWithFormat:@"Now syncing %ld changes.", (long)[syncMgr.syncActions totalItemsToApply]];
    
    [inProgressView addSubview:inProgressIndicatorView];
    [inProgressView addSubview:inProgressIndicatorLabel];
    
    [inProgressIndicatorView startAnimating];
    [self.view addSubview:inProgressView];
    
    [inProgressView applyDefaultRoundedStyle];
    
}

- (void) addSyncResultsView {
    ContentSyncManager *syncMgr = [ContentSyncManager sharedInstance];
    
    UIView *resultsSummaryView = [[UIView alloc] initWithFrame:CGRectMake(0, LABEL_HEIGHT + BUTTON_SPACING, POPOVER_WIDTH, RESULTS_SUMMARY_HEIGHT)];
    resultsSummaryView.backgroundColor = [UIColor whiteColor];
    
    // Create the summary view
    CGFloat yPos = LABEL_SPACING;
    UILabel *resultTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, POPOVER_WIDTH, LABEL_HEIGHT)];
    resultTitle.backgroundColor = [UIColor clearColor];
    resultTitle.font = [UIFont boldSystemFontOfSize: LABEL_HEIGHT - 4.0f];
    resultTitle.textColor = [UIColor blackColor];
    resultTitle.textAlignment = NSTextAlignmentCenter;
    resultTitle.text = @"Results Summary";
    
    yPos += LABEL_HEIGHT; 
    itemsToRemoveLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_SPACING, yPos, POPOVER_WIDTH, LABEL_HEIGHT)];
    itemsToRemoveLabel.backgroundColor = [UIColor clearColor];
    itemsToRemoveLabel.font = [UIFont italicSystemFontOfSize: LABEL_HEIGHT - 4.0f];
    itemsToRemoveLabel.textColor = [UIColor blackColor];
    itemsToRemoveLabel.textAlignment = NSTextAlignmentLeft;
    itemsToRemoveLabel.text = [NSString stringWithFormat:@"Delete %lu resources.", (unsigned long)[syncMgr.syncActions.removeContentItems count]];
    
    yPos += LABEL_HEIGHT; 
    itemsToAddLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_SPACING, yPos, POPOVER_WIDTH, LABEL_HEIGHT)];
    itemsToAddLabel.backgroundColor = [UIColor clearColor];
    itemsToAddLabel.font = [UIFont italicSystemFontOfSize: LABEL_HEIGHT - 4.0f];
    itemsToAddLabel.textColor = [UIColor blackColor];
    itemsToAddLabel.textAlignment = NSTextAlignmentLeft;
    itemsToAddLabel.text = [NSString stringWithFormat:@"Add %lu resources.", (unsigned long)[syncMgr.syncActions.addContentItems count]];
    
    yPos += LABEL_HEIGHT;
    itemsToModifyLabel = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_SPACING, yPos, POPOVER_WIDTH, LABEL_HEIGHT)];
    itemsToModifyLabel.backgroundColor = [UIColor clearColor];
    itemsToModifyLabel.font = [UIFont italicSystemFontOfSize: LABEL_HEIGHT - 4.0f];
    itemsToModifyLabel.textColor = [UIColor blackColor];
    itemsToModifyLabel.textAlignment = NSTextAlignmentLeft;
    itemsToModifyLabel.text = [NSString stringWithFormat:@"Modify %lu resources.", (unsigned long)[syncMgr.syncActions.modifyContentItems count]];
    
    [resultsSummaryView addSubview:resultTitle];
    [resultsSummaryView addSubview:itemsToRemoveLabel];
    [resultsSummaryView addSubview:itemsToAddLabel];
    [resultsSummaryView addSubview:itemsToModifyLabel];
    
    
    // Are there sync errors
    CGFloat applyButtonYPos = LABEL_HEIGHT + LABEL_SPACING + RESULTS_SUMMARY_HEIGHT + BUTTON_SPACING;
    
    if (syncMgr.downloadErrorList && [syncMgr.downloadErrorList count] > 0) {
        UIView *downloadErrorsView = [[UIView alloc] initWithFrame:CGRectMake(0, applyButtonYPos, POPOVER_WIDTH, DOWNLOAD_ERRORS_HEIGHT)];
        downloadErrorsView.backgroundColor = [UIColor whiteColor];
    
        failedDownloadsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, POPOVER_WIDTH, LABEL_HEIGHT)];
        failedDownloadsLabel.backgroundColor = [UIColor clearColor];
        failedDownloadsLabel.font = [UIFont boldSystemFontOfSize: LABEL_HEIGHT - 4.0f];
        failedDownloadsLabel.textColor = [UIColor redColor];
        failedDownloadsLabel.textAlignment = NSTextAlignmentCenter;
        failedDownloadsLabel.text = [NSString stringWithFormat:@"%lu  Download Failures", (unsigned long)[syncMgr.downloadErrorList count]];
        
        failedDownloadsTableView = [[UITableView alloc] 
                                        initWithFrame:CGRectMake(0, LABEL_HEIGHT+LABEL_SPACING, POPOVER_WIDTH, DOWNLOAD_ERRORS_TABLE_HEIGHT) 
                                        style:UITableViewStylePlain];
        failedDownloadsTableView.dataSource = self;
        failedDownloadsTableView.delegate = self;
        failedDownloadsTableView.allowsSelection = NO;
        failedDownloadsTableView.rowHeight = 20.0f;
        failedDownloadsTableView.backgroundColor = [UIColor clearColor];
        failedDownloadsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        [downloadErrorsView addSubview:failedDownloadsLabel];
        [downloadErrorsView addSubview:failedDownloadsTableView];
        
        
        [self.view addSubview:downloadErrorsView];
        
        [downloadErrorsView applyDefaultRoundedStyle];
        
        applyButtonYPos += DOWNLOAD_ERRORS_HEIGHT + BUTTON_SPACING;
    }
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        applyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, applyButtonYPos, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [applyButton setBackgroundColor:[UIColor colorWithRed:210.0f green:210.0f blue:210.0f alpha:1.0f]];
        [applyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else {
        applyButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(0, applyButtonYPos, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [((MOGlassButton *)applyButton) setupAsGrayButton];
    }
    
    // Should this be a retry button or an apply changes button ??
    if (syncMgr.downloadErrorList && [syncMgr.downloadErrorList count] > 0) {
        [applyButton setTitle:@"Retry Downloads" forState:UIControlStateNormal];
        [applyButton addTarget:self action:@selector(handleSyncNowButton:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [applyButton setTitle:@"Apply Changes" forState:UIControlStateNormal];
        [applyButton addTarget:self action:@selector(handleApplyChanges:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.view addSubview:resultsSummaryView];
    [self.view addSubview:applyButton];
    
    [resultsSummaryView applyDefaultRoundedStyle];
}

@end

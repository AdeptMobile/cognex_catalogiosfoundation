//
//  SFRequestLoginViewController.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/6/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import "SFRequestLoginViewController.h"
#import "SFAppConfig.h"
#import "ContentUtils.h"

@interface SFRequestLoginViewController ()

@end

@implementation SFRequestLoginViewController

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Lifecycle Methods
- (void)loadView {
    SFRequestLoginView *requestview = [[SFRequestLoginView alloc] initWithFrame:CGRectZero];
    requestview.delegate = self;
    [self setView:requestview];
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
    if ([[[SFAppConfig sharedInstance] getRequestLoginConfig] landscapeOnly]) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[[SFAppConfig sharedInstance] getRequestLoginConfig] landscapeOnly]) {
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

#pragma mark - SFRequestLoginViewDelegate Methods
- (void) doneButtonTapped:(id)doneButton {
    SFRequestLoginConfig *config = [[SFAppConfig sharedInstance] getRequestLoginConfig];
    SFRequestLoginView *requestView = (SFRequestLoginView *)self.view;
    NSInteger selectedRow = [requestView.regionPicker selectedRowInComponent:0];
    
    NSString *subjectString = [NSString stringWithFormat:config.requestSubjectFormatString, [config.regions objectAtIndex:selectedRow]];
    
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setToRecipients:[NSArray arrayWithObject:[config.requestAddresses objectAtIndex:selectedRow]]];
    [mailViewController setSubject:subjectString];
    // The string reader from the plist file preserves the escaping for line breaks
    // so we have to replace them here to get real line breaks.
    [mailViewController setMessageBody:[[config.requestBodies objectAtIndex:selectedRow] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] isHTML:NO];
    mailViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:mailViewController animated:YES completion:NULL];
    });
}

-(void)cancelButtonTapped:(id)cancelButton {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    // This drops the mail composing controller.  We don't want to animate this
    // one and the one below, it will cause problems.
	[self dismissViewControllerAnimated:NO completion:NULL];
    // This drops us back to the main splash/login page.
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end

//
//  SFLoginViewController.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/4/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import "SFLoginViewController.h"

#import "SFAutoLogin.h"

#import "SFAppConfig.h"
#import "SFLoginView.h"
#import "SFDownloadConfigViewController.h"
#import "SFRequestLoginViewController.h"

#import "NSString+Extensions.h"
#import "ContentUtils.h"
#import "AlertUtils.h"
#import "AbstractMainViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface SFLoginViewController ()

@end

@implementation SFLoginViewController

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Lifecycle Methods
- (void)loadView {
    SFLoginView *loginView = [[SFLoginView alloc] initWithFrame:CGRectZero];
    loginView.delegate = self;
    loginView.usernameField.delegate = self;
    loginView.passwordField.delegate = self;
    
    [self setView:loginView];
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
    // AutoLogin Here
    if ([SFAutoLogin doAutoLogin]) {
        [SFAutoLogin autoLoginShowAlertForErrors:YES then:^(BOOL isLoginSuccessful) {
            if (isLoginSuccessful) {
                NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                // Pull ourselves off the stack so that we don't come back to the login
                // screen unless we log off.
                [viewControllers removeLastObject];
                
                if ([ContentUtils isAppConfigured] == YES) {
                    // Go to the main view controller
                    AbstractMainViewController *mainController = [[SFAppConfig sharedInstance] getMainViewController];
                    [viewControllers addObject:mainController];
                } else {
                    if ([[SFAppConfig sharedInstance] isDownloadFilteringEnabled] == YES) {
                        // Go to the download configuration controller
                        SFDownloadConfigViewController *dlController = [[SFDownloadConfigViewController alloc] init];
                        [viewControllers addObject:dlController];
                    } else {
                        // We are done configuring the app, set the flag to tell the app
                        // the initial config is done and go to the main controller
                        [ContentUtils setAppConfigured:YES];
                        AbstractMainViewController *mainController = [[SFAppConfig sharedInstance] getMainViewController];
                        [viewControllers addObject:mainController];
                    }
                }
                [self.navigationController setViewControllers:viewControllers animated:YES];
            }
        }];
    }
    
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
    if ([[[SFAppConfig sharedInstance] getLoginViewConfig] landscapeOnly]) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[[SFAppConfig sharedInstance] getLoginViewConfig] landscapeOnly]) {
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

#pragma mark - SFLoginViewDelegate methods
- (void)loginButtonTapped:(id)loginButton {
    SFLoginView *loginView = (SFLoginView *)self.view;
    if ([loginView.usernameField.text isEmpty] || [loginView.passwordField.text isEmpty]) {
        [AlertUtils showModalAlertMessage:NSLocalizedString(@"Please specify username and password.", nil) withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    } else {
        NSString *username = loginView.usernameField.text;
        NSString *password = loginView.passwordField.text;
        
        [SFAutoLogin loginWith:username andPassword:password showAlertForErrors:YES then:^(BOOL isLoginSuccessful) {
            if (isLoginSuccessful) {
                NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                // Pull ourselves off the stack so that we don't come back to the login
                // screen unless we log off.
                [viewControllers removeLastObject];
                
                if ([ContentUtils isAppConfigured] == YES) {
                    // Go to the main view controller
                    AbstractMainViewController *mainController = [[SFAppConfig sharedInstance] getMainViewController];
                    [viewControllers addObject:mainController];
                } else {
                    if ([[SFAppConfig sharedInstance] isDownloadFilteringEnabled] == YES) {
                        // Go to the download configuration controller
                        SFDownloadConfigViewController *dlController = [[SFDownloadConfigViewController alloc] init];
                        [viewControllers addObject:dlController];
                    } else {
                        // We are done configuring the app, set the flag to tell the app
                        // the initial config is done and go to the main controller
                        [ContentUtils setAppConfigured:YES];
                        AbstractMainViewController *mainController = [[SFAppConfig sharedInstance] getMainViewController];
                        [viewControllers addObject:mainController];
                    }
                }
                [self.navigationController setViewControllers:viewControllers animated:YES];
            }
        }];
    }
}

- (void)requestLoginButtonTapped:(id)requestLoginButton {
    SFRequestLoginViewController *requestLoginController = [[SFRequestLoginViewController alloc] init];
    [self presentViewController:requestLoginController animated:YES completion:NULL];
}

- (void) needHelpButtonTapped:(id)needHelpButton {
    SFLoginConfig *config = [[SFAppConfig sharedInstance] getLoginViewConfig];
    
    if (![config.helpEmailAddress isEmpty] && ![config.helpEmailSubject isEmpty] &&
        ![config.helpEmailBody isEmpty]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:[NSArray arrayWithObject:config.helpEmailAddress]];
        [mailViewController setSubject:config.helpEmailSubject];
        // The string reader from the plist file preserves the escaping for line breaks
        // so we have to replace them here to get real line breaks.
        [mailViewController setMessageBody:[config.helpEmailBody stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"] isHTML:NO];
        mailViewController.modalPresentationStyle = UIModalPresentationPageSheet;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:mailViewController animated:YES completion:NULL];
        });
        
    } else if (![config.helpAlertText isEmpty]) {
        [AlertUtils showModalAlertMessage:config.helpAlertText withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
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

@end

//
//  SFAppSetupViewController.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/11/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import "SFAppSetupViewController.h"
#import "OPIFoundation.h"
#import "SFAppSetupView.h"
#import "UIColor+Chooser.h"
#import "AbstractLayout.h"
#import "VerticalLayout.h"
#import "UIViewWithLayout.h"
#import "SFAppConfig.h"

#import "SFAutoLogin.h"

#define POPOVER_WIDTH 300.0f
#define POPOVER_HEIGHT 260.0f

@interface SFAppSetupViewController ()

@end

@implementation SFAppSetupViewController

- (id)init
{
    self = [super init];
    if (self) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.preferredContentSize = CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT);
        } else {
            self.contentSizeForViewInPopover = CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT);
        }
        
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)loadView {
    SFAppSetupView *setupView = [[SFAppSetupView alloc] initWithFrame:CGRectZero];
    setupView.delegate = self;
    [self setView:setupView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SFAppSetupView Delegate Methods
- (void)downloadSetupButtonPressed:(id)dlButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(setupChangeDownloadPressed)]) {
        [self.delegate setupChangeDownloadPressed];
    }
}

- (void)passwordSetupButtonPressed:(id)pwButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(setupChangePasswordPressed)]) {
        [self.delegate setupChangePasswordPressed];
    }
}

- (void)logoutButtonPressed:(id)logoutButton {
    // Clear Credentials
    [SFAutoLogin clearAutoLogin];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(setupLogoutPressed)]) {
        [self.delegate setupLogoutPressed];
    }
}

@end

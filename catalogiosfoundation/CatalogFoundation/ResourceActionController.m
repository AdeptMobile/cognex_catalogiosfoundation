//
//  ResourceActionController.m
//  ToloApp
//
//  Created by Torey Lomenda on 9/29/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ResourceActionController.h"
#import "OPIFoundation.h"

#import "MOGlassButton.h"

#define POPOVER_WIDTH 220.0f
#define POPOVER_HEIGHT 44.0f

#define BUTTON_HEIGHT 44.0f
#define BUTTON_WIDTH 220.f

#define BUTTON_SPACING 5.0f

@interface ResourceActionController() 

- (void) handleShareLinkButton: (id) sender;

@end


@implementation ResourceActionController
@synthesize delegate;

#pragma mark -
#pragma mark init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        // Custom initialization
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.preferredContentSize = CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT);
        } else {
            self.contentSizeForViewInPopover = CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT);
        }
    }
    
    return self;
}


#pragma mark -
#pragma mark View Lifecycle
- (void) loadView {
    [super loadView];
    
    CGRect appFrame = [[UIScreen mainScreen]applicationFrame];
    UIView *mainView = [[UIView alloc] initWithFrame:appFrame];
    
    mainView.backgroundColor = [UIColor whiteColor];
    
    // Setup the clear button
    UIButton *shareLinkButton = nil;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        shareLinkButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [shareLinkButton setBackgroundColor:[UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0f]];
        [shareLinkButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [shareLinkButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [shareLinkButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    } else {
        shareLinkButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
        [((MOGlassButton *)shareLinkButton) setupAsGrayButton];
    }
    
	[shareLinkButton setTitle:@"Share Document" forState:UIControlStateNormal];
    [shareLinkButton addTarget:self action:@selector(handleShareLinkButton:) forControlEvents:UIControlEventTouchUpInside];
    
	[mainView addSubview:shareLinkButton];
    
    [self setView: mainView];
    
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
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Private Methods
- (void) handleShareLinkButton:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(selectedAction:)]) {
        [delegate selectedAction:DOC_ACTION_EMAIL_LINK];
    }
}
@end

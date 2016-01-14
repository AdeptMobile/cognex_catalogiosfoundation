//
//  TolomaticInfoViewController.m
//  ToloApp
//
//  Created by Torey Lomenda on 7/7/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "CompanyInfoHtmlViewController.h"
#import "CompanyWebViewController.h"

#import "SFAppConfig.h"

#import "UIView+ViewLayout.h"
#import "UIImage+Extensions.h"
#import "UIScreen+Helpers.h"
#import "UIImage+CatalogFoundationResourceImage.h"
#import "NSString+Extensions.h"

#define LOGO_HEIGHT 80.0f

#define MAIN_BUTTON_WIDTH 50.0f
#define MAIN_BUTTON_HEIGHT 30.0f

@interface CompanyInfoHtmlViewController()

- (void) resizeView: (UIInterfaceOrientation) interfaceOrientation;

- (void) logoLeftTapped:(UITapGestureRecognizer *) tapGesture;
- (void) logoRightTapped:(UITapGestureRecognizer *) tapGesture;
- (void) mainButtonTapped: (id) selector;

@end

@implementation CompanyInfoHtmlViewController

- (id) initWithHtmlResourceNamed:(NSString *)anHtmlResource andConfig:(CompanyInfoHtmlViewConfig *)aViewConfig {
    self = [super init];
    
    if (self) {
        viewConfig = aViewConfig;
        htmlResourceNamed = anHtmlResource;
        htmlPath = nil;
    }
    
    return self;
}

- (id) initWithHtmlPath:(NSString *)anHtmlPath andConfig:(CompanyInfoHtmlViewConfig *)aViewConfig {
    self = [super init];
    if (self) {
        viewConfig = aViewConfig;
        htmlPath = anHtmlPath;
        htmlResourceNamed = nil;
    }
    return self;
}

- (void)dealloc {
    viewConfig = nil;
    
    htmlResourceNamed = nil;
    
    htmlPath = nil;
    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    CGFloat yOffset = 0.0f;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        // For iOS 7 or later.  This moves things out from under the status bar.
        yOffset = 20.0f;
    }
    
    UIView *mainView = [[UIView alloc] initWithFrame:bounds];
    mainView.backgroundColor = viewConfig.bgColor;
    
    NSString *logoLeft = viewConfig.logoLeft;
    NSString *logoRight = viewConfig.logoRight;
    
    // Configure the logo and link
    if ([NSString isNotEmpty:logoLeft]) {
        UIImage *logoImage = [UIImage imageResource:logoLeft];
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
        
        leftIconView = [[UIView alloc] initWithFrame:CGRectMake(10, 10 + yOffset, logoImage.size.width, logoImage.size.height)];
        [leftIconView addSubview:logoImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(logoLeftTapped:)];
        tap.numberOfTapsRequired = 1;
        [leftIconView addGestureRecognizer: tap];
        
        [mainView addSubview:leftIconView];
    }
    
    if ([NSString isNotEmpty:logoRight]) {
        UIImage *logoImage = [UIImage imageResource:logoRight];
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
        
        rightIconView = [[UIView alloc] initWithFrame:CGRectMake(10, 10 + yOffset, logoImage.size.width, logoImage.size.height)];
        [rightIconView addSubview:logoImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(logoRightTapped:)];
        tap.numberOfTapsRequired = 1;
        [rightIconView addGestureRecognizer: tap];
        
        [mainView addSubview:rightIconView];
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect screen = [UIScreen rectForScreenView:orientation];
    CGRect webViewFrame = CGRectMake(0, LOGO_HEIGHT + yOffset, screen.size.width, screen.size.height - LOGO_HEIGHT - yOffset);
    
    webView = [[UIWebView alloc] initWithFrame:webViewFrame];
    
    [mainView addSubview:webView];
    
    // Add a nav button back to main
    mainButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [mainButton addTarget:self action:@selector(mainButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [mainButton setTitle:@"Main" forState:UIControlStateNormal];
    if (viewConfig.textColor) {
        [mainButton setTitleColor:viewConfig.textColor forState:UIControlStateNormal];
    }
    [mainView addSubview:mainButton];
    
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
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self resizeView:orientation];
    
    NSURL *htmlURL = nil;
    if (htmlResourceNamed) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        htmlURL = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:htmlResourceNamed]];
        [webView loadRequest: [NSURLRequest requestWithURL:htmlURL]];
    } else if (htmlPath) {
        htmlURL = [NSURL fileURLWithPath:htmlPath];
        [webView loadRequest: [NSURLRequest requestWithURL:htmlURL]];
    } else {
        NSLog(@"InfoViewController: no resource specified to display!");
    }
    
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self resizeView:toInterfaceOrientation];
}

#pragma mark -
#pragma mark Private Methods
- (void) resizeView:(UIInterfaceOrientation)interfaceOrientation {
    CGRect screenFrame = [UIScreen rectForScreenView:interfaceOrientation];
    CGSize size = CGSizeMake(screenFrame.size.width, screenFrame.size.height);
    
    CGFloat yOffset = 0.0f;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        // For iOS 7 or later.  This moves things out from under the status bar.
        yOffset = 20.0f;
    }
    
    CGRect webViewFrame = CGRectMake(0, LOGO_HEIGHT + yOffset, size.width, size.height - LOGO_HEIGHT - yOffset);
    
    CGRect frame = self.view.frame;
    frame.size = size;
    self.view.frame = frame;
    
    webView.frame = webViewFrame;
    [webView reload];
    
    mainButton.frame = CGRectMake(0, 10 + yOffset, MAIN_BUTTON_WIDTH, MAIN_BUTTON_HEIGHT);
    [mainButton centerHorizonalOn:self.view];
    
    // Position Right side logo
    if (rightIconView) {
        CGRect rightLogoFrame = rightIconView.frame;
        rightLogoFrame.origin = CGPointMake(size.width - rightLogoFrame.size.width - 10.0f, rightLogoFrame.origin.y + yOffset);
        rightIconView.frame = rightLogoFrame;
    }
}

- (void) logoLeftTapped:(UITapGestureRecognizer *)tapGesture {
    NSString *urlString = viewConfig.leftLogoLink;
    
    if ([NSString isNotEmpty:urlString]) {
        CompanyWebViewController *webViewController = [[CompanyWebViewController alloc] initWithUrl:[NSURL URLWithString:urlString]
                                                                                          andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
        webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:webViewController animated:YES completion:NULL];
    }
}

- (void) logoRightTapped:(UITapGestureRecognizer *)tapGesture {
    NSString *urlString = viewConfig.rightLogoLink;
    
    if ([NSString isNotEmpty:urlString]) {
        CompanyWebViewController *webViewController = [[CompanyWebViewController alloc] initWithUrl:[NSURL URLWithString:urlString]
                                                                                          andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
        webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:webViewController animated:YES completion:NULL];
    }
}

- (void) mainButtonTapped:(id)selector {
    if (self.navigationController) {
        CATransition* transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction
                                     functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionReveal;
        
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

@end

//
//  ToloWebViewController.m
//  ToloApp
//
//  Created by Torey Lomenda on 6/26/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "CompanyWebViewController.h"

#import "UIViewController+ViewControllerLayout.h"
#import "UIView+ViewLayout.h"
#import "UIColor+Chooser.h"
#import "UIScreen+Helpers.h"

#import "SFAppConfig.h"

#import "NSBundle+CatalogFoundationResource.h"
#import "UIImage+CatalogFoundationResourceImage.h"
#import "SketchPadController.h"
#import "UIImage+Resize.h"

#define TOOLBAR_HEIGHT 44.0f

@interface CompanyWebViewController()

- (void) resizeView: (UIInterfaceOrientation) interfaceOrientation;
- (void) closeWebView: (id) sender;

- (void)updateToolbarItems;

- (void)goBackClicked:(UIBarButtonItem *)sender;
- (void)goForwardClicked:(UIBarButtonItem *)sender;
- (void)reloadClicked:(UIBarButtonItem *)sender;
- (void)stopClicked:(UIBarButtonItem *)sender;
- (void)sketchClicked:(UIBarButtonItem *)sender;
- (void)actionButtonClicked:(UIBarButtonItem *)sender;

@end

@implementation CompanyWebViewController

@synthesize toloWebUrl;
@synthesize closeButton;
@synthesize backBarButtonItem;
@synthesize forwardBarButtonItem;
@synthesize refreshBarButtonItem;
@synthesize stopBarButtonItem;
@synthesize sketchBarButtonItem;
@synthesize actionBarButtonItem;
@synthesize toolbar;
@synthesize availableActions;
@synthesize logoImage;

@synthesize config;


- (id)initWithUrl:(NSURL *) url andConfig:(CompanyWebViewConfig *) aConfig {
    self = [super init];
    
    if (self) {
        if (!url.scheme) {
            NSString *modifiedURL = [NSString stringWithFormat:@"http://%@", url.absoluteString];
            url = [NSURL URLWithString:modifiedURL];
        }
        toloWebUrl = url;
        self.availableActions = ToloWebViewControllerAvailableActionsOpenInSafari | ToloWebViewControllerAvailableActionsMailLink;
        logoImage = nil;
        
        self.config = aConfig;
    }

    return self;
}
- (id) initWithUrl: (NSURL *) url andLogo:(UIImage *) logo andConfig:(CompanyWebViewConfig *) aConfig;
{
    self = [super init];    
    if (self) {
        if (!url.scheme) {
            NSString *modifiedURL = [NSString stringWithFormat:@"http://%@", url.absoluteString];
            url = [NSURL URLWithString:modifiedURL];
        }
        toloWebUrl = url;
        self.availableActions = ToloWebViewControllerAvailableActionsOpenInSafari | ToloWebViewControllerAvailableActionsMailLink;
        logoImage = logo;
        
        self.config = aConfig;
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
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    CGFloat yOffset = 0.0f;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        // For iOS 7 or later.  This moves things out from under the status bar.
        yOffset = 20.0f;
    }
    
    UIView *mainView = [[UIView alloc] initWithFrame:bounds];
    if (config.bgColor) {
        mainView.backgroundColor = config.bgColor;
    }
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f + yOffset, bounds.size.width, TOOLBAR_HEIGHT)];
    
    // Setup the Tolo Web View
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect screen = [UIScreen rectForScreenView:orientation];
    CGRect webViewFrame = CGRectMake(0, TOOLBAR_HEIGHT + yOffset, screen.size.width, screen.size.height - TOOLBAR_HEIGHT - yOffset);
    
    toloWebView = [[UIWebView alloc] initWithFrame:webViewFrame];
    toloWebView.delegate = self;
    toloWebView.allowsInlineMediaPlayback = NO;
    toloWebView.mediaPlaybackRequiresUserAction = YES;
    toloWebView.scalesPageToFit = YES;
    
    // Add an activity indicator to load the images in the background
    loadingWebPageIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingWebPageIndicator.hidesWhenStopped = YES;

    
    // Setup Toolbar
    self.closeButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(closeWebView:)]; 
    
    self.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage contentFoundationResourceImageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackClicked:)];
    self.backBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
    backBarButtonItem.width = 18.0f;
    
    self.forwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage contentFoundationResourceImageNamed:@"forward.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goForwardClicked:)];
    self.forwardBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
    self.forwardBarButtonItem.width = 18.0f;
    
    self.refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadClicked:)];
    
    self.stopBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopClicked:)];
    
    self.sketchBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage contentFoundationResourceImageNamed:@"sketch.png"] style:UIBarButtonItemStylePlain target:self action:@selector(sketchClicked:)];
    self.sketchBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
    self.sketchBarButtonItem.width = 18.0f;
    
    
    self.actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];
    
    self.toolbar.barStyle = UIBarStyleBlackTranslucent;
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    if (config) {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.toolbar.barTintColor = config.toolbarTintColor;
            if ([self.toolbar.barTintColor colorIsLight]) {
                self.toolbar.tintColor = [UIColor blackColor];
            } else {
                self.toolbar.tintColor = [UIColor whiteColor];
            }
            self.toolbar.translucent = NO;
        } else {
            self.toolbar.tintColor = config.toolbarTintColor;
        }
    }
    
    [self updateToolbarItems];
                                                  
    [mainView addSubview:self.toolbar];
    [mainView addSubview:toloWebView];
    [mainView addSubview:loadingWebPageIndicator];
    
    
    [self setView:mainView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    // This is useful for releasing memory when loading PDF documents or docs with large images
    // Details:  http://stackoverflow.com/questions/648396/does-uiwebview-leak-memory
    [toloWebView loadHTMLString: @"" baseURL: nil];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self resizeView:orientation];
    
    [toloWebView loadRequest: [NSURLRequest requestWithURL:toloWebUrl]];
    
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
#pragma mark UIWebViewDelegate Methods
- (void) webViewDidStartLoad:(UIWebView *)webView {
    [loadingWebPageIndicator startAnimating];
    [self updateToolbarItems];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [loadingWebPageIndicator stopAnimating];
    [self updateToolbarItems];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Error loading: %@, %@", webView.request.URL.absoluteString, error.localizedDescription);
    [loadingWebPageIndicator stopAnimating];
    [self updateToolbarItems];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
	if([title isEqualToString:NSLocalizedString(@"Open in Safari", @"")])
        [[UIApplication sharedApplication] openURL:toloWebView.request.URL];
    
    if([title isEqualToString:NSLocalizedString(@"Copy Link", @"")]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = toloWebView.request.URL.absoluteString;
    }
    
    else if([title isEqualToString:NSLocalizedString(@"Mail Link to this Page", @"")]) {
        
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        
		mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:[toloWebView stringByEvaluatingJavaScriptFromString:@"document.title"]];
  		[mailViewController setMessageBody:toloWebView.request.URL.absoluteString isHTML:NO];
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
- (void) resizeView:(UIInterfaceOrientation)interfaceOrientation {
    CGRect screenFrame = [UIScreen rectForScreenView:interfaceOrientation];
    
    CGFloat yOffset = 0.0f;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        // For iOS 7 or later.  This moves things out from under the status bar.
        yOffset = 20.0f;
    }
    
    CGSize size = CGSizeMake(screenFrame.size.width, screenFrame.size.height);
    CGRect webViewFrame = CGRectMake(0, TOOLBAR_HEIGHT + yOffset, size.width, size.height - TOOLBAR_HEIGHT - yOffset);
    
    CGRect frame = self.view.frame;
    frame.size = size;
    self.view.frame = frame;
    
    toloWebView.frame = webViewFrame;
    
    loadingWebPageIndicator.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0);
}

- (void)goBackClicked:(UIBarButtonItem *)sender {
    [toloWebView goBack];
}

- (void)goForwardClicked:(UIBarButtonItem *)sender {
    [toloWebView goForward];
}

- (void)reloadClicked:(UIBarButtonItem *)sender {
    [toloWebView reload];
}

- (void)sketchClicked:(UIBarButtonItem *)sender {
    UIImage *previewImage = [[self imageFromView] resizedImage:CGSizeMake(self.view.bounds.size.width - 20*2,
                                                                          self.view.bounds.size.height-TOOLBAR_HEIGHT-20*2) interpolationQuality:kCGInterpolationHigh];

    
    SketchPadController *sketchPadController = [[SketchPadController alloc] 
                                                initWithImage:previewImage 
                                                tintColor:[[SFAppConfig sharedInstance] getSketchViewTintColor]
                                                titleFont:nil
                                                brand:[[SFAppConfig sharedInstance] getBrandTitle]
                                                andBgColor:[[SFAppConfig sharedInstance] getSketchViewBgColor]];
    
    [self presentViewController:sketchPadController animated:YES completion:NULL];
}

- (UIImage *) imageFromView {
    UIGraphicsBeginImageContext(self.view.bounds.size);
    
    [toloWebView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}

- (void)stopClicked:(UIBarButtonItem *)sender {
    [toloWebView stopLoading];
	[self updateToolbarItems];
}

- (void)actionButtonClicked:(id)sender {
    
    UIActionSheet *pageActionSheet = [[UIActionSheet alloc] 
                                      initWithTitle:[toloWebView stringByEvaluatingJavaScriptFromString:@"document.title"]
                                      delegate:self 
                                      cancelButtonTitle:nil   
                                      destructiveButtonTitle:nil   
                                      otherButtonTitles:nil]; 
    
    if((self.availableActions & ToloWebViewControllerAvailableActionsCopyLink) == ToloWebViewControllerAvailableActionsCopyLink)
        [pageActionSheet addButtonWithTitle:NSLocalizedString(@"Copy Link", @"")];
    
    if((self.availableActions & ToloWebViewControllerAvailableActionsOpenInSafari) == ToloWebViewControllerAvailableActionsOpenInSafari)
        [pageActionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", @"")];
    
    if([MFMailComposeViewController canSendMail] && (self.availableActions & ToloWebViewControllerAvailableActionsMailLink) == ToloWebViewControllerAvailableActionsMailLink)
        [pageActionSheet addButtonWithTitle:NSLocalizedString(@"Mail Link to this Page", @"")];
    
    [pageActionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    pageActionSheet.cancelButtonIndex = [pageActionSheet numberOfButtons]-1;
    
    [pageActionSheet showFromBarButtonItem:self.actionBarButtonItem animated:YES];
    
}

- (void) closeWebView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) updateToolbarItems {
    self.backBarButtonItem.enabled = toloWebView.canGoBack;
    self.forwardBarButtonItem.enabled = toloWebView.canGoForward;
    self.actionBarButtonItem.enabled = !toloWebView.isLoading;
    
    UIBarButtonItem *refreshStopBarButtonItem = toloWebView.isLoading ? self.stopBarButtonItem : self.refreshBarButtonItem;
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 5.0f;
    
    UIBarButtonItem *bigFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    bigFixedSpace.width = 30.0f;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSMutableArray *items;
    if(self.availableActions == 0) {
        items = [NSMutableArray arrayWithObjects:
                 self.closeButton,
                 flexibleSpace,
                 refreshStopBarButtonItem,
                 bigFixedSpace,
                 self.backBarButtonItem,
                 bigFixedSpace,
                 self.forwardBarButtonItem,
                 bigFixedSpace,
                 self.sketchBarButtonItem,
                 bigFixedSpace,
                 nil];
    } else {
        items = [NSMutableArray arrayWithObjects:
                 self.closeButton,
                 flexibleSpace,
                 refreshStopBarButtonItem,
                 bigFixedSpace,
                 self.backBarButtonItem,
                 bigFixedSpace,
                 self.forwardBarButtonItem,
                 bigFixedSpace,
                 self.sketchBarButtonItem,
                 bigFixedSpace,
                 self.actionBarButtonItem,
                 fixedSpace,
                 nil];
    }
    
  
    //Add the optional logo to the left corner
    if (logoImage != nil) {
        UIImageView *iv = [[UIImageView alloc] initWithImage:logoImage];
        UIBarButtonItem *logoBarItem = [[UIBarButtonItem alloc] initWithCustomView:iv];
        
        [items insertObject:logoBarItem atIndex:0];
        
        //add this spacer so the logo is flush with the side
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] 
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace 
                                           target:nil action:nil];
        negativeSpacer.width = -20;
        [items insertObject:negativeSpacer atIndex:0];
    }
  
    [self.toolbar setItems:items];

}

@end

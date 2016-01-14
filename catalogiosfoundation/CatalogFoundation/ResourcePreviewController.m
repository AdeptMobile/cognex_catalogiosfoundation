//
//  ProductContentViewController.m
//  ToloApp
//
//  Created by Torey Lomenda on 6/3/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ResourcePreviewController.h"
#import "SketchPadController.h"

#import "ContentSyncManager.h"
#import "AlertUtils.h"
#import "ContentUtils.h"

#import "SFAppConfig.h"

#import "UIView+ViewLayout.h"
#import "UIView+ImageRender.h"
#import "UIColor+Chooser.h"
#import "UIScreen+Helpers.h"
#import "UIImage+Resize.h"
#import "NSNotificationCenter+MainThread.h"

#define TOOLBAR_HEIGHT 44.0f
#define SIDE_MARGIN 20.0f

static NSString * const EMAIL_TEMPLATE = @""
"<p>"
"The <a href=\"%@\">%@</a> document link was sent to you from the %@ iPad app."  
"</p>";
@interface ResourcePreviewController() {
    CGFloat yOffset;
}

- (void) backToMainOnTap:(UITapGestureRecognizer *)tapGesture;
- (void) resizeViews: (UIInterfaceOrientation) interfaceOrientation;

- (void) emailDocumentLink;

@end
@implementation ResourcePreviewController

@synthesize mailSetupDelegate;

- (id) initWithUrl:(NSURL *)url {
    self = [super init];
    
    if (self) {
        // Custom initialization
        doResizeOnWillAppear = YES;
        documentUrl = url;
        
        if (![ContentUtils isMovieFile:[documentUrl path]] && ![ContentUtils isImageFile:[documentUrl path]]) {
            previewController = [[QLPreviewController alloc] init];
            previewController.dataSource = self;
            previewController.delegate = self;
        }
        
        yOffset = 0.0f;
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            // For iOS 7 or later.  This moves things out from under the status bar.
            yOffset = 20.0f;
        }
    }
    return self;
}

- (void)dealloc {
    documentUrl = nil;
    
    if (previewController) {
        previewController = nil;
    }
    
    mailSetupDelegate = nil;
    
}

#pragma mark -
#pragma mark ToloPreviewToolbarDelegate Methods
- (void) sketchButtonTapped:(id)sketchButton {
    UIImage *previewImage = [contentView imageFromView];
    previewImage = [previewImage resizedImage:CGSizeMake(self.view.bounds.size.width - 20*2, 
                                                         self.view.bounds.size.height - TOOLBAR_HEIGHT - yOffset - 20*2) interpolationQuality:kCGInterpolationHigh];
    
    SketchPadController *sketchPadController = [[SketchPadController alloc] 
                                                initWithImage:previewImage 
                                                tintColor:[[SFAppConfig sharedInstance] getSketchViewTintColor]
                                                titleFont:nil
                                                brand:[[SFAppConfig sharedInstance] getBrandTitle]
                                                andBgColor:[[SFAppConfig sharedInstance]getSketchViewBgColor]];
    
    [self presentViewController:sketchPadController animated:YES completion:NULL];
}

- (void) closeButtonTapped:(id)closeButton {
    
    if (previewView && [previewView isMemberOfClass:[UIWebView class]]) {
        // This is useful for releasing memory when loading PDF documents or docs with large images
        // Details:  http://stackoverflow.com/questions/648396/does-uiwebview-leak-memory
        [((UIWebView *) previewView) loadHTMLString: @"" baseURL: nil];

    }
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    if (previewController) {
        [previewController dismissViewControllerAnimated:NO completion:NULL];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) documentActionSelected:(DocActionType) docActionType {
    // Send e-mail link
    if (docActionType == DOC_ACTION_EMAIL_LINK) {
        [self emailDocumentLink];
    }
}

#pragma mark -
#pragma mark Quick Look Preview Data Source Methods
- (NSInteger) numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index {
    return documentUrl;
}

#pragma mark -
#pragma mark QLPreviewControllerDelegate Methods
- (BOOL) previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id<QLPreviewItem>)item {
    return YES;
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate Methods
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
    if (result == MFMailComposeResultSent) {
        
        [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"E-mail sent."] withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
        
        NSString *sharedDocument = [NSString stringWithFormat:@"/%@", [documentUrl lastPathComponent]];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:sharedDocument forKey:@"sharedDocument"];
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"contentDocumentShared" object:self userInfo:[NSDictionary dictionaryWithDictionary:dict]];
        
    } else if (result == MFMailComposeResultFailed) {
        
        [AlertUtils showModalAlertMessage:@"Sending of e-mail failed." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return previewImageView;
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    CGFloat rectScale = scale;
    
    if (rectScale < scrollView.minimumZoomScale) {
        rectScale = scrollView.minimumZoomScale;
    } else if (rectScale > scrollView.maximumZoomScale) {
        rectScale = scrollView.maximumZoomScale;
    }
    
    CGRect zoomFrame = view.frame;
    zoomFrame.size = CGSizeMake(previewView.bounds.size.width*rectScale, previewView.bounds.size.height*rectScale);
    view.frame = zoomFrame;
}


#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
    
    CGRect screen = [UIScreen rectForScreenView:[[UIApplication sharedApplication] statusBarOrientation]];
    CGSize size = screen.size;
    
    ResourcePreviewConfig *previewConfig = [[SFAppConfig sharedInstance] getPortfolioResourcePreviewConfig];
    
    UIView *mainView = [[UIView alloc] initWithFrame:screen];
    mainView.backgroundColor = previewConfig.previewMainBgColor;
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(20, TOOLBAR_HEIGHT + 20 + yOffset, size.width - 20, size.height - TOOLBAR_HEIGHT - 20 - yOffset)];
    contentView.backgroundColor = previewConfig.previewContentBgColor;
    
    // load the "nested" controller view as a subview
    if (previewController) {
        [previewController loadView];
    }
    
    // How are we going to preview the document (Quick Look or Web View)
    if ([ContentUtils isMovieFile:[documentUrl path]]) {
        previewView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        previewView.userInteractionEnabled = YES;
        ((UIWebView * )previewView).scalesPageToFit = YES;
    } else if ([ContentUtils isImageFile:[documentUrl path]]) {
         previewView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        ((UIScrollView * )previewView).maximumZoomScale = 5.0;
        ((UIScrollView * )previewView).minimumZoomScale = 0.5;
        ((UIScrollView * )previewView).bouncesZoom = YES;
        ((UIScrollView * )previewView).delegate = self;
    } else {
        previewView = previewController.view;
    }
    
    // Initialize the content view (embed the preview in the content view
    [contentView addSubview:previewView];
    
    // Add the toolbar
    toloToolbar = [[ResourcePreviewToolbarView alloc] initWithFrame:CGRectMake(0, yOffset, size.width, TOOLBAR_HEIGHT)];
    toloToolbar.resourceToolbarDelegate = self;
    
    [mainView addSubview:toloToolbar];
    [mainView addSubview:contentView];
    
    [self setView:mainView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (previewController) {
        [previewController viewDidLoad];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    if (previewController) {
        [previewController viewDidUnload];
    }
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self resizeViews:orientation];
    
    if ([ContentUtils isMovieFile:[documentUrl path]]) {
        [((UIWebView *) previewView) loadRequest:[NSURLRequest requestWithURL:documentUrl]];
    } else if ([ContentUtils isImageFile:[documentUrl path]]) {
        if ([previewView.subviews count] == 0) {
            ResourcePreviewConfig *previewConfig = [[SFAppConfig sharedInstance] getPortfolioResourcePreviewConfig];
            UIImage *preview = [UIImage imageWithContentsOfFile:[documentUrl path]];
            
            previewImageView = [[UIImageView alloc] initWithFrame:previewView.bounds];
            previewImageView.contentMode = UIViewContentModeScaleAspectFit;
            previewImageView.backgroundColor = previewConfig.previewContentImageBgColor;
            
            if (preview) {
                previewImageView.image = preview;
            }
            [previewView addSubview:previewImageView];

        }
    } else if (previewController) {
        // Need to reload to data
        [previewController viewWillAppear:animated];
    }
    
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
    
    if (previewController) {
        [previewController viewDidAppear:animated];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    // Return YES for supported orientations
	return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self resizeViews:toInterfaceOrientation];  
}

#pragma mark -
#pragma mark Private Methods
- (void) backToMainOnTap:(UITapGestureRecognizer *)tapGesture {
    if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
        [((UINavigationController *) self.parentViewController) popViewControllerAnimated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) resizeViews:(UIInterfaceOrientation)interfaceOrientation {
    CGRect screenFrame = [UIScreen rectForScreenView:interfaceOrientation];
    CGSize size = CGSizeMake(screenFrame.size.width, screenFrame.size.height);
    CGFloat widthBounds = screenFrame.size.width;
    
    // Resize the toolbar
    CGRect toolbarFrame = CGRectMake(0, yOffset, widthBounds, TOOLBAR_HEIGHT);
    toloToolbar.frame = toolbarFrame;
    
    // Set the size for the content view
    CGRect contentFrame = CGRectMake(20, TOOLBAR_HEIGHT + 20 + yOffset, size.width - 20, size.height - TOOLBAR_HEIGHT - 20 - yOffset);
    contentView.frame = contentFrame;
    
    if (doResizeOnWillAppear || interfaceOrientation != self.interfaceOrientation) {
        CGRect previewFrame = CGRectMake(0, 0, contentFrame.size.width - 20, contentFrame.size.height - 20);
        previewView.frame = previewFrame;
        
        if ([previewView isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView * )previewView).contentSize = previewFrame.size;
        }
             
        if (previewImageView) {
            previewImageView.frame = CGRectMake(0, 0, previewFrame.size.width, previewFrame.size.height);
        }
        
        doResizeOnWillAppear = NO;
    }

}

- (void) emailDocumentLink {
    ContentMetaData *metadata = [[ContentSyncManager sharedInstance] getAppContentMetaData];
    ContentItem *item = [metadata getContentItemAtPath:[documentUrl path]];
    
    if (item) {

        MFMailComposeViewController *emailDialog = nil;
        
        if (mailSetupDelegate && [mailSetupDelegate respondsToSelector:@selector(setupEmailForContentItem:)]) {
            emailDialog = [mailSetupDelegate setupEmailForContentItem:item];
        } 
        
        if (emailDialog == nil) {
            emailDialog = [[MFMailComposeViewController alloc] init];
            if ([MFMailComposeViewController canSendMail]){
                NSString *emailBody = [NSString 
                                       stringWithFormat:EMAIL_TEMPLATE,
                                       item.downloadUrl, item.name, [[SFAppConfig sharedInstance] getBrandTitle]];
                
                NSString *subject = [NSString stringWithFormat:@"Sharing %@ Document", [[SFAppConfig sharedInstance] getBrandTitle]];
                [emailDialog setSubject:subject];
                [emailDialog setMessageBody:emailBody isHTML:YES];
            }
        }
        
        if ([MFMailComposeViewController canSendMail]){
            emailDialog.mailComposeDelegate = self;
            emailDialog.modalPresentationStyle = UIModalPresentationPageSheet;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:emailDialog animated:YES completion:NULL];
            });
        }

    }
}

@end

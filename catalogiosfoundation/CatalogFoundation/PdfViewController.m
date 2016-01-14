//
//  PdfViewController.m
//  ToloApp
//
//  Created by Torey Lomenda on 7/14/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

//#import <FastPdfKit/FastPdfKit.h>

#import "PdfViewController.h"
#import "PdfViewControllerConfig.h"

#import "SketchPadController.h"
#import "CompanyWebViewController.h"

#import "ContentSyncManager.h"

#import "SFAppConfig.h"

#import "UIView+ViewLayout.h"
#import "UIView+ImageRender.h"
#import "UIColor+Chooser.h"
#import "UIImage+Resize.h"
#import "UIScreen+Helpers.h"
#import "NSNotificationCenter+MainThread.h"

#import "ContentUtils.h"
#import "AlertUtils.h"

#define STATUS_BAR_HEIGHT 20.0f
#define TOOLBAR_HEIGHT 44.0f

#define PDF_MARGIN_TOP 20.0f
#define PDF_MARGIN_LEFT 20.0f
#define PDF_MARGIN_RIGHT 20.0f
#define PDF_MARGIN_BOTTOM 20.0f

#define PAGE_SLIDER_LABEL_X 20.0f
#define PAGE_SLIDER_LABEL_WIDTH 100.0f
#define PAGE_SLIDER_HEIGHT 20.0f
#define PAGE_SLIDER_MARGIN 5.0f


#define PDFVIEW_INDEX 0

static NSString * const EMAIL_TEMPLATE = @""
"<p>"
"The <a href=\"%@\">%@</a> document link was sent to you from the %@ iPad app."  
"</p>";

@class MFDocumentManager;
@interface PdfViewController() {
    CGFloat yOffset;
}

- (void) resizeView: (UIInterfaceOrientation) interfaceOrientation;
- (void) resizeViewToSize:(CGSize)mySize;

-(void) actionPageSliderStopped:(id)sender;
-(void) actionPageSliderSlided:(id)sender;

- (void) showToolbarAndSlider:(UITapGestureRecognizer *) tapGesture;

- (void) emailDocumentLink;

@end
@implementation PdfViewController

@synthesize mailSetupDelegate;
@synthesize docManager;

#pragma mark - init/dealloc
- (id) initWithUrl:(NSURL *)url {
    MFDocumentManager *aDocManager = [[MFDocumentManager alloc]initWithFileUrl:url];
    
    self = [super initWithDocumentManager:aDocManager];
    
    if (self) {
        // Custom initialization
        docManager = aDocManager;
        documentUrl = url;
        
        self.documentDelegate = self;
        
        yOffset = 0.0f;
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            // For iOS 7 or later.  This moves things out from under the status bar.
            yOffset = 20.0f;
            // This will move the PDF view in 20 pts on each side.  Since this view
            // subclasses MFDocumentViewController the default behavior is to use the
            // entire view assigned to the controller, making it more difficult to
            // handle the shift down.  SMM
            self.padding = 20.0f;
        }
    }
    
    return self;
}

- (void)dealloc {
    documentUrl = nil;
    
    
    mailSetupDelegate = nil;
    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
#pragma mark ToloPreviewToolbarDelegate Methods
- (void) sketchButtonTapped:(id)sketchButton {
    
    // Before capturing image hide the tool buttons
    toloToolbar.alpha = 0;
    pageSlider.alpha = 0;
    pageLabel.alpha = 0;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImage *previewImage = [self.view imageFromView];
    previewImage = [previewImage resizedImage:CGSizeMake(self.view.bounds.size.width - PDF_MARGIN_LEFT - PDF_MARGIN_RIGHT, 
                                                         self.view.bounds.size.height - TOOLBAR_HEIGHT -PDF_MARGIN_TOP - PDF_MARGIN_BOTTOM - yOffset) interpolationQuality:kCGInterpolationHigh];
    
    SketchPadController *sketchPadController = [[SketchPadController alloc] 
                                                initWithImage:previewImage 
                                                tintColor:[[SFAppConfig sharedInstance] getSketchViewTintColor]
                                                titleFont:nil
                                                brand:[[SFAppConfig sharedInstance] getBrandTitle]
                                                andBgColor:[[SFAppConfig sharedInstance]getSketchViewBgColor]];
    
    [self presentViewController:sketchPadController animated:YES completion:NULL];
    
    toloToolbar.alpha = 1;
    pageSlider.alpha = 1;
    pageLabel.alpha = 1;
    self.view.backgroundColor = [[SFAppConfig sharedInstance] getPortfolioResourcePreviewConfig].previewContentPdfBgColor;
}

- (void) closeButtonTapped:(id)closeButton {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) bookmarkButtonTapped:(id)bookmarkButton {
    toloToolbar.currentPage = self.page;
}

- (void) bookmarkSelectPage:(NSUInteger)pageSelected {
    [self setPage:pageSelected];
    
    // Update the label.
	[pageLabel setText:[NSString stringWithFormat:@"%lu/%lu",(unsigned long)pageSelected,(unsigned long)[[self document]numberOfPages]]];
    [pageSlider setValue:[[NSNumber numberWithUnsignedInteger:pageSelected]floatValue] animated:YES];
}

- (void) outlineSelectPage:(NSUInteger)pageSelected {
    [self setPage:pageSelected];
    
    // Update the label.
	[pageLabel setText:[NSString stringWithFormat:@"%lu/%lu",(unsigned long)pageSelected,(unsigned long)[[self document]numberOfPages]]];
    [pageSlider setValue:[[NSNumber numberWithUnsignedInteger:pageSelected]floatValue] animated:YES];
}

- (void) documentActionSelected:(DocActionType)docActionType {
    // Send e-mail link
    if (docActionType == DOC_ACTION_EMAIL_LINK) {
        [self emailDocumentLink];
    }
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isMemberOfClass:[UITapGestureRecognizer class]] && touch.tapCount == 1) {
            CGPoint currentTouchPosition = [touch locationInView:self.view];
        
            // If touched near middle of the toolbar receive the touch
        if (currentTouchPosition.y <= TOOLBAR_HEIGHT + yOffset && currentTouchPosition.y >= 0) {
            CGFloat width = self.view.bounds.size.width;
            if (currentTouchPosition.x >= ((width / 2.0f) - 100.0f) && currentTouchPosition.x <= ((width / 2.0f) + 100.0f)) {
                return YES;
            }
        }
    }
    
    return NO;
}


#pragma mark -
#pragma mark MFDocumentViewControllerDelegate Methods
- (void) documentViewController:(MFDocumentViewController *)dvc didGoToPage:(NSUInteger)aPage {
    // Update the label.
	[pageLabel setText:[NSString stringWithFormat:@"%lu/%lu",(unsigned long)aPage,(unsigned long)[[self document]numberOfPages]]];
    [pageSlider setValue:[[NSNumber numberWithUnsignedInteger:aPage]floatValue] animated:YES];
}

-(void)documentViewController:(MFDocumentViewController *)dvc didReceiveURIRequest:(NSString *)uri {
    NSURL *url = [NSURL URLWithString:uri];
    
    CompanyWebViewController *webViewController = [[CompanyWebViewController alloc] initWithUrl:url
                                                                                      andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
    
    webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:webViewController animated:YES completion:NULL];
}

#pragma mark - View lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    UIView *mainView = [[UIView alloc] initWithFrame:[UIScreen rectForScreenView:orientation]];
    mainView.backgroundColor = [[SFAppConfig sharedInstance] getPortfolioResourcePreviewConfig].previewContentPdfBgColor;
        
    UITapGestureRecognizer *hideToolsTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(showToolbarAndSlider:)];
    hideToolsTap.numberOfTapsRequired = 1;
    hideToolsTap.delegate = self;
    [mainView addGestureRecognizer: hideToolsTap];
    
    [self setView:mainView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect screen = [UIScreen rectForScreenView:orientation];
    
    // Add the toolbar
    toloToolbar = [[PdfPreviewToolbarView alloc] initWithFrame:CGRectMake(0.0f, yOffset, screen.size.width, TOOLBAR_HEIGHT)];
    toloToolbar.pdfToolbarDelegate = self;
    toloToolbar.document = self.document;
    toloToolbar.bookmarkingDocId = [documentUrl path];
    
    [self.view addSubview:toloToolbar];
    
    
    // Page sliders and label, bottom margin
    // |<-- 20 px -->| Label (80 x 40 px) |<-- 20 px -->| Slider ((view_width - labelwidth - padding) x 40 px) |<-- 20 px -->|
	CGSize viewSize = self.view.bounds.size;
    
    // Page label
    pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(PAGE_SLIDER_LABEL_X, viewSize.height -(PAGE_SLIDER_MARGIN + PAGE_SLIDER_HEIGHT), PAGE_SLIDER_LABEL_WIDTH, PAGE_SLIDER_HEIGHT)];
    [pageLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    [pageLabel setBackgroundColor:[UIColor clearColor]];
    [pageLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [pageLabel setText:[NSString stringWithFormat:@"%lu/%lu",(unsigned long)[self page],(unsigned long)[[self document]numberOfPages]]];
    [pageLabel setTextAlignment:NSTextAlignmentLeft];
    
    //pageLabel.hidden = YES;
    [self.view addSubview:pageLabel];
    
    //Page slider.
    pageSlider = [[UISlider alloc]initWithFrame:CGRectMake(PAGE_SLIDER_LABEL_X+PAGE_SLIDER_LABEL_WIDTH, 
                                                           viewSize.height - (PAGE_SLIDER_MARGIN +PAGE_SLIDER_HEIGHT),
                                                           self.view.bounds.size.width-(PAGE_SLIDER_LABEL_X+PAGE_SLIDER_LABEL_WIDTH)-PAGE_SLIDER_MARGIN*2, 
                                                           PAGE_SLIDER_HEIGHT)];
    [pageSlider setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth];
    // Why not clearColor?
    [pageSlider setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
    [pageSlider setMinimumValue:1.0];
    [pageSlider setMaximumValue:[[self document] numberOfPages]];
    [pageSlider setContinuous:YES];
    [pageSlider addTarget:self action:@selector(actionPageSliderSlided:) forControlEvents:UIControlEventValueChanged];
    [pageSlider addTarget:self action:@selector(actionPageSliderStopped:) forControlEvents:UIControlEventTouchUpInside];
    // Check which page we are on.  May have set a starting page.
    [pageSlider setValue:[[NSNumber numberWithUnsignedInteger:[self page]]floatValue] animated:NO];
    //pageSlider.hidden = YES;
    [self.view addSubview:pageSlider];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self resizeView:orientation];
    
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
    
    PdfViewControllerConfig *config = [[SFAppConfig sharedInstance] getPdfViewControllerConfig];
    
    if (config.autoFadeToolbar == YES) {
        // Fade out the toolbar and slider automatically "for better viewing".  Actually it just
        // confuses people because they don't know to tap at the top to bring the toolbar back and
        // exit the document viewer.  This defaults to NO.  SMM
        [UIView animateWithDuration:1.0 animations:^{
            [self showToolbarAndSlider:nil];
        }];
    }

    // Needed for iOS 8 to enable full rotation for this controller while the rest
    // of the app stays landscape.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(enableRotation)]) {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(enableRotation)];
    }
#pragma clang diagnostic pop
    

}

- (void) viewWillDisappear:(BOOL)animated {
    
    // Needed for iOS 8 to enable full rotation for this controller while the rest
    // of the app stays landscape
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(disableRotation)]) {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(disableRotation)];
    }
#pragma clang diagnostic pop
    
}

- (void) viewDidDisappear:(BOOL)animated {
    // Empty the cache so we don't have artifacts from previous PDF's
    // showing up in subsequent documents.
    [super cleanUp];
    [docManager emptyCache];
    
    [super viewDidDisappear:animated];
}

//added to support iOS 6 rotation issue
- (BOOL)shouldAutorotate
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self resizeView:toInterfaceOrientation];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    if ([self.view.backgroundColor colorIsLight]) {
        return UIStatusBarStyleDefault;
    } else {
        return UIStatusBarStyleLightContent;
    }
}

#pragma mark - iOS 8 View Size Change Support
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self resizeViewToSize:size];
}

#pragma mark -
#pragma mark Private Methods
- (void) resizeView:(UIInterfaceOrientation)interfaceOrientation {
    CGRect screenFrame = [UIScreen rectForScreenView:interfaceOrientation];
    CGSize size = CGSizeMake(screenFrame.size.width, screenFrame.size.height);
    [self resizeViewToSize:size];
}

- (void) resizeViewToSize:(CGSize)mySize {
    // Resize the toolbar
    CGRect toolbarFrame = CGRectMake(0, yOffset, mySize.width, TOOLBAR_HEIGHT);
    toloToolbar.frame = toolbarFrame;
}

-(void) actionPageSliderStopped:(id)sender {
	
	// We move to the page only if the user release the slider (on UITouchUpInside).
	
	// Cancel the previous request for thumbnail, we don't need it.
	//[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showThumbnailView) object:nil];
	//[self hideThumbnailView];
	
	// Get the requested page number from the slider.
	UISlider *slider = (UISlider *)sender;
	NSNumber *number = [NSNumber numberWithFloat:[slider value]];
	NSUInteger pageNumber = [number unsignedIntValue];
	
	// Go to the page.
	[self setPage:pageNumber];
}

-(void) actionPageSliderSlided:(id)sender {
    
	// When the user move the slider, we update the label and queue a selector to generate a thumbnail for the page if
	// the user hold the slider for at least 1 second without moving it.
	
	// Cancel the previous request if any.
	//[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showThumbnailView) object:nil];
	//[self hideThumbnailView];
	
	// Start a new one.
	//[self performSelector:@selector(showThumbnailView) withObject:nil afterDelay:1.0];
	
	// Get the slider value.
	UISlider *slider = (UISlider *)sender;
	NSNumber *number = [NSNumber numberWithFloat:[slider value]];
	NSUInteger pageNumber = [number unsignedIntValue];
	
	//We use the instance's thumbPage variable to avoid passing a number to the selector each time.
	//thumbPage = pageNumber;
	
	// Update the label.
	[pageLabel setText:[NSString stringWithFormat:@"%lu/%lu",(unsigned long)pageNumber,(unsigned long)[[self document]numberOfPages]]];
}

- (void) showToolbarAndSlider:(UITapGestureRecognizer *)tapGesture {
    // TODO - Need to make the toolbar autofade configurable.  SMM
        if (pageLabel.alpha == 1) {
            toloToolbar.alpha = 0;
            pageLabel.alpha = 0;
            pageSlider.alpha = 0;
        } else {
            toloToolbar.alpha = 1;
            pageLabel.alpha = 1;
            pageSlider.alpha = 1;
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
            if ([MFMailComposeViewController canSendMail]) {
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

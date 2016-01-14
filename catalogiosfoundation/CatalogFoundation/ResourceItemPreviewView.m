//
//  ResourceItemPreviewView.m
//  ToloApp
//
//  Created by Torey Lomenda on 7/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ResourceItemPreviewView.h"

#import "ResourceListPreviewView.h"

#import "OPIFoundation.h"

#import "SFAppConfig.h"
#import "ContentUtils.h"

#import "AlertUtils.h"
#import "ContentSyncManager.h"

#import "NSArray+Helpers.h"
#import "UIImage+Resize.h"
#import "UIImage+Alpha.h"
#import "UIView+ViewLayout.h"
#import "UIColor+Chooser.h"
#import "UITextView+Extensions.h"
#import "NSNotificationCenter+MainThread.h"
#import "NSDictionary+ContentViewBehavior.h"
#import "ContentLookup.h"
#import "AbstractPortfolioViewController.h"
#import "UIAlertView+Block.h"
#import "UIScreen+Helpers.h"
#import "UIImage+Extensions.h"
#import "NSString+StringFormatters.h"
#import "UIApplication+WindowOverlay.h"

#import "PdfViewController.h"
#import "CompanyWebViewController.h"
#import "ResourceMoviePlayer.h"

static NSString * const EMAIL_TEMPLATE = @""
"<p>"
"The <a href=\"%@\">%@</a> document link was sent to you from the %@ iPad app."  
"</p>";

#define LABEL_WIDTH 45.0f
#define LABEL_OFFSET 0.0f

@interface ResourceItemPreviewView()

- (void) setupPreviewImageView;
- (void) setupPreviewLabel;

- (void) presentOptionsMenu: (UILongPressGestureRecognizer *) longPressGesture;
- (void) presentOptionsMenu;
- (void) openDocument: (UITapGestureRecognizer *) tapGesture;
- (void) openDocument;
- (void) shareDocument: (UITapGestureRecognizer *) tapGesture;
- (AFHTTPRequestOperation *) downloadDocumentThen:(void(^)(AFHTTPRequestOperation *, BOOL, NSError *))block;
- (void) dismissDownloadProgress;
- (void) cancelDownload:(UIButton *)sender;

- (BOOL) allowOpenDocument;

@end

@implementation ResourceItemPreviewView
@synthesize previewImageView;

@synthesize productNavigationController;
@synthesize docInteractionController;
@synthesize overlayController;
@synthesize mailSetupDelegate;

@synthesize resourceImageStatusDelegate;

- (id)initWithFrame:(CGRect)frame productNavController:(UIViewController *)productNavController andResourceItem:(id<ContentViewBehavior>)aResourceItem {
    ResourcePreviewConfig *config = [[ResourcePreviewConfig alloc] init];
    return [self initWithFrame:frame productNavController:productNavController andResourceItem:aResourceItem andConfig:config];
}

-(id)initWithFrame:(CGRect)frame productNavController:(UIViewController *)productNavController andResourceItem:(id<ContentViewBehavior>)aResourceItem andConfig:(ResourcePreviewConfig *)config {
    
    NSURL *actualUrl = nil;
    if ([aResourceItem contentFilePath]) {
        actualUrl = [NSURL fileURLWithPath:[aResourceItem contentFilePath]];
    }
    
    NSString *labelPresent = [aResourceItem contentTitle];
    NSURL *linkPresent = [aResourceItem contentLink];
    NSString *previewPresent = [aResourceItem contentThumbNail];
    NSNumber *startAtPage = [aResourceItem contentStartPage];
    
    CGRect selfFrame = frame;
    
    if (labelPresent && !config.usesTitleOverlay) {
        selfFrame.size.width = frame.size.width + LABEL_WIDTH;
    }
    
    self = [super initWithFrame:selfFrame];
    
    if (self) {
        // Initialization code
        resourceItem = aResourceItem;
        viewConfig = config;
        productNavigationController = productNavController;
        resourceItemUrl = actualUrl;
        // Only used for PDF display.  Otherwise it is ignored.
        if (startAtPage) {
            resourceStartPage = startAtPage;
        }
        
        // Add the View to highlight when thumbnail is selected
        highlightedView = [[UIView alloc] initWithFrame:CGRectZero];
        highlightedView.backgroundColor = [[SFAppConfig sharedInstance] getPortfolioResourcePreviewConfig].previewThumbHighlightBgColor;
        highlightedView.alpha = 0.4;
        highlightedView.hidden = YES;
        
        overlayController = [[ExpandOverlayViewController alloc] init];
        overlayController.dismissButton = nil;
        
        // If a label is present, I need to adjust the width
        if (labelPresent) {
            resourceItemLabel = labelPresent;
        }
        
        if (linkPresent) {
            resourceExternalLink = linkPresent;
        }
        
        if (previewPresent) {
            resourcePreviewImagePath = previewPresent;
        }
        
        [self addSubview:highlightedView];
        [self setupPreviewImageView];

        [self setupPreviewLabel];
    }
    return self;
}

- (void)dealloc {
    
    labelTabView = nil;
    previewLabel = nil;
    viewConfig = nil;
    
    
    resourceStartPage = nil;
    
    resourceItemUrl = nil;
    
    resourceItemLabel = nil;
    
    resourceExternalLink = nil;

    resourcePreviewImagePath = nil;
    
    
    resourceItem = nil;
    
    mailSetupDelegate = nil;
    
    
}

#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate Methods
- (UIViewController *) documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self.productNavigationController;
}

#pragma mark -
#pragma mark Layout and drawing code
- (void) layoutSubviews {
    [super layoutSubviews];
    
    highlightedView.frame = self.bounds;
    [self applyBorderStyle:[UIColor clearColor] withShadow:YES];
    
    if (previewTextView && !viewConfig.usesTitleOverlay) {
        [previewTextView alignTextVertically];
        
        [previewTextView applyBorderStyle:viewConfig.previewThumbLabelBorderColor withBorderWidth:1.0 withShadow:NO];
    }
    
    if (viewConfig.usesTitleOverlay) {
        [self bringSubviewToFront:previewTextView];
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark -
#pragma mark Public Methods
- (UIImage *) loadPreviewImage {
    // Setup the preview image
    UIImage *previewImage = nil;
    if (resourcePreviewImagePath) {
        previewImage = [UIImage imageWithContentsOfFile:resourcePreviewImagePath];
    } else if (resourceItemUrl) {
        previewImage = [ContentUtils itemContentPreviewImage:[resourceItemUrl path]];
    }
    
    if (previewImage) {
        if (resourceItemLabel && !viewConfig.usesTitleOverlay) {
            previewImage = [previewImage scaleAndCropImageForSize:CGSizeMake(self.bounds.size.width-LABEL_WIDTH, self.bounds.size.height)];
        } else {
            previewImage = [previewImage scaleAndCropImageForSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height)];
        }
    } else if ([docInteractionController.icons count] > 0) {
        // Use the document interaction controller
        NSInteger iconCount = [docInteractionController.icons count];
        previewImage = [docInteractionController.icons objectAtIndex:iconCount - 1];
    }
    
    // See if the resource is on the local storage.  If not, assume that it was
    // suppressed from the sync and should be shown as a "ghost" icon.
    BOOL resourceExists = [ContentUtils fileExists:[resourceItemUrl path]];
    BOOL isProduct = [[resourceItem contentType] isEqualToString:CONTENT_TYPE_INDUSTRY_PRODUCT];
    if (isProduct == NO && resourceExists == NO) {
        previewImage = [previewImage imageByApplyingAlpha:0.5f];
    }
    
    return previewImage;
}

- (void) previewImageLoaded:(UIImage *) image {
    // Stop and remove the indicator
    [previewImageLoadingView stopAnimating];
    previewImageLoadingView.hidden = YES;
    
    ResourcePreviewConfig *previewConfig = [[SFAppConfig sharedInstance] getPortfolioResourcePreviewConfig];
    
    if (image) {
        if (resourceItemLabel && !viewConfig.usesTitleOverlay) {
            self.previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width-LABEL_WIDTH, self.bounds.size.height)];
        } else {
            self.previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        }
        previewImageView.backgroundColor = previewConfig.previewThumbBgColor;
        previewImageView.contentMode = UIViewContentModeScaleAspectFit;
        previewImageView.image = image;
        
       
        [self addSubview:previewImageView];
        
    } else {
        UILabel *noPreviewView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        noPreviewView.backgroundColor = [UIColor clearColor];
        noPreviewView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        noPreviewView.backgroundColor = previewConfig.previewThumbNoPreviewBgColor;
        
        noPreviewView.text = @"No Preview Available";
        noPreviewView.textColor = previewConfig.previewThumbNoPreviewTextColor;
        noPreviewView.textAlignment = NSTextAlignmentCenter;
        noPreviewView.font = [UIFont systemFontOfSize:14];
        noPreviewView.adjustsFontSizeToFitWidth = YES;
        [self addSubview:noPreviewView];
    }
}

#pragma mark -
#pragma mark Private Methods
- (void) setupPreviewImageView {
    if (resourceItemUrl && [resourceItemUrl isFileURL] == YES) {
        // Setup the document interaction controller
        docInteractionController = [[UIDocumentInteractionController alloc] init];
        docInteractionController.URL = resourceItemUrl;
        docInteractionController.delegate = self;
    
        // Add an activity indicator to load the images in the background
        previewImageLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        previewImageLoadingView.center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        
        [previewImageLoadingView startAnimating];
        [self addSubview:previewImageLoadingView];
    }     
    
    // Setup gestures for the view
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(presentOptionsMenu:)];
    [self addGestureRecognizer:longPressGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareDocument:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGesture];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openDocument:)];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [self addGestureRecognizer:tapGesture];
    
    

}

- (void) setupPreviewLabel {
    ResourcePreviewConfig *previewConfig = [[SFAppConfig sharedInstance] getPortfolioResourcePreviewConfig];
    
    if (resourceItemLabel && !viewConfig.usesTitleOverlay) {
        float fontSize = 16.0f;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            fontSize = 15.0f;
        }
        
        labelTabView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-LABEL_WIDTH, 0,
                                                                LABEL_WIDTH, self.bounds.size.height-LABEL_OFFSET)];
        labelTabView.backgroundColor = previewConfig.previewThumbLabelBgColor;
        
        
        previewLabel = [[UICustomLabel alloc] initWithFrame:CGRectMake(0, 0, LABEL_WIDTH, self.bounds.size.height-LABEL_OFFSET)
                                           andVerticalAlign:VerticalAlignmentMiddle];
        
        previewLabel.adjustsFontSizeToFitWidth = YES;
        previewLabel.backgroundColor = [UIColor clearColor];
        previewLabel.textAlignment = NSTextAlignmentCenter;
        previewLabel.textColor = previewConfig.previewThumbLabelTextColor;
        previewLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        previewLabel.lineBreakMode = NSLineBreakByWordWrapping;
        previewLabel.numberOfLines = 0;
        previewLabel.text = resourceItemLabel;
        
        [labelTabView addSubview:previewLabel];
        [self addSubview:labelTabView];
        
        [labelTabView rotateView:-270];
        
        labelTabView.frame = CGRectMake(self.bounds.size.width-LABEL_WIDTH, 0,
                                        LABEL_WIDTH, self.bounds.size.height-LABEL_OFFSET);
        previewLabel.frame = CGRectMake(0, 0, self.bounds.size.height-LABEL_OFFSET,LABEL_WIDTH);
        
        [labelTabView applyBorderStyle:[UIColor clearColor] withShadow:NO];
    }
    else if (resourceItemLabel) {
        
        previewTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        previewTextView.font = viewConfig.titleFont;
        
        // See if the resource is on the local storage.  If not, assume that it was
        // suppressed from the sync and should be shown as a "ghost" icon.
        BOOL resourceExists = [ContentUtils fileExists:[resourceItemUrl path]];
        BOOL isProduct = [[resourceItem contentType] isEqualToString:CONTENT_TYPE_INDUSTRY_PRODUCT];
        if (isProduct == YES || resourceExists == YES) {
            previewTextView.textColor = viewConfig.titleColor;
            previewTextView.backgroundColor = viewConfig.overlayColor;
        } else {
            previewTextView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
            previewTextView.textColor = [UIColor blackColor];
        }
        
        // If we set the alpha here it makes the text transluctent as well which is difficult to read.
        // If an image is used, the transparency needs to be taken care of in the image itself, meaning
        // it needs to be something that supports an alpha channel like a png file.  SMM
        // previewTextView.alpha = 0.5;
        previewTextView.scrollEnabled = NO;
        previewTextView.editable = NO;
        previewTextView.userInteractionEnabled = NO;
        
        previewTextView.text = resourceItemLabel;
        
        [self addSubview:previewTextView];
    }
    
}

- (void) presentOptionsMenu:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {

        if ([ContentUtils fileExists:[resourceItemUrl path]] && [ContentUtils isMovieFile:[resourceItemUrl path]] && [ContentUtils isVideoSyncDisabled] ) {
            
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Video Filtering Enabled"
                                                                message:@"Remove this video from device to save space?"
                                                               delegate:self cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"OK", nil];
                [alert showWithCompletion:^(UIAlertView *anAlertView, NSInteger buttonIndex) {
                    
                    if (buttonIndex == 1) {     //OK. Remove video file from device.
                        [ContentUtils removeFile:[resourceItemUrl path]];
                    } else {
                        if ([[resourceItem contentType] isEqualToString:CONTENT_TYPE_INDUSTRY_PRODUCT] || [ContentUtils fileExists:[resourceItemUrl path]]) {
                            [self presentOptionsMenu];
                        }
                    }
                    
                    return;
                }];
        } else if ([[resourceItem contentType] isEqualToString:CONTENT_TYPE_INDUSTRY_PRODUCT] || [ContentUtils fileExists:[resourceItemUrl path]]) {
            [self presentOptionsMenu];
        } else {
            // Make sure we don't have a sync going or ready to unpack.
            ContentSyncManager *manager = [ContentSyncManager sharedInstance];
            if (manager.isSyncInProgress == YES || manager.isSyncDoApplyChanges == YES || manager.hasSyncItemsToApply == YES) {
                [AlertUtils showModalAlertMessage:@"Current Sync must finish and be applied before downloading file." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
                return;
            }
            currentOperation = [self downloadDocumentThen:^(AFHTTPRequestOperation *operation, BOOL cancelled, NSError *error) {
                if (error == nil && cancelled == NO) {
                    if (resourceItemLabel) {
                        previewTextView.textColor = viewConfig.titleColor;
                        previewTextView.backgroundColor = viewConfig.overlayColor;
                    }
                    
                    if (resourcePreviewImagePath) {
                        previewImageView.image = [previewImageView.image imageByApplyingAlpha:1.0f];
                    } else if (resourceItemUrl) {
                        UIImage *previewImage = [ContentUtils itemContentPreviewImage:[resourceItemUrl path]];
                        if (previewImage) {
                            if (resourceItemLabel && !viewConfig.usesTitleOverlay) {
                                previewImage = [previewImage scaleAndCropImageForSize:CGSizeMake(self.bounds.size.width-LABEL_WIDTH, self.bounds.size.height)];
                            } else {
                                previewImage = [previewImage scaleAndCropImageForSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height)];
                            }
                        } else if ([docInteractionController.icons count] > 0) {
                            // Use the document interaction controller
                            NSInteger iconCount = [docInteractionController.icons count];
                            previewImage = [docInteractionController.icons objectAtIndex:iconCount - 1];
                        }
                        previewImageView.image = previewImage;
                    }
                    
                    [self presentOptionsMenu];
                    currentOperation = nil;
                } else {
                    if (cancelled) {
                        [AlertUtils showModalAlertMessage:@"Download Cancelled" withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
                    } else {
                        NSString *msg = [NSString stringWithFormat:@"Error: %@ downloading file.", error.localizedDescription];
                        [AlertUtils showModalAlertMessage:msg withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
                    }
                    [ContentUtils removeFile:[resourceItemUrl path]];
                    currentOperation = nil;
                }
            }];
        }
    }
}


- (void) presentOptionsMenu {
    if (![docInteractionController presentOptionsMenuFromRect:self.bounds inView:self animated:YES]) {
        if ([ContentUtils isCADFile:[resourceItemUrl path]]) {
            NSString *msg = [NSString stringWithFormat:@"You need a CAD Viewer to view this document.  %@ recommends vueCAD.",
                             [[SFAppConfig sharedInstance] getAppAlertTitle]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Install CAD Viewer" 
                                                            message:msg 
                                                           delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Get vueCAD", nil];
            [alert showWithCompletion:^(UIAlertView *anAlertView, NSInteger buttonIndex) {
                NSString *clickedButtonTitle = [anAlertView buttonTitleAtIndex:buttonIndex];
                if ([clickedButtonTitle isEqualToString:@"Get vueCAD"]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/apps/vueCAD"]];
                }
            }];
        }
    };
}

- (void) shareDocument:(UITapGestureRecognizer *)tapGesture {
    ContentMetaData *metadata = [[ContentSyncManager sharedInstance] getAppContentMetaData];
    NSString *contentPath = [resourceItem contentFilePath];
    
    if (contentPath) {
        ContentItem *item = [metadata getContentItemAtPath:contentPath];
        
        if (item) {
            MFMailComposeViewController *emailDialog = nil;
            // This lets us override the e-mail configuration at the product detail level (app specific)
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
                    [self.productNavigationController presentViewController:emailDialog animated:YES completion:NULL];
                });
            }
            
        }
    }
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate Methods
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.productNavigationController dismissViewControllerAnimated:YES completion:NULL];
    
    if (result == MFMailComposeResultSent) {
        
        [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"E-mail sent."] withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
        
        NSString *sharedDocument = [NSString stringWithFormat:@"/%@", [[resourceItem contentFilePath] lastPathComponent]];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:sharedDocument forKey:@"sharedDocument"];
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"contentDocumentShared" object:self userInfo:[NSDictionary dictionaryWithDictionary:dict]];
        
    } else if (result == MFMailComposeResultFailed) {
        
        [AlertUtils showModalAlertMessage:@"Sending of e-mail failed." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
        
    }
}

- (void) openDocument: (UITapGestureRecognizer *) tapGesture {
    if ([[resourceItem contentType] isEqualToString:CONTENT_TYPE_INDUSTRY_PRODUCT] || [ContentUtils fileExists:[resourceItemUrl path]]) {
        [self openDocument];
    } else {
        // Make sure we don't have a sync going or ready to unpack.
        ContentSyncManager *manager = [ContentSyncManager sharedInstance];
        if (manager.isSyncInProgress == YES || manager.isSyncDoApplyChanges == YES || manager.hasSyncItemsToApply == YES) {
            [AlertUtils showModalAlertMessage:@"Current Sync must finish and be applied before downloading file." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
            return;
        }
        // Download document and then try to open it.
        currentOperation = [self downloadDocumentThen:^(AFHTTPRequestOperation *operation, BOOL cancelled, NSError *error) {
            if (error == nil && cancelled == NO) {
                if (resourceItemLabel) {
                    previewTextView.textColor = viewConfig.titleColor;
                    previewTextView.backgroundColor = viewConfig.overlayColor;
                }
                
                if (resourcePreviewImagePath) {
                    previewImageView.image = [previewImageView.image imageByApplyingAlpha:1.0f];
                } else if (resourceItemUrl) {
                    UIImage *previewImage = [ContentUtils itemContentPreviewImage:[resourceItemUrl path]];
                    if (previewImage) {
                        if (resourceItemLabel && !viewConfig.usesTitleOverlay) {
                            previewImage = [previewImage scaleAndCropImageForSize:CGSizeMake(self.bounds.size.width-LABEL_WIDTH, self.bounds.size.height)];
                        } else {
                            previewImage = [previewImage scaleAndCropImageForSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height)];
                        }
                    } else if ([docInteractionController.icons count] > 0) {
                            // Use the document interaction controller
                            NSInteger iconCount = [docInteractionController.icons count];
                            previewImage = [docInteractionController.icons objectAtIndex:iconCount - 1];
                    }
                    previewImageView.image = previewImage;
                }
            
                [self openDocument];
                currentOperation = nil;
            } else {
                if (cancelled) {
                    [AlertUtils showModalAlertMessage:@"Download Cancelled" withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
                } else {
                    NSString *msg = [NSString stringWithFormat:@"Error: %@ downloading file.", error.localizedDescription];
                    [AlertUtils showModalAlertMessage:msg withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
                }
                [ContentUtils removeFile:[resourceItemUrl path]];
                currentOperation = nil;
            }
        }];
    }
}

- (void) openDocument {
    // Only allow the open document if the preview thumbnail is loaded
    if ([self allowOpenDocument]) {
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"contentResourceItemViewed" object:self userInfo:[NSDictionary dictionaryFromContentViewBehavior:resourceItem]];
        
        // This serves the purpose of highlighting the thumbnail before the details are expanded into view.
        // Could use a NSOperation as well, but might be overkill for this :-)
        [UIView animateWithDuration:0.1 animations:^ {
            highlightedView.hidden = NO;
            [self bringSubviewToFront:highlightedView];
        }completion:^(BOOL finished) {
            
            // I am either going to open an external link for the resource or the item url (on the file system)
            // Added to support Tolomatic Phase 2 requirements to link to an external URL
            if ([[resourceItem contentType] isEqualToString:CONTENT_TYPE_INDUSTRY_PRODUCT]) {
                id<ContentViewBehavior> product = [[[ContentLookup sharedInstance] impl] lookupProduct:[resourceItem contentId]];
                
                if (product) {
                    AbstractPortfolioViewController *pdvc = (AbstractPortfolioViewController *) [[SFAppConfig sharedInstance] getPortfolioDetailViewController:product];
                    [productNavigationController.navigationController pushViewController:pdvc animated:YES];
                } else {
                    [AlertUtils showModalAlertMessage:@"Requested product not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
                }

            } else if (resourceExternalLink) {
                CompanyWebViewController *webController = [[CompanyWebViewController alloc] initWithUrl:resourceExternalLink
                                                                                              andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
                
                webController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [productNavigationController presentViewController:webController animated:YES completion:NULL];
                
            } else if (resourceItemUrl) {
                BOOL allowPreviewForResource = [[SFAppConfig sharedInstance] allowPreviewForResourceItem:resourceItemUrl];
                
                if (allowPreviewForResource && [ContentUtils canOpenInApp:resourceItemUrl]) {
                    if ([ContentUtils isPDFFile:[resourceItemUrl path]]) {
                        [ContentUtils cleanFastPdfKitCache];
                        PdfViewController *pdfController = [[PdfViewController alloc] initWithUrl:resourceItemUrl];
                        pdfController.mailSetupDelegate = self.mailSetupDelegate;
                        if (resourceStartPage && [resourceStartPage unsignedIntegerValue] > 1) {
                            pdfController.startingPage = [resourceStartPage unsignedIntegerValue];
                        }
                        pdfController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                        [productNavigationController presentViewController:pdfController animated:YES completion:NULL];
                    } else if ([ContentUtils isMovieFile:[resourceItemUrl path]]) {
                        ResourceMoviePlayer *movieController = [[ResourceMoviePlayer alloc] initWithFrame:CGRectZero title:resourceItemLabel andUrl:resourceItemUrl];
                        movieController.overlayController = self.overlayController;
                        overlayController.overlayView = movieController;
                        [overlayController presentOverlayOnView:[self.productNavigationController view] startAtView:self fadeOutMode:ExpandStartViewFadeOutFull];
                        
                        [movieController readyPlayer];
                    } else {
                        ResourcePreviewController *preview = [[ResourcePreviewController alloc] initWithUrl:resourceItemUrl];
                        preview.mailSetupDelegate = self.mailSetupDelegate;
                        preview.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                        [productNavigationController presentViewController:preview animated:YES completion:NULL];
                    }
                } else {
                    if (allowPreviewForResource) {
                        [self presentOptionsMenu];
                    } else {
                        [AlertUtils showModalAlertMessage:@"Please press/hold the presentation icon to open with Keynote - where you can view and edit." withTitle:@"Open"];
                    }
                }
            } else {
                [AlertUtils showModalAlertMessage:@"No document found to open." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
            }
            
            highlightedView.hidden = YES;
        }];
    }
}

- (AFHTTPRequestOperation *) downloadDocumentThen:(void (^)(AFHTTPRequestOperation *, BOOL, NSError *))block {
    
    ContentMetaData *metadata = [[ContentSyncManager sharedInstance] getAppContentMetaData];
    NSString *contentPath = [resourceItem contentFilePath];
    
    if (contentPath) {
        ContentItem *item = [metadata getContentItemAtPath:contentPath];
        
        if (item) {
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            downloadProgressView = [[AlertProgressHUD alloc] initWithFrame:[UIScreen rectForScreenView:orientation]];
            [downloadProgressView setTitle:@"Download"];
            [downloadProgressView setMessage:[NSString stringWithFormat:@"Downloading %@", [item name]]];
            downloadCustomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [downloadProgressView defaultContentWidth], 95.0f)];
            [downloadCustomView setAutoresizingMask:UIViewAutoresizingNone];
            
            
            downloadProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [downloadProgressView defaultContentWidth], 21)];
            [downloadProgressLabel setBackgroundColor:[UIColor clearColor]];
            [downloadProgressLabel setTextColor:[downloadProgressView defaultTextColor]];
            [downloadProgressLabel setTextAlignment:NSTextAlignmentCenter];
            [downloadProgressLabel setText:[NSString stringWithFormat:@"%@ of %@",@"0",@"0"]];
            [downloadProgressLabel setAutoresizingMask:UIViewAutoresizingNone];
            [downloadCustomView addSubview:downloadProgressLabel];
            
            downloadProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
            downloadProgress.frame = CGRectMake(0.0f, 31.0f, [downloadProgressView defaultContentWidth], 10.0f);
            downloadProgress.progressTintColor = [UIColor colorWithRed:0.0f/255.0f green:51.0f/255.0f blue:171.0f/255.0f alpha:1.0f];
            [downloadProgress setAutoresizingMask:UIViewAutoresizingNone];
            [downloadProgress setProgress:0.0f];
            [downloadProgress setBackgroundColor:[UIColor clearColor]];
            [downloadCustomView addSubview:downloadProgress];
            
            downloadCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 51.0f, [downloadProgressView defaultContentWidth], 43.0f)];
            downloadCancelButton.titleLabel.textColor = [downloadProgressView defaultTextColor];
            downloadCancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            [downloadCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
                // For iOS 6.1 or earlier
                UIImage *buttonImage = [UIImage imageResource:@"AlertProgressCancelButtonBackground.png"];
                UIImage *stretchImage = [buttonImage stretchableImageWithLeftCapWidth:buttonImage.size.width / 2.0f topCapHeight:buttonImage.size.height / 2.0f];
                [downloadCancelButton setBackgroundImage:stretchImage forState:UIControlStateNormal];
                UIImage *highlightImage = [UIImage imageResource:@"AlertProgressButtonBackground_Hightlighted.png"];
                UIImage *hightlightStretchImage = [highlightImage stretchableImageWithLeftCapWidth:highlightImage.size.width / 2.0f topCapHeight:highlightImage.size.height / 2.0f];
                [downloadCancelButton setBackgroundImage:hightlightStretchImage forState:UIControlStateHighlighted];
            } else {
                downloadCancelButton.backgroundColor = [UIColor redColor];
            }
            
            [downloadCancelButton addTarget:self action:@selector(cancelDownload:) forControlEvents:UIControlEventTouchUpInside];
            [downloadCustomView addSubview:downloadCancelButton];
            
            downloadProgressView.customView = downloadCustomView;

            [[UIApplication sharedApplication] addWindowOverlay:downloadProgressView];
            
            // Make sure parent directory exists for file we are downloading
            [ContentUtils createDirForFile:[resourceItemUrl path]];
            
            NSURL *downloadUrl = [NSURL URLWithString:[item.downloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSURLRequest *request = [NSURLRequest requestWithURL:downloadUrl];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[resourceItemUrl path] append:NO];

            [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                long long expectedBytes = (totalBytesExpectedToRead == -1) ? item.fileSize : totalBytesExpectedToRead;
                float progress = (float)((float)totalBytesRead / (float)expectedBytes);
                //NSLog(@"bytesRead: %lu totalBytesRead: %lld totalBytesExpectedToRead %lld expectedBytes: %lld progress: %f", (unsigned long)bytesRead, totalBytesRead, totalBytesExpectedToRead, expectedBytes, progress);
                [downloadProgress setProgress:progress];
                [downloadProgressLabel setText:[NSString stringWithFormat:@"%@ of %@",[NSString formatAsFileSize:totalBytesRead], [NSString formatAsFileSize:expectedBytes]]];
            }];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                // worked
                [self dismissDownloadProgress];
                if (block) {
                    block(operation, NO, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                // didn't work
                [self dismissDownloadProgress];
                if (block) {
                    block(operation, [operation isCancelled], error);
                }
            }];
            
            [operation start];
            return operation;
        }
    }
    return nil;
}

- (void)cancelDownload:(UIButton *)sender {
    if (currentOperation) {
        [currentOperation cancel];
    }
}

- (void) dismissDownloadProgress {
    if (downloadCancelButton) {
        [downloadCancelButton removeFromSuperview];
        downloadCancelButton = nil;
    }
    if (downloadProgress) {
        [downloadProgress removeFromSuperview];
        downloadProgress = nil;
    }
    if (downloadProgressLabel) {
        [downloadProgressLabel removeFromSuperview];
        downloadProgressLabel = nil;
    }
    if (downloadCustomView) {
        [downloadCustomView removeFromSuperview];
        downloadCustomView = nil;
    }
    if (downloadProgressView) {
        [downloadProgressView removeFromSuperview];
        downloadProgressView = nil;
    }
}

- (BOOL) allowOpenDocument {
    if (previewImageView == nil || previewImageView.image == nil) {
        return NO;
    }
    
    if (resourceImageStatusDelegate && [resourceImageStatusDelegate respondsToSelector:@selector(allImagesLoaded:)]) {
        return [resourceImageStatusDelegate allImagesLoaded:self];
    }
    
    return YES;

}

@end

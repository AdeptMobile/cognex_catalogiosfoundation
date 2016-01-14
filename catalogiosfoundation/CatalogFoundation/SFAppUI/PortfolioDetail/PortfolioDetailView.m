//
//  ProductDetailView.m
//  ToloApp
//
//  Created by Torey Lomenda on 6/3/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "PortfolioDetailView.h"

#import "HorizontalLayout.h"
#import "VerticalLayout.h"
#import "FillLayout.h"

#import "SketchPadController.h"
#import "ResourcePreviewController.h"
#import "CompanyWebViewController.h"

#import "ContentUtils.h"

#import "SFAppConfig.h"
#import "AlertUtils.h"
#import "ContentLookup.h"

#import "ContentSyncManager.h"

#import "OPIFoundation.h"

#import "UIView+ViewLayout.h"
#import "UIView+ImageRender.h"
#import "UIColor+Chooser.h"
#import "UIImage+Resize.h"
#import "UIImage+Extensions.h"
#import "NSFileManager+Utilities.h"
#import "NSBundle+CatalogFoundationResource.h"
#import "UIScreen+Helpers.h"
#import "NSString+Extensions.h"

#import "ResourceButtonMenuConfig.h"
#import "ResourceButtonConfig.h"

#import "DetailFavoritesViewController.h"
#import "BasicPortfolioDetailViewController.h"
#import "DetailSearchViewController.h"
#import "HierarchyNavigationViewController.h"
#import "HierarchyNavigationViewControllerDelegate.h"
#import "GalleryDetailViewController.h"

#define RESOURCE_MENU_WIDTH 210.0f
#define RESOURCE_MENU_HEIGHT 360.0f

#define PRODUCT_FEATURE_WIDTH 512.0f
#define PRODUCT_FEATURE_HEIGHT_LANDSCAPE 410.0f
#define PRODUCT_FEATURE_HEIGHT_PORTRAIT 664.0f

#define PRODUCT_INFO_WIDTH 206.0f
#define PRODUCT_INFO_HEIGHT 178.0f

#define TOOLBAR_HEIGHT 44.0f

#define RESOURCE_PREVIEW_HEIGHT 220.0f
#define RESOURCE_PREVIEW_WIDTH_LANDSCAPE 1004.0f
#define RESOURCE_PREVIEW_WIDTH_PORTRAIT 748.0f

static NSString * const EMAIL_TEMPLATE = @""
"<p>"
"I would like to request the %@ Demo Case."
"<p>"
"<b>REQUESTOR: Please include your contact and shipping information below in this email. Thank you.<b>"
"</p>"
"</p>";

@interface PortfolioDetailView() 

- (void) setupProductPhotoView;
- (void) setupResourceMenuView;
- (void) setupResourcePreviewView;

- (void) dismissOnTap:(UITapGestureRecognizer *) tapGesture;
- (void) leftLogoTapped:(UITapGestureRecognizer *) tapGesture;
- (void) openPreview;
- (void) dismissPopovers;

- (void) presentWebView:(NSURL *)url;

- (void) backToMain;

- (void) layoutResourcePreviewView;

@end

@implementation PortfolioDetailView

@synthesize contentProduct;
@synthesize productNavigationController;
@synthesize overlayController;
@synthesize detailFavoritesPopover;
@synthesize detailSearchPopover;
@synthesize hierarchyPopover;
@synthesize setupPopover;
@synthesize contentToolbar;

@synthesize productPhotoView;

@synthesize resourcePreviewView;
@synthesize resourceMenuView;

@synthesize logoView;

- (id)initWithFrame:(CGRect)frame productNavController: (UINavigationController *) productNavController andContentProduct:(id<ContentViewBehavior>)aContentProduct {
    self = [super initWithFrame:frame];
    if (self) {
        float topOffset = [self topOffsetForStatusBar];
        
        // Initialize the content path
        currentResourceMenuSelection = -1;
        
        previewScrollOrigin = CGPointZero;
        
        contentProduct = aContentProduct;
        productNavigationController = productNavController;
        
        // Not required.  This is set in the controller
        //self.backgroundColor = [[ContentConfig sharedInstance] lookupColorForProperty:@"com.opi.content.productDetail.bgColor"];
        
        // init logo
        NSString *logoLeft = [[SFAppConfig sharedInstance] getBasicPortfolioDetailViewConfig].leftLogoNamed;
        
        if ([NSString isNotEmpty:logoLeft]) {
            UIImage *leftLogoImage = [UIImage imageResource:logoLeft];
            
            logoView = [[UIImageView alloc] initWithImage:leftLogoImage];
            logoView.frame = CGRectMake(10, 10 + topOffset, leftLogoImage.size.width, leftLogoImage.size.height);
            
            logoView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(leftLogoTapped:)];
            tap.numberOfTapsRequired = 1;
            [logoView addGestureRecognizer: tap];
        } else {
            logoView = [[UIImageView alloc] initWithImage:[UIImage imageResource:@"logo.png"]];
            logoView.userInteractionEnabled = YES;
        }
        
        [self addSubview:logoView];
            
        // Add the toolbar
        contentToolbar = [[ContentInfoToolbarView alloc] initWithFrame:CGRectZero
                                                             andConfig:[[SFAppConfig sharedInstance] getContentInfoToolbarConfig]];
        contentToolbar.delegate = self;
        [self addSubview:contentToolbar];
        
        // Setup the subviews
        [self setupResourceMenuView];
        [self setupProductPhotoView];
        [self setupResourcePreviewView];
        
        DetailFavoritesViewController *detailFavoritesController = [[DetailFavoritesViewController alloc] init];
        detailFavoritesController.delegate = self;
        self.detailFavoritesPopover = [[UIPopoverController alloc] initWithContentViewController:detailFavoritesController];
        
        DetailSearchViewController *detailSearchController = [[DetailSearchViewController alloc] init];
        detailSearchController.delegate = self;
        self.detailSearchPopover = [[UIPopoverController alloc] initWithContentViewController:detailSearchController];
        
        HierarchyNavigationViewController *hierarchyController = [[HierarchyNavigationViewController alloc] init];
         hierarchyController.rootLevelVCAtTop = NO;
        self.hierarchyPopover = [[UIPopoverController alloc] initWithContentViewController:hierarchyController];
        
    }
    return self;
}


#pragma mark -
#pragma mark Public Methods
- (void) hideToolbarPopover {
    [contentToolbar dismissPopover];
}

- (void) updateBadgeText: (NSString *) newBadgeText {
    [contentToolbar updateBadgeText:newBadgeText];
}

#pragma mark -
#pragma mark ContentInfoToolbarDelegate Methods
- (void) toolbarButtonTapped:(id)toolbarButton {
    switch ([toolbarButton tag]) {
        case 6: 
        {
            [self dismissPopovers];
            [self backToMain];
            break;
        }
        case 5:
        {
            if (overlayController) {
                [overlayController dismissOverlay];
            }
            break;
        }
        case 4:
        {
            CompanyWebViewController *webViewController = [[CompanyWebViewController alloc] initWithUrl:[NSURL URLWithString:[[SFAppConfig sharedInstance] getContentInfoToolbarConfig].webBtnLink]
                                                                                              andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
            webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [productNavigationController presentViewController:webViewController animated:YES completion:NULL];
            break;
        }
        case 3:
        {            
            [self dismissPopovers];
            UIButton *button = (UIButton *)toolbarButton;
            [detailFavoritesPopover presentPopoverFromRect:button.frame inView:contentToolbar permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            break;
        }
        case 2:
        {
            [self dismissPopovers];
            UIButton *button = (UIButton *)toolbarButton;
            [detailSearchPopover presentPopoverFromRect:button.frame inView:contentToolbar permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            break;
        }
        case 1:
        {
            UIImage *previewImage = [[self imageFromView] resizedImage:CGSizeMake(self.bounds.size.width - 20*2,
                                                                                self.bounds.size.height-TOOLBAR_HEIGHT-20*2) interpolationQuality:kCGInterpolationHigh];
            SketchPadController *sketchPadController = [[SketchPadController alloc] 
                                                        initWithImage:previewImage 
                                                        tintColor:[[SFAppConfig sharedInstance] getSketchViewTintColor]
                                                        titleFont:nil
                                                        brand:[[SFAppConfig sharedInstance] getBrandTitle]
                                                        andBgColor:[[SFAppConfig sharedInstance] getSketchViewBgColor]];
            
            [productNavigationController presentViewController:sketchPadController animated:YES completion:NULL];
        }
        default:
        {
            break;
        }
    }
}

- (void) longPressOnToolbarButton:(id)toolbarButton {
    // View controller will pick up the button press
}

- (void) selectedSyncAction:(SyncActionType)syncAction {
    if (syncAction == SYNC_CONTENT_NOW) {
        [[ContentSyncManager sharedInstance] performSync];
    } else if (syncAction == SYNC_APPLY_CHANGES) {
        [ContentSyncManager sharedInstance].syncDoApplyChanges = YES;
        [self backToMain];
    }
}

#pragma mark -
#pragma mark ResourceButtonMenuDelegate Protocol
- (void) menuItemSelected:(id) menuButton resourcesAvailableList:(NSArray *)resourcePathList {
    UIButton *btn = (UIButton *) menuButton;
    
    if (resourcePreviewView && currentResourceMenuSelection != btn.tag) {
        if (resourcePreviewView.loadPreviewsQueue.operationCount > 0) {
            [[resourcePreviewView loadPreviewsQueue] cancelAllOperations];
        }
        // Determine where to start the preview scroll view
        if (currentResourceMenuSelection != -1) {
            resourcePreviewView.docPreviewStripView.startScrollPosition = CGPointZero;
        } else {
            resourcePreviewView.docPreviewStripView.startScrollPosition = previewScrollOrigin;
        }
        
        [resourcePreviewView loadPreviews:btn.titleLabel.text withResources:resourcePathList];
        
        currentResourceMenuSelection = btn.tag;
    }
}

- (BOOL) allowMenuItemSelection:(NSInteger)menuButtonIndex {
    return [resourcePreviewView allPreviewsLoaded];
}

#pragma mark - DetailFavoritesViewControllerDelegate methods
- (id<ContentViewBehavior>) detailForFavorites {
    return contentProduct;
}

- (void)favoritesViewController:(DetailFavoritesViewController *)pfvc didRequestProduct:(NSString *)productId {
    [self dismissPopovers];
    id<ContentViewBehavior> product = [[[ContentLookup sharedInstance] impl] lookupProduct:productId];
    if (product) {
        AbstractPortfolioViewController *pdvc = [[SFAppConfig sharedInstance] getPortfolioDetailViewController:product];
        //pdvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        //[productNavigationController presentModalViewController:pdvc animated:YES];
        [productNavigationController.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested product not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
}

- (void)favoritesViewController:(DetailFavoritesViewController *)pfvc didRequestIndustry:(NSString *)industryId {
    [self dismissPopovers];
    id<ContentViewBehavior> industry = [[[ContentLookup sharedInstance] impl] lookupIndustry:industryId];
    if (industry) {
        AbstractPortfolioViewController *pdvc = [[SFAppConfig sharedInstance] getPortfolioDetailViewController:industry];
        [productNavigationController.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested industry not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
}

- (void)favoritesViewController:(DetailFavoritesViewController *)pfvc didRequestGallery:(NSString *)galleryId {
    [self dismissPopovers];
    
    id<ContentViewBehavior> gallery = [[[ContentLookup sharedInstance] impl] lookupGallery:galleryId];
    
    if (gallery) {
        GalleryDetailViewController *pdvc = [[GalleryDetailViewController alloc] initWithContentGallery:gallery];
        [productNavigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested gallery not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
    
}

- (BOOL) canAddFavorite {
    // Products can be added as favorites
    return YES;
}

#pragma mark - DetailSearchViewControllerDelegate methods
- (void) searchViewController:(DetailSearchViewController *)psvc didRequestProduct:(NSString *)productId {
    [self dismissPopovers];
    id<ContentViewBehavior> product = [[[ContentLookup sharedInstance] impl] lookupProduct:productId];
    if (product) {
        AbstractPortfolioViewController *pdvc = [[SFAppConfig sharedInstance] getPortfolioDetailViewController:product];
        
        //pdvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        //[productNavigationController presentModalViewController:pdvc animated:YES];
        [productNavigationController.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested product not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
}

- (void) searchViewController:(DetailSearchViewController *)psvc didRequestIndustry:(NSString *)industryId {
    [self dismissPopovers];
    id<ContentViewBehavior> industry = [[[ContentLookup sharedInstance] impl] lookupProduct:industryId];
    if (industry) {
        AbstractPortfolioViewController *pdvc = [[SFAppConfig sharedInstance] getPortfolioDetailViewController:industry];
        [productNavigationController.navigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested industry not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
}

- (void) searchViewController:(DetailSearchViewController *)psvc didRequestGallery:(NSString *)galleryId {
    [self dismissPopovers];
    
    id<ContentViewBehavior> gallery = [[[ContentLookup sharedInstance] impl] lookupGallery:galleryId];
    
    if (gallery) {
        GalleryDetailViewController *pdvc = [[GalleryDetailViewController alloc] initWithContentGallery:gallery];
        [productNavigationController pushViewController:pdvc animated:YES];
    } else {
        [AlertUtils showModalAlertMessage:@"Requested gallery not found.  It may have been deleted from the catalog." withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
}

#pragma mark - MailSetupDelegate Methods
- (MFMailComposeViewController *)setupEmailForContentItem:(ContentItem *)contentItem {
    MFMailComposeViewController *emailDialog = nil;
    if ([contentProduct hasResources]) {
        for (id<ContentViewBehavior>resourceGroup in [contentProduct contentResources]) {
            if ([[resourceGroup contentTitle] isEqualToString:@"Demo Cases"]) {
                if ([resourceGroup hasResourceItems]) {
                    for (id<ContentViewBehavior>resourceItem in [resourceGroup contentResourceItems]) {
                        if ([[resourceItem contentFilePath] hasSuffix:contentItem.path]) {
                            emailDialog = [[MFMailComposeViewController alloc] init];
                            // I do not think I need this here.  Do we configure recepients ??
                            // [emailDialog setToRecipients:[NSArray arrayWithObject:[NSString stringWithString:@"demorequest@sick.com"]]];
                            [emailDialog setSubject:[NSString stringWithFormat:@"Demo Case Request %@", contentItem.name]];
                            NSString *emailBody = [NSString 
                                                   stringWithFormat:EMAIL_TEMPLATE,
                                                   [resourceItem contentTitle]];
                            [emailDialog setMessageBody:emailBody isHTML:YES];
                        }
                    }
                }
            }
        }
    }
    return emailDialog;
}

#pragma mark -
#pragma mark layout methods
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGSize logoSize = self.logoView.frame.size;
    
    float topOffset = [self topOffsetForStatusBar];
    
    // Logo stays in the top left corner and is set in init
    
    if (!CGRectIsEmpty(bounds)) {
        // ResourceMenuView stays the same as well
        if (resourceMenuView) {
            CGRect menuFrame = CGRectMake(10.0f, 130.0f + topOffset, RESOURCE_MENU_WIDTH, RESOURCE_MENU_HEIGHT);
            resourceMenuView.frame = menuFrame;
        }
        
        // Toolbar is calculated the same in both orientations
        float toolbarLeftOffset = 10.0f;
        float toolbarTopOffset = 7 + topOffset;
        CGRect toolbarFrame = CGRectMake(logoSize.width + toolbarLeftOffset, toolbarTopOffset,
                                         bounds.size.width - (logoSize.width + toolbarLeftOffset),
                                         TOOLBAR_HEIGHT);
        contentToolbar.frame = toolbarFrame;
        
        CGRect featuresFrame;
        CGRect infoFrame;
        CGRect resourcePreviewFrame;
        
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            infoFrame = CGRectMake(10.0f, 586.0f + topOffset, PRODUCT_INFO_WIDTH, PRODUCT_INFO_HEIGHT);
            featuresFrame = CGRectMake(246.0f, 100.0f + topOffset, PRODUCT_FEATURE_WIDTH, PRODUCT_FEATURE_HEIGHT_PORTRAIT);
            resourcePreviewFrame = CGRectMake(10.0f, 774.0f + topOffset, RESOURCE_PREVIEW_WIDTH_PORTRAIT, RESOURCE_PREVIEW_HEIGHT);
        } else {
            infoFrame = CGRectMake(258.0f, 130.0f + topOffset, PRODUCT_INFO_WIDTH, PRODUCT_INFO_HEIGHT);
            featuresFrame = CGRectMake(502.0f, 100.0f + topOffset, PRODUCT_FEATURE_WIDTH, PRODUCT_FEATURE_HEIGHT_LANDSCAPE);
            resourcePreviewFrame = CGRectMake(10.0f, 520.0f + topOffset, RESOURCE_PREVIEW_WIDTH_LANDSCAPE, RESOURCE_PREVIEW_HEIGHT);
        }

        productPhotoView.frame = infoFrame;
        productFeaturesView.frame = featuresFrame;
        
        if (resourcePreviewView) {
            resourcePreviewView.frame = resourcePreviewFrame;
            [resourcePreviewView layoutSubviews];
        }
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        BasicPortfolioDetailViewConfig *config = [[SFAppConfig sharedInstance] getBasicPortfolioDetailViewConfig];
        
        if (config.mainPortBgColor && UIInterfaceOrientationIsPortrait(orientation)) {
            self.backgroundColor = config.mainPortBgColor;
        } else if (config.mainLandBgColor && UIInterfaceOrientationIsLandscape(orientation)) {
            self.backgroundColor = config.mainLandBgColor;
        } else {
            self.backgroundColor = config.mainBgColor;
        }
        
        // Select the first enabled menu item
        [resourceMenuView defaultMenuSelection];
    }
}

#pragma mark -
#pragma mark Accessor Methods
//=========================================================== 
// - setProductNavigationController:
//=========================================================== 
- (void)setProductNavigationController:(UINavigationController *)aProductNavigationController {
    if (productNavigationController != aProductNavigationController) {
        // This is an assign (no retain required)
        productNavigationController = aProductNavigationController;
        
        if (resourcePreviewView) {
            resourcePreviewView.productNavigationController = aProductNavigationController;
        }
    }
}

#pragma mark - Public Methods
- (void) stopLoadingPreviews {
    // Stop loading all previews.
    if (resourcePreviewView && resourcePreviewView.loadPreviewsQueue) {
        [[resourcePreviewView loadPreviewsQueue] cancelAllOperations];
    }
}

- (void) addViewsOnAppear {
    if (productPhotoView == nil) {
        [self setupProductPhotoView];
    }
    if (resourcePreviewView == nil) {
        NSInteger menuTag = currentResourceMenuSelection;
        
        [self setupResourcePreviewView];
        
        // Force Layout of the preview view
        [self layoutResourcePreviewView];
        
        currentResourceMenuSelection = -1;
        [resourceMenuView menuSelection:menuTag];
    }
    
    [self setNeedsLayout];
}

- (void) removeViewsOnDisappear {
    // Track the current scroll position of the resource preview view
    previewScrollOrigin = resourcePreviewView.docPreviewStripView.containingScrollView.contentOffset;
    
    [resourcePreviewView removeFromSuperview];
    [productPhotoView removeFromSuperview];
    
    self.resourcePreviewView = nil;
    self.productPhotoView = nil;
}

#pragma mark - Private Layout Methods
- (float) topOffsetForStatusBar {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        return 20.0f;
    }
    
    return 0.0;
}

#pragma mark -
#pragma mark Private Methods
- (void) setupResourceMenuView {
    // Build the menu configuration
    ResourceButtonMenuConfig *menuConfig = [[SFAppConfig sharedInstance] getPortfolioResourceButtonMenuConfig];
    
    // Find out if we have an resource groups that need to be excluded from the menu.
    NSArray *excludedResources = [[SFAppConfig sharedInstance] getExcludedResources];
    
    // Build the button configs
    if ([contentProduct hasResources]) {
        for (id<ContentViewBehavior> resourceGroup in [contentProduct contentResources]) {
            BOOL display = YES;
            if (excludedResources && [excludedResources count] > 0) {
                NSString *resourceGroupTitle = [resourceGroup contentTitle];
                for (NSString *ex in excludedResources) {
                    if ([ex isEqualToString:resourceGroupTitle]) {
                        display = NO;
                        break;
                    }
                }
            }
            // If the resource group doesn't have any items, don't show it.
            if ([resourceGroup hasResourceItems] == NO) {
                display = NO;
            }
            if (display) {
                [menuConfig.buttonConfigList addObject:[[SFAppConfig sharedInstance] getPortfolioResourceButtonConfig:resourceGroup]];
            }
        }
    }
    
    resourceMenuView = [[ResourceButtonMenuView alloc] initWithFrame:CGRectZero andConfig:menuConfig];
    resourceMenuView.delegate = self;
    
    [self addSubview:resourceMenuView];
}
- (void) setupProductPhotoView {

    self.productPhotoView = [[ProductPhotoView alloc] initWithFrame:CGRectZero contentProduct:contentProduct];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(openPreview)];
    tap2.numberOfTapsRequired = 1;
    [productPhotoView.productImage addGestureRecognizer: tap2];

    [self addSubview:productPhotoView];
    
    if (productFeaturesView == nil) {
        productFeaturesView = [[PortfolioFeaturesView alloc] initWithFrame:CGRectZero andContentProduct:contentProduct];
        [self addSubview:productFeaturesView];
    }
    
}
- (void) setupResourcePreviewView {
    self.resourcePreviewView = [[ResourceListPreviewView alloc] initWithFrame:CGRectZero productNavController:self.productNavigationController mailSetupDelegate:self andContentProduct:contentProduct];
    [self addSubview:resourcePreviewView];
}

- (void) resizeBadge:(CGSize)screenSize {
    [contentToolbar resizeBadge];
}

-(void) dismissOnTap:(UITapGestureRecognizer *)tapGesture {
    if (overlayController) {
        [overlayController dismissOverlay];
    }
}

- (void) openPreview {
    // This serves the purpose of highlighting the thumbnail before the details are expanded into view.
    // Could use a NSOperation as well, but might be overkill for this :-)
    NSString *resourceItemPath = nil;
    if ([contentProduct hasImages]) {
        resourceItemPath = (NSString *)[[contentProduct contentImages] objectAtIndex:0];
    } else {
        resourceItemPath = [NSBundle contentFoundationResourceBundlePathForResource:@"not-found.png"];
    }
    
    if (resourceItemPath) {
        ResourcePreviewController *preview = [[ResourcePreviewController alloc] initWithUrl:[NSURL fileURLWithPath:resourceItemPath]];

        preview.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [productNavigationController presentViewController:preview animated:YES completion:NULL];
    }
}

- (void) leftLogoTapped:(UITapGestureRecognizer *)tapGesture {
    NSString *urlString = [[SFAppConfig sharedInstance] getBasicCategoryViewConfig].leftLogoLink;
    
    if ([NSString isNotEmpty:urlString]) {
        [self presentWebView:[NSURL URLWithString:urlString]];
    }
}

- (void) dismissPopovers {
    if (detailFavoritesPopover && detailFavoritesPopover.isPopoverVisible) {
        [detailFavoritesPopover dismissPopoverAnimated:NO];
    }
    if (detailSearchPopover && detailSearchPopover.isPopoverVisible) {
        [detailSearchPopover dismissPopoverAnimated:NO];
    }
    if (hierarchyPopover && hierarchyPopover.isPopoverVisible) {
        [hierarchyPopover dismissPopoverAnimated:NO];
    }
}

- (void) backToMain {
    if (productNavigationController.navigationController) {
        CATransition* transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction
                                     functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionReveal;
        [productNavigationController.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [productNavigationController.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (void) presentWebView:(NSURL *)url {
    CompanyWebViewController *webViewController = [[CompanyWebViewController alloc] initWithUrl:url andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
    
    webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    // Get current controller
    [productNavigationController presentViewController:webViewController animated:YES completion:NULL];
}

- (void) layoutResourcePreviewView {
    if (resourcePreviewView) {
        CGRect previewFrame;
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            previewFrame = CGRectMake(10.0f, 774.0f, RESOURCE_PREVIEW_WIDTH_PORTRAIT, RESOURCE_PREVIEW_HEIGHT);
        } else {
            previewFrame = CGRectMake(10.0f, 520.0f, RESOURCE_PREVIEW_WIDTH_LANDSCAPE, RESOURCE_PREVIEW_HEIGHT);
        }
        
        resourcePreviewView.frame = previewFrame;
        [resourcePreviewView layoutSubviews];
    }
}

@end

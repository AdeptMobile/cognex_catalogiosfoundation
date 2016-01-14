//
//  DSDetailView.m
//  Torit
//
//  Created by Nate Flink on 8/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TabbedDetailView.h"

#import "FXLabel.h"

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

#import "UIView+ViewLayout.h"
#import "UIView+ImageRender.h"
#import "UIColor+Chooser.h"
#import "UIImage+Resize.h"
#import "UIImage+Extensions.h"
#import "NSFileManager+Utilities.h"
#import "NSBundle+CatalogFoundationResource.h"
#import "UIImage+CatalogFoundationResourceImage.h"
#import "UIScreen+Helpers.h"

#import "ResourceTabConfig.h"

#import "DetailFavoritesViewController.h"
#import "DetailSearchViewController.h"
#import "HierarchyNavigationViewController.h"
#import "HierarchyNavigationViewControllerDelegate.h"
#import "SFAppSetupViewController.h"

#import "BasicCategoryViewController.h"


#define TOOLBAR_WIDTH 13 * 44.0f
#define TOOLBAR_HEIGHT 44.0f

@interface TabbedDetailView() {
    UIButton * onlineCatalogButton;
    UIButton * donaldsonInnovationButton;
    CGPoint previewScrollOrigin;
    CGFloat yOffset;
    TabbedPortfolioDetailViewConfig *config;
}

- (void) setupProductInfoView;
- (void) setupResourceMenuView;
- (void) setupResourcePreviewView;

- (void) dismissOnTap:(UITapGestureRecognizer *) tapGesture;
- (void) logoTapped:(UITapGestureRecognizer *) tapGesture;
- (void) openPreview;
- (void) dismissPopovers;

- (void) backToMain;

@end

@implementation TabbedDetailView


@synthesize contentProduct;
@synthesize productNavigationController;
@synthesize overlayController;
@synthesize detailFavoritesPopover;
@synthesize detailSearchPopover;
@synthesize hierarchyPopover;
@synthesize setupPopover;
@synthesize contentToolbar;
@synthesize resourceMenuView;
@synthesize resourcePreviewView;

- (id)initWithFrame:(CGRect)frame productNavController: (UINavigationController *) productNavController andContentProduct:(id<ContentViewBehavior>)aContentProduct {
    self = [super initWithFrame:frame];
    if (self) {
        
        // This view is landscape only.
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        CGRect screen = [UIScreen rectForScreenView:orientation];
        
        yOffset = 0.0f;
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            // For iOS 7 or later.  This moves things out from under the status bar.
            yOffset = 20.0f;
        }
        
        config = [[SFAppConfig sharedInstance] getTabbedPortfolioDetailViewConfig];
        UIImageView *backgroundImageView;
        if (config.mainBgImageNamed) {
            backgroundImageView = [[UIImageView alloc] initWithFrame:screen];
            backgroundImageView.image = [UIImage contentFoundationResourceImageNamed:config.mainBgImageNamed];
        } else {
            self.backgroundColor = config.mainBgColor;
        }
        
        // init logo
        NSString *logoLeft = config.leftLogoNamed;
        UIImageView *logoView;
        
        if (logoLeft) {
            logoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8 + yOffset, 130, 43)];
            logoView.userInteractionEnabled = YES;
            logoView.image = [UIImage contentFoundationResourceImageNamed:config.leftLogoNamed];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(homeButtonPressed:)];
            tapGesture.numberOfTapsRequired = 1;
            tapGesture.numberOfTouchesRequired = 1;
            [logoView addGestureRecognizer:tapGesture];
        } else {
            logoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8 + yOffset, 146, 63)];
            logoView.userInteractionEnabled = YES;
            logoView.image = [UIImage contentFoundationResourceImageNamed:@"logo.png"];
        }
        
        if (config.mainBgImageNamed) {
            [self addSubview:backgroundImageView];
        }
        [self addSubview:logoView];
        
        FXLabel *productLabel = [[FXLabel alloc] initWithFrame:CGRectMake(30, 72 + yOffset, 964, config.mainTitleFontSize)];
        productLabel.font = [UIFont fontWithName:config.mainTitleFont size:config.mainTitleFontSize];
        productLabel.text = [[aContentProduct contentTitle] uppercaseString];
        productLabel.backgroundColor = [UIColor clearColor];
        productLabel.textColor = config.mainTitleFontColor;
        [self addSubview:productLabel];
        
        FXLabel *infoText = [[FXLabel alloc] initWithFrame:CGRectMake(30, 128 + yOffset, 388, 90)];
        infoText.text = [aContentProduct contentInfoText];
        [infoText setLineBreakMode:NSLineBreakByWordWrapping];
        [infoText setNumberOfLines:0];
        [infoText setBackgroundColor:[UIColor clearColor]];
        [infoText setFont:[UIFont fontWithName:config.mainInfoTextFont size:config.mainInfoTextFontSize]];
        [infoText setTextColor:config.mainInfoTextFontColor];
        [infoText setTextAlignment:config.mainInfoTextHorizontalAlignment];
        [infoText setContentMode:config.mainInfoTextVerticalAlignment];
        [self addSubview:infoText];
        
        
        if (config.mainBottomBarImageNamed) {
            UIImage *bottomImage = [UIImage contentFoundationResourceImageNamed:config.mainBottomBarImageNamed];
            UIImageView *bottomBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 720 + yOffset, 1024, 28)];
            bottomBarImageView.image = bottomImage;
            
            [self addSubview:bottomBarImageView];
        }

        // Initialize the content path
        currentResourceMenuSelection = -1;
        
        self.contentProduct = aContentProduct;
        productNavigationController = productNavController;
        
        // Add the toolbar
        contentToolbar = [[ContentInfoToolbarView alloc] initWithFrame:CGRectMake(180, 8 + yOffset, 832, 44)];
        [self addSubview:contentToolbar];

        if (config.externalApplicationButtonEnabled == YES) {
            UIButton * extAppButton = [[UIButton alloc] initWithFrame:CGRectMake(844, 550 + yOffset, 150, 38)];
            extAppButton.titleLabel.numberOfLines = 2;
            extAppButton.titleLabel.font = [UIFont fontWithName:config.externalApplicationButtonFont size:14.0f];
            extAppButton.titleLabel.textColor = config.externalApplicationButtonTextColor;
            extAppButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            extAppButton.titleLabel.shadowColor = config.externalApplicationButtonShadowColor;
            extAppButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
            [extAppButton setBackgroundImage:[UIImage imageResource:config.externalApplicationButtonImageNamed] forState:UIControlStateNormal];
            [extAppButton setTitle:[config.externalApplicationButtonTitle uppercaseString] forState:UIControlStateNormal];
            [extAppButton addTarget:self action: @selector(externalAppButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:extAppButton];
        }
        
        //Add the "Online Catalog" button (if possible)
        if ([contentProduct hasResources]) {
            [[contentProduct contentResources] enumerateObjectsUsingBlock:^(id<ContentViewBehavior> obj, NSUInteger idx, BOOL * stop) {
                NSLog(@"resource items: %@", [obj contentResourceItems]);
                NSLog(@"resource contentType: %@, title %@",[obj contentType],[obj contentTitle]);
                
                if ([obj contentTitle] && [[obj contentTitle] caseInsensitiveCompare:config.onlineCatalogButtonResourceGroup] == NSOrderedSame) {
                    NSLog(@"Online Catalog");
                    *stop = YES;
                    if ([[obj contentResourceItems] count]<1) {
                        NSLog(@"there are no resource items");//try another one, bro
                        return; //don't crash, just return
                    }
                    
                    id<ContentViewBehavior> itm = [[obj contentResourceItems] objectAtIndex:0];
                    NSString * pth = [itm contentFilePath];
                    
                    if ([pth length] < 8) {//has to be at least Content/CatalogApp
                        NSLog(@"malformed url string in a resource item");
                        return;
                    }
                    NSString * urlStr = [NSString stringWithContentsOfFile:pth encoding:NSUTF8StringEncoding  error:nil];
                    NSLog(@"online catalog Resource Item %@", urlStr);
                    if ([urlStr length] < 8) {//has to be at least http:// ..
                        NSLog(@"malformed url string in a resource item");
                        return;
                    }
                    onlineCatalogResourceUrl = urlStr;
                    //ok everything checks out, go ahead and add a button to launch a web browser
                    
                    onlineCatalogButton = [[UIButton alloc] initWithFrame:CGRectMake(844, 550 + yOffset, 150, 38)];
                    if (config.externalApplicationButtonEnabled) {
                        onlineCatalogButton.frame = CGRectMake(844, 598 + yOffset, 150, 38);
                    }
                    
                    onlineCatalogButton.titleLabel.numberOfLines = 2;
                    onlineCatalogButton.titleLabel.font = [UIFont fontWithName:config.onlineCatalogButtonFont size:14.0f];
                    onlineCatalogButton.titleLabel.textColor = config.onlineCatalogButtonTextColor;
                    onlineCatalogButton.titleLabel.textAlignment = NSTextAlignmentCenter;
                    onlineCatalogButton.titleLabel.shadowColor = config.onlineCatalogButtonShadowColor;
                    onlineCatalogButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
                    [onlineCatalogButton setBackgroundImage:[UIImage contentFoundationResourceImageNamed:config.onlineCatalogButtonImageNamed] forState:UIControlStateNormal];
                    [onlineCatalogButton setTitle:[config.onlineCatalogButtonTitle uppercaseString] forState:UIControlStateNormal];
                    [onlineCatalogButton addTarget:self action: @selector(onlineCatalogButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:onlineCatalogButton];
                }
            }];
        }
        
        if (config.categoryShortcutButtonEnabled) {
            // Add the category shortcut button
            
            CGRect categoryShortcutFrame = CGRectZero;
            
            if (onlineCatalogButton || config.externalApplicationButtonEnabled) {
                if (onlineCatalogButton && config.externalApplicationButtonEnabled) {
                    categoryShortcutFrame = CGRectMake(844, 646 + yOffset, 150, 38);
                } else {
                    categoryShortcutFrame = CGRectMake(844, 598 + yOffset, 150, 38);
                }
            }
            else{
                categoryShortcutFrame = CGRectMake(844, 550 + yOffset, 150, 38);
            }
            
            UIButton * categoryShortcutButton = [[UIButton alloc] initWithFrame:categoryShortcutFrame];
            categoryShortcutButton.titleLabel.numberOfLines = 2;
            categoryShortcutButton.titleLabel.font = [UIFont fontWithName:config.categoryShortcutButtonFont size:14.0f];
            categoryShortcutButton.titleLabel.textColor = config.categoryShortcutButtonTextColor;
            categoryShortcutButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            categoryShortcutButton.titleLabel.shadowColor = config.categoryShortcutButtonShadowColor;
            categoryShortcutButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
            [categoryShortcutButton setBackgroundImage:[UIImage contentFoundationResourceImageNamed:config.categoryShortcutButtonImageNamed] forState:UIControlStateNormal];
            [categoryShortcutButton setTitle:[config.categoryShortcutButtonTitle uppercaseString] forState:UIControlStateNormal];
            [categoryShortcutButton addTarget:self action: @selector(categoryShortcutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:categoryShortcutButton];
        }
        
        // Setup the subviews
        
        //[self setupProductInfoView];
        //[self setupResourcePreviewView];
        //[self setupResourceMenuView];
        //  
        DetailFavoritesViewController *detailFavoritesController = [[DetailFavoritesViewController alloc] init];
        self.detailFavoritesPopover = [[UIPopoverController alloc] initWithContentViewController:detailFavoritesController];
        
        DetailSearchViewController *detailSearchController = [[DetailSearchViewController alloc] init];
        self.detailSearchPopover = [[UIPopoverController alloc] initWithContentViewController:detailSearchController];
        
        HierarchyNavigationViewController *hierarchyController = [[HierarchyNavigationViewController alloc] init];
        hierarchyController.rootLevelVCAtTop = NO;
        self.hierarchyPopover = [[UIPopoverController alloc] initWithContentViewController:hierarchyController];
        
        SFAppSetupViewController *setupController = [[SFAppSetupViewController alloc] init];
        self.setupPopover = [[UIPopoverController alloc] initWithContentViewController:setupController];
        
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

-(void) onlineCatalogButtonPressed:(id)sender; {
    CompanyWebViewConfig *webConfig = [[SFAppConfig sharedInstance] getCompanyWebViewConfig];
    CompanyWebViewController *webController = [[CompanyWebViewController alloc] initWithUrl:[NSURL URLWithString:onlineCatalogResourceUrl] andConfig:webConfig];
    webController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [productNavigationController presentViewController:webController animated:YES completion:NULL];
}

-(void) externalAppButtonPressed:(id)sender; {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:config.externalApplicationButtonAppCheckUrl]]) {
        NSString *stringURL = config.externalApplicationButtonAppOpenUrl;
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Warning"
                              message: @"External application is not installed"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void) categoryShortcutButtonPressed:(id)sender; {
    
    [[[[ContentLookup sharedInstance] impl] mainCategoryPaths] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        NSString *lookingForCategory = (config.categoryShortcutButtonCategory && config.categoryShortcutButtonCategory.length > 0) ? config.categoryShortcutButtonCategory : config.categoryShortcutButtonTitle;
        if ([obj contentTitle] && [[obj contentTitle] caseInsensitiveCompare:lookingForCategory] == NSOrderedSame) {
            NSMutableArray * vc = [[NSMutableArray alloc] initWithArray:productNavigationController.navigationController.viewControllers];
            NSArray * arr = [vc subarrayWithRange:NSMakeRange(0, 1)];
            vc = [NSMutableArray arrayWithArray:arr];
            BasicCategoryViewController * nextLevel = [[BasicCategoryViewController alloc] initWithCategoryPath:obj];
            [vc addObject:nextLevel];
            [productNavigationController.navigationController setViewControllers:vc animated:YES];
        }
    }];
    
}

- (void) addViewsOnAppear {
    if (productPhotoView == nil) {
        [self setupProductInfoView];
    }
    
    if (resourcePreviewView == nil) {
        int menuTag = (int) currentResourceMenuSelection;
        
        [self setupResourcePreviewView];
        
        // Force Layout of the preview view
        [resourcePreviewView layoutSubviews];
        
        currentResourceMenuSelection = -1;
        [resourceMenuView selectTab:menuTag];
    }
    
    if (resourceMenuView == nil) {
        [self setupResourceMenuView];
    }

    
    [self setNeedsLayout];
}

- (void) removeViewsOnDisappear {
    // Track the current scroll position of the resource preview view
    previewScrollOrigin = resourcePreviewView.docPreviewStripView.containingScrollView.contentOffset;
    
    [resourceMenuView removeFromSuperview];
    [resourcePreviewView removeFromSuperview];
    [productPhotoView removeFromSuperview];
    if (productFeaturesView != nil) {
        [productFeaturesView removeFromSuperview];
        productFeaturesView = nil;
    }
    
    resourceMenuView = nil;
    resourcePreviewView = nil;
    productPhotoView = nil;
}

#pragma mark -
#pragma mark ContentInfoToolbarDelegate Methods


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

#pragma mark -
#pragma mark layout methods

- (void) layoutSubviews {        
    [super layoutSubviews];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect screen = [UIScreen rectForScreenView:orientation];
    CGSize size = screen.size;
    
    [self resizeBadge:size];
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

#pragma mark -
#pragma mark Private Methods
- (void) setupResourceMenuView {
    
    ResourceTabMenuConfig *menuConfig = [[ResourceTabMenuConfig alloc] init];
    
    // Find out if we have an resource groups that need to be excluded from the menu.
    NSArray *excludedResources =[[SFAppConfig sharedInstance] getExcludedResources];
    
    // Build the button configs
    if ([contentProduct hasResources]) {
        for (id<ContentViewBehavior> resourceGroup in [contentProduct contentResources]) {
            BOOL display = YES;
            if (excludedResources && [excludedResources count] > 0) {
                NSString *resourceGroupTitle = [resourceGroup contentTitle];
                for (NSString *ex in excludedResources) {
                    if (ex && [ex caseInsensitiveCompare:resourceGroupTitle] == NSOrderedSame) {
                        display = NO;
                        break;
                    }
                }
            }
            if (display && [resourceGroup hasResourceItems]) {
                ResourceTabConfig *resourceTabConfig = [[SFAppConfig sharedInstance] getResourceTabConfig:resourceGroup];
                [menuConfig.tabConfigList addObject:resourceTabConfig];
            }
        }
    }
    
    if ([contentProduct hasIndustryProducts]) {
        ResourceTabConfig *industryProductConfig = [[SFAppConfig sharedInstance] getResourceTabConfig:contentProduct];
        // Override the usual button title setting which would be the Industry title in this case.
        industryProductConfig.buttonTitle = @"Products";
        [menuConfig.tabConfigList addObject:industryProductConfig];
    }
    
    ResourceTabConfig *tabconfig = [menuConfig.tabConfigList lastObject];
    
    resourceMenuView = [[ResourceTabMenuView alloc] initWithFrame:CGRectMake(1, 1, [menuConfig.tabConfigList count] * tabconfig.tabSize.width, tabconfig.tabSize.height) andConfig:menuConfig];
    resourceMenuView.delegate = self;
    
    [resourcePreviewView addSubview:resourceMenuView];
  
}

- (void) setupProductInfoView {
    
    // ProductPhotoView is the Image Preview of an Item
    productPhotoView = [[ProductPhotoView alloc] initWithFrame:CGRectMake(30, 224 + yOffset, 388, 258) contentProduct:contentProduct];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(openPreview)];
    tap2.numberOfTapsRequired = 1;
    [productPhotoView.productImage addGestureRecognizer: tap2];
    [self addSubview:productPhotoView];
    
    BOOL __block hasFeatures = NO;    
    if ([contentProduct hasResources]) { //check if any features exist        
        [[contentProduct contentResources] enumerateObjectsUsingBlock:^(id<ContentViewBehavior> obj, NSUInteger idx, BOOL * stop) {            
            if ([obj contentTitle] && [[obj contentTitle] caseInsensitiveCompare:config.includedResourceGroup] == NSOrderedSame) {
                *stop = YES;                
                hasFeatures = YES;                
                return;                
            }                        
        }];        
    }    
    if (hasFeatures) {        
        productFeaturesView = [[TabbedPortfolioFeaturesView alloc] initWithFrame:CGRectMake(418, 134 + yOffset, 596, 338) andContentProduct:contentProduct];
        [self addSubview:productFeaturesView];
    }
}

- (void) setupResourcePreviewView {
    
    //ResourcePreviewView is the Document Previewer
    NSArray *excludedResources = [[SFAppConfig sharedInstance] getExcludedResources];
    
    BOOL display = NO;
    
    // This check will tell us if the Product or the Industry has resource groups to
    // display.
    if ([contentProduct hasResources]){
        //No excluded resoures, show everything
        if ([excludedResources count] < 1) {
            display = YES;
        }
        
        
        for (id<ContentViewBehavior> resourceGroup in [contentProduct contentResources]) {
            if (excludedResources && [excludedResources count] > 0) {
                NSString *resourceGroupTitle = [resourceGroup contentTitle];
                if (![excludedResources containsObject:resourceGroupTitle]) {
                    display = YES;
                }
                
            }
        }
    }
  
    // If we have industry products attached, then we are an Industry and need to set
    // up a display for our highlighted products.
    if ([contentProduct hasIndustryProducts]) {
        display = YES;
    }

    if (([contentProduct hasResources] || [contentProduct hasIndustryProducts]) && display) {
        
        CGFloat width = 804;
        if (!onlineCatalogButton && config.categoryShortcutButtonEnabled == NO) {
            width = 970;
        }
        
        resourcePreviewView = [[ResourceListPreviewView alloc] initWithFrame:CGRectMake(30, 510 + yOffset, width, 194) productNavController:self.productNavigationController mailSetupDelegate:nil withTabs:NO andContentProduct:contentProduct];
        [self addSubview:resourcePreviewView];
    }
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

- (void) logoTapped:(UITapGestureRecognizer *)tapGesture {
    NSString *urlString = [[SFAppConfig sharedInstance] getTabbedPortfolioDetailViewConfig].leftLogoLink;
    
    CompanyWebViewController *webViewController = [[CompanyWebViewController alloc] initWithUrl:[NSURL URLWithString:urlString] andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
    webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [productNavigationController presentViewController:webViewController animated:YES completion:NULL];
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

-(void) homeButtonPressed:(id)sender; {
    [self backToMain];
}

@end

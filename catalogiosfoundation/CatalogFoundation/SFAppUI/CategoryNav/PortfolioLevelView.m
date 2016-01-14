//
//  ProductLevelView.m
//  SickApp
//
//  Created by Steven McCoole on 2/13/12.
//  Copyright (c) 2012 Object Partners Inc. All rights reserved.
//

#import "PortfolioLevelView.h"
#import "UIImage+CatalogFoundationResourceImage.h"

#import "CompanyWebViewController.h"

#import "UIImage+Extensions.h"
#import "UIScreen+Helpers.h"
#import "NSString+Extensions.h"

#import "ContentUtils.h"

#import "SFAppConfig.h"

#import "BorderLayout.h"
#import "VerticalLayout.h"
#import "HorizontalLayout.h"
#import "FillLayout.h"

@interface PortfolioLevelView()

- (void) resizeBadge:(CGSize)screenSize;

- (void) leftLogoTapped:(UITapGestureRecognizer *) tapGesture;

- (void) presentWebView: (NSURL *) url;

@end

@implementation PortfolioLevelView
@synthesize delegate;
@synthesize thumbnailDelegate;
@synthesize navController;

@synthesize levelPath;

@synthesize logoView;
@synthesize bgImageView;
@synthesize toolbarView;
@synthesize progressView;
@synthesize levelView;

#pragma mark -
#pragma mark init/dealloc methods
- (id) initWithFrame:(CGRect)frame navController:(UINavigationController *)controller andLevelPath:(id<ContentViewBehavior>)path {
    self = [super initWithFrame:frame];
    if (self) {
        
        if (path) {
            levelPath = path;
        } else {
            levelPath = nil;
        }
        
        navController = controller;
        
        // init logo
        NSString *logoLeft = [[SFAppConfig sharedInstance] getBasicCategoryViewConfig].leftLogoNamed;
        
        if ([NSString isNotEmpty:logoLeft]) {
            UIImage *leftLogoImage = [UIImage imageResource:logoLeft];
            
            logoView = [[UIImageView alloc] initWithImage:leftLogoImage];
            logoView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(leftLogoTapped:)];
            tap.numberOfTapsRequired = 1;
            [logoView addGestureRecognizer: tap];
        } else {
            logoView = [[UIImageView alloc] initWithImage:[UIImage imageResource:@"logo.png"]];
            logoView.userInteractionEnabled = YES;
        }

        // init toobar
        toolbarView = [[ContentInfoToolbarView alloc] initWithFrame:CGRectZero andConfig:[[SFAppConfig sharedInstance] getContentInfoToolbarConfig]];
        toolbarView.delegate = self;

        BasicCategoryViewConfig *config = [[SFAppConfig sharedInstance] getBasicCategoryViewConfig];
        if (config.mainViewBgImageNamed || config.mainViewLandBgImageNamed || config.mainViewPortBgImageNamed) {
            bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [bgImageView setContentMode:UIViewContentModeScaleAspectFill];
            [self addSubview:bgImageView];
        }

        [self addSubview:logoView];
        [self addSubview:toolbarView];
        
        BorderRegion *centerRegion = nil;
        
        if (levelPath) {
            // init level view
            levelView = [[ProductLevelScrollView alloc] initWithFrame:CGRectZero levelPath:levelPath];
            levelView.numThumbsLandscape = config.thumbsPerPageLandscape;
            levelView.numThumbsPortrait = config.thumbsPerPagePortrait;
            
            if (config.pageControlActiveColor && config.pageControlInactiveColor) {
                UIView *activeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 10)];
                activeView.backgroundColor = config.pageControlActiveColor;
                
                UIView *inactiveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 10)];
                inactiveView.backgroundColor = config.pageControlInactiveColor;
                
                UIImage *activeImage = nil;
                UIImage *inactiveImage = nil;
                
                UIGraphicsBeginImageContext(activeView.bounds.size);
                [activeView.layer renderInContext:UIGraphicsGetCurrentContext()];
                activeImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                UIGraphicsBeginImageContext(inactiveView.bounds.size);
                [inactiveView.layer renderInContext:UIGraphicsGetCurrentContext()];
                inactiveImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                [levelView.levelPageControl setActiveImage:activeImage];
                [levelView.levelPageControl setInactiveImage:inactiveImage];
            }
            
            [self addSubview:levelView];
            centerRegion = [BorderRegion layout:[FillLayout items:[ViewItem viewItemFor:levelView], nil]];
        } else {
            progressView = [[ToloContentProgressView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            [progressView setupForInitialDownloadProgress];
            progressView.totalContentChanges = 0;
            [self addSubview:progressView];
            centerRegion = [BorderRegion layout:[FillLayout items:[ViewItem viewItemFor:progressView], nil]];
        }
        
        [self addSubview:levelView];
        
        NSString *marginString = @"10px";
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            // Add status bar height for iOS 7 and up
            marginString = @"30px 10px 10px 10px";
        }
        
        if (config.displayCategoryTitle) {
            
            UILabel *productsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            productsLabel.font = [UIFont fontWithName:config.categoryTitleFontName size:config.categoryTitleFontSize];
            productsLabel.text = [[levelPath contentTitle] uppercaseString];
            productsLabel.backgroundColor = [UIColor clearColor];
            productsLabel.textColor = config.categoryTitleFontColor;
            [self addSubview:productsLabel];
            
            // Configure like Donaldson layout
            BorderLayout *topLayout = [BorderLayout
                                       margin:@"0px 0px 60px 0px"
                                       padding:@"0px"
                                       north:nil
                                       south:[BorderRegion layout:
                                              [VerticalLayout margin:@"0px 30px 0px 30px"
                                                             padding:@"0px"
                                                              valign:@"top"
                                                              halign:@"right"
                                                               items:[ViewItem viewItemFor:productsLabel
                                                                                     width:@"100%"
                                                                                    height:@"44px"],
                                               nil]]
                                       east:nil
                                       west:[BorderRegion
                                             size:@"162px"
                                             useBorderLayoutProps:NO
                                             layout:[HorizontalLayout margin:@"0px 12px 0px 30px"
                                                                     padding:@"0px"
                                                                      valign:@"top"
                                                                      halign:@"left"
                                                     items:[ViewItem viewItemFor:logoView],nil]]
                                       center:[BorderRegion layout:
                                               [VerticalLayout margin:@"0px"
                                                              padding:@"0px"
                                                               valign:@"top"
                                                               halign:@"right"
                                                            items:[ViewItem viewItemFor:toolbarView
                                                                                   width:@"100%"
                                                                                  height:@"44px"],
                                                                  [ViewItem viewItemFor:nil],
                                                                  nil]]
                                       
                                       ];
            
            layout = [BorderLayout margin:marginString padding:@"0px"
                                    north:[BorderRegion size:@"144px"
                                        useBorderLayoutProps:NO
                                                      layout:topLayout]
                                    south:nil
                                     east:nil
                                     west:nil
                                   center:centerRegion
                      ];

        } else {
            layout = [BorderLayout margin:marginString padding:@"0px"
                                 north:[BorderRegion size:@"85px" useBorderLayoutProps:NO 
                                                   layout:[BorderLayout margin:@"0px 0px 10px 0px" padding:@"0px" 
                                                                         north:nil 
                                                                         south:nil
                                                                          east:nil 
                                                                          west:[BorderRegion size:@"170px" useBorderLayoutProps:NO 
                                                                                           layout:[HorizontalLayout margin:@"0px" padding:@"0px" 
                                                                                                                    valign:@"top"
                                                                                                                    halign:@"left"
                                                                                                                     items:[ViewItem viewItemFor:logoView],nil]] 
                                                                        center:[BorderRegion layout:
                                                                                [VerticalLayout margin:@"0px" 
                                                                                               padding:@"0px" 
                                                                                                valign:@"center" 
                                                                                                halign:@"right" 
                                                                                                 items:[ViewItem viewItemFor:toolbarView 
                                                                                                                       width:@"100%"
                                                                                                                      height:@"50%"],
                                                                                                        [ViewItem viewItemFor:nil 
                                                                                                                        width:@"100%"
                                                                                                                       height:@"50%"], nil]]
                                                                                                   
                                                           ]
                                        ]
                                 south:nil 
                                  east:nil 
                                  west:nil 
                                center:centerRegion
                   ];
        }
        
    }
    return self;
}


#pragma mark - Accessors/Setters
- (void) setThumbnailDelegate:(id<ProductThumbnailDelegate>)aThumbnailDelegate {
    if (thumbnailDelegate != aThumbnailDelegate) {
        thumbnailDelegate = aThumbnailDelegate;
        if (levelView) {
            levelView.thumbnailDelegate = thumbnailDelegate;
        }
    }
}

#pragma mark - Public Methods
- (void) loadLevelThumbnails {
    if (levelView) {
        [levelView loadSubLevelThumbnailImages];
    }
}

- (void) updateBadgeText: (NSString *) newBadgeText {
    [self.toolbarView updateBadgeText:newBadgeText];
}

#pragma mark -
#pragma mark layout code
- (void) layoutSubviews {
    [super layoutSubviews];

    // Arrange the view according to the defined layout
    [layout layoutForView:self];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect screen = [UIScreen rectForScreenView:orientation];
    CGSize size = screen.size;
    
    // Set the background for the view
    BasicCategoryViewConfig *config = [[SFAppConfig sharedInstance] getBasicCategoryViewConfig];
    
    if (bgImageView) {
        bgImageView.frame = self.bounds;
        // If a background image was configured see if we have specific ones
        // for portrait or landscape.
        if (config.mainViewLandBgImageNamed && UIInterfaceOrientationIsLandscape(orientation)) {
            [bgImageView setImage:[UIImage contentFoundationResourceImageNamed:config.mainViewLandBgImageNamed]];
        } else if (config.mainViewPortBgImageNamed && UIInterfaceOrientationIsPortrait(orientation)) {
            [bgImageView setImage:[UIImage contentFoundationResourceImageNamed:config.mainViewPortBgImageNamed]];
        } else {
            [bgImageView setImage:[UIImage contentFoundationResourceImageNamed:config.mainViewBgImageNamed]];
        }
        
    } else if (config.mainViewPortBgColor && UIInterfaceOrientationIsPortrait(orientation)) {
        
        // This is if a repeating pattern image is used and converted into a
        // UIColor.
        self.backgroundColor = config.mainViewPortBgColor;
        
    } else if (config.mainViewLandBgColor && UIInterfaceOrientationIsLandscape(orientation)) {
        
        // This is if a repeating pattern image is used and converted into a
        // UIColor.
        self.backgroundColor = config.mainViewLandBgColor;
        
    } else {
        
        // Just a plain old color.
        self.backgroundColor = config.mainViewBgColor;
        
    }
    
    [self resizeBadge:size];
}

#pragma mark - ContentInfoToolbarDelegate methods
- (void) toolbarButtonTapped:(id)selector {
    if (delegate && [delegate respondsToSelector:@selector(toolbarButtonTapped:)]) {
        [delegate toolbarButtonTapped:selector];
    }
}

- (void) longPressOnToolbarButton:(id)toolbarButton {
    if (delegate && [delegate respondsToSelector:@selector(longPressOnToolbarButton:)]) {
        [delegate longPressOnToolbarButton:toolbarButton];
    }
}

- (void) selectedSyncAction:(SyncActionType)syncAction {
    
    if (delegate && [delegate respondsToSelector:@selector(selectedSyncAction:)]) {
        [delegate selectedSyncAction:syncAction];
    }
    
}

#pragma mark - Private Methods
- (void) leftLogoTapped:(UITapGestureRecognizer *)tapGesture {
    NSString *urlString = [[SFAppConfig sharedInstance] getBasicCategoryViewConfig].leftLogoLink;
    
    if ([NSString isNotEmpty:urlString]) {
        [self presentWebView:[NSURL URLWithString:urlString]];
    }
}

- (void) resizeBadge:(CGSize)screenSize {
    [self.toolbarView resizeBadge];
}

- (void) presentWebView:(NSURL *)url {
    CompanyWebViewController *webViewController = [[CompanyWebViewController alloc] initWithUrl:url andConfig:[[SFAppConfig sharedInstance] getCompanyWebViewConfig]];
    
    webViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    // Get current controller
    [navController presentViewController:webViewController animated:YES completion:NULL];
}

@end

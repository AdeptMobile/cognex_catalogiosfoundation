//
//  SFAppConfig.h
//  CatalogFoundation
//
//  Created by Torey Lomenda on 1/29/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ContentViewBehavior.h"

#import "ContentSyncConfig.h"
#import "CarouselMainConfig.h"
#import "GridMainConfig.h"
#import "SFLoginConfig.h"
#import "SFDownloadViewConfig.h"
#import "SFRequestLoginConfig.h"
#import "SFChangePasswordConfig.h"
#import "SFAppSetupConfig.h"

#import "BasicCategoryViewConfig.h"

#import "BasicPortfolioDetailViewConfig.h"
#import "TabbedPortfolioDetailViewConfig.h"
#import "PortfolioDetailVideoControllerConfig.h"
#import "ProductPhotoViewConfig.h"
#import "ResourcePreviewConfig.h"
#import "ResourceButtonMenuConfig.h"
#import "ResourceButtonConfig.h"
#import "ResourceTabConfig.h"
#import "GalleryDetailViewControllerConfig.h"

#import "CompanyWebViewConfig.h"
#import "CompanyInfoHtmlViewConfig.h"

#import "ContentInfoToolbarConfig.h"

#import "PdfViewControllerConfig.h"

@interface SFAppConfig : NSObject {
    NSDictionary *appConfigDict;
}

+ (SFAppConfig *) sharedInstance;

#pragma mark - SF App General Config
- (NSString *) getAppAlertTitle;
- (NSString *) getBrandTitle;

#pragma mark - SF In App Updater
- (NSString *) getAppUpdaterBaseUrl;
- (NSString *) getAppUpdaterManfestPath;
- (NSString *) getAppUpdaterUsername;
- (NSString *) getAppUpdaterPassword;

#pragma mark - SF App Content Config
- (ContentSyncConfig *) getContentSyncConfig;

- (NSURL *) getUserCheckUrl;
- (NSURL *) getContentMetadataUrl;
- (NSURL *) getContentStructureUrl;
- (BOOL) isContentStructureSyncEnabled;

- (BOOL) isAuthRequiredForJSON;
- (BOOL) isAuthRememberLoginEnabled;

- (BOOL) isDownloadFilteringEnabled;
- (BOOL) isVideoFilteringEnabled;
- (BOOL) isPresentationFilteringEnabled;
- (NSString *) getLocalContentRoot;
- (NSString *) getLocalContentDocPath;
- (NSString *) getLocalContentSymlinkRef;

- (NSString *) getLocalContentResourcePath;
- (NSString *) getLocalSyncRoot;

- (BOOL) doIgnoreLocalPath:(NSString *)path;
- (BOOL) doWordifyLabel;

- (NSArray *) getExcludedResources;

- (NSString *) getBundledContentZip;

#pragma mark - SF APP Setup View Config
- (SFAppSetupConfig *)getAppSetupViewConfig;

#pragma mark - SF APP Login View Config
- (SFLoginConfig *)getLoginViewConfig;

#pragma mark - SF App Download View Config
- (SFDownloadViewConfig *)getDownloadViewConfig;

#pragma mark - SF App Request Login View Config
- (SFRequestLoginConfig *)getRequestLoginConfig;

#pragma mark - SF App Change Password View Config
- (SFChangePasswordConfig *)getChangePasswordConfig;

#pragma mark - SF App Main View Config
- (id) getMainViewController;
- (BOOL) getMainViewControllerLandscapeOnly;
- (CarouselMainConfig *) getMainCarouselConfig;
- (GridMainConfig *) getMainGridConfig;

#pragma mark - SF App Splash View Config
- (BOOL) getSplashViewControllerLandscapeOnly;
- (NSString *) getSplashViewControllerType;

#pragma mark - SF App Category Nav View Config
- (id) getCategoryNavViewController:  (id<ContentViewBehavior>) path;
- (BOOL) getCategoryNavViewControllerLandscapeOnly;
- (BasicCategoryViewConfig *) getBasicCategoryViewConfig;

#pragma mark - SF App Portfolio Detail View Config
- (id) getPortfolioDetailViewController:  (id<ContentViewBehavior>) path;
- (id) getPortfolioGalleryViewController:(id<ContentViewBehavior>)path;
- (BOOL) getPortfolioDetailViewControllerLandscapeOnly;
- (BasicPortfolioDetailViewConfig *) getBasicPortfolioDetailViewConfig;
- (TabbedPortfolioDetailViewConfig *) getTabbedPortfolioDetailViewConfig;
- (PortfolioDetailVideoControllerConfig *) getPortfolioDetailVideoControllerConfig;

- (ProductPhotoViewConfig *) getProductPhotoViewConfig;
- (ResourcePreviewConfig *) getPortfolioResourcePreviewConfig;
- (ResourceButtonMenuConfig *) getPortfolioResourceButtonMenuConfig;
- (ResourceTabConfig *) getResourceTabConfig:(id<ContentViewBehavior>) contentItem;
- (ResourceButtonConfig *) getPortfolioResourceButtonConfig:(id<ContentViewBehavior>) resourceGroup;

- (UIColor *) getPortfolioPreviewToolbarTintColor;
- (NSInteger) getPortfolioPreviewMoviePlayerStyle;

- (BOOL) allowPreviewForResourceItem: (NSURL *) resourceUrl;

#pragma mark - Gallery Detail View Config
- (GalleryDetailViewControllerConfig *)getGalleryDetailViewConfig;

#pragma mark - SF App Company Web  and HTML Info View Config
- (CompanyWebViewConfig *) getCompanyWebViewConfig;
- (CompanyInfoHtmlViewConfig *) getCompanyInfoHtmlViewConfig;

#pragma mark - SF App Toolbar Configs
- (ContentInfoToolbarConfig *) getContentInfoToolbarConfig;

#pragma mark - Sketch View Config
- (UIColor *) getSketchViewTintColor;
- (UIColor *) getSketchViewBgColor;

#pragma mark - PDF View Controller Config
- (PdfViewControllerConfig *) getPdfViewControllerConfig;

@end

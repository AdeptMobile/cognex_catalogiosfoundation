//
//  SFAppConfig.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 1/29/13.
//  Copyright (c) 2013 NA. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>

#import "SFAppConfig.h"

#import "OPIFoundation.h"

#import "CarouselMainViewController.h"
#import "GridMainConfig.h"
#import "GridMainViewController.h"

#import "BasicCategoryViewController.h"

#import "BasicPortfolioDetailViewController.h"
#import "TabbedDetailViewController.h"
#import "GalleryDetailViewController.h"

#import "UIImage+CatalogFoundationResourceImage.h"
#import "NSString+Extensions.h"
#import "UIColor+Chooser.h"


#define APPCONFIG_DICT @"com.sf.app"
#define APPCONFIG_UPDATER_DICT @"com.sf.app.updater"
#define APPCONFIG_CONTENT_DICT @"com.sf.app.content"

#define APPCONFIG_TOOLBAR_NAV_DICT @"com.sf.app.toolbar.nav"

#define APPCONFIG_LOGINVIEW_DICT @"com.sf.app.login"
#define APPCONFIG_DOWNLOADCONFIG_DICT @"com.sf.app.download.config"
#define APPCONFIG_REQUESTLOGIN_DICT @"com.sf.app.requestlogin"
#define APPCONFIG_CHANGEPASSWORD_DICT @"com.sf.app.changePassword.config"
#define APPCONFIG_APPSETUPCONFIG_DICT @"com.sf.app.setup.config"

#define APPCONFIG_MAINVIEW_DICT @"com.sf.app.mainview"
#define APPCONFIG_CATVIEW_DICT @"com.sf.app.categoryview"
#define APPCONFIG_SPLASHVIEW_DICT @"com.sf.app.splashview"

#define APPCONFIG_PORTFOLIO_MAINVIEW_DICT @"com.sf.app.portfolio.mainview"
#define APPCONFIG_PORTFOLIO_VIDEOVIEW_DICT @"com.sf.app.portfolio.videoview"
#define APPCONFIG_PORTFOLIO_PHOTOVIEW_DICT @"com.sf.app.portfolio.photoview"
#define APPCONFIG_PORTFOLIO_PREVIEW_DICT @"com.sf.app.portfolio.preview"
#define APPCONFIG_PORTFOLIO_RESOURCEMENU_DICT @"com.sf.app.portfolio.resourcemenu"
#define APPCONFIG_PORTFOLIO_RESOURCETAB_DICT @"com.sf.app.portfolio.resourcetab"

#define APPCONFIG_PORTFOLIO_GALLERY_DICT @"com.sf.app.portfolio.gallery"

#define APPCONFIG_INFOHTMLVIEW_DICT @"com.sf.app.infohtmlview"
#define APPCONFIG_WEBVIEW_DICT @"com.sf.app.webview"
#define APPCONFIG_SKETCHVIEW_DICT @"com.sf.app.sketchview"
#define APPCONFIG_DOCPREVIEW_DICT @"com.sf.app.doc.preview"
#define APPCONFIG_DOCVIEWER_DICT @"com.sf.app.doc.viewer"

@interface SFAppConfig()

- (NSString *) tidyUrlString: (NSString *) urlString;

- (NSString *) valueForKey: (NSString *) key inDictionary: (NSString *) dictKey;
- (BOOL) boolForKey: (NSString *) key inDictionary: (NSString *) dictKey;

- (UIFont *) fontForName: (NSString *) fontKey size: (NSString *) fontSizeKey inDictionary: (NSString *) dictKey;

- (UIColor *) colorForKey: (NSString *) key inDictionary: (NSString *) dictKey;
- (UIColor *) colorPortraitForKey: (NSString *) key inDictionary: (NSString *) dictKey;
- (UIColor *) colorLandscapeForKey: (NSString *) key inDictionary: (NSString *) dictKey;
- (NSString *) imagePortraitForKey: (NSString *) key inDictionary: (NSString *) dictKey;
- (NSString *) imageLandscapeForKey: (NSString *) key inDictionary: (NSString *) dictKey;
- (UIViewContentMode) contentModeForKey: (NSString *)key inDictionary: (NSString *) dictKey;
- (NSTextAlignment) textAlignmentForKey: (NSString *)key inDictionary: (NSString *) dictKey;

@end

@implementation SFAppConfig

#pragma mark - Singleton
+ (SFAppConfig *) sharedInstance {
    
    static dispatch_once_t pred;
    static SFAppConfig *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        
        sharedInstance = [[self alloc] init];
        
    });
    
    return sharedInstance;
}

#pragma mark - init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        // Initialize
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"SFAppConfig" ofType:@"plist"];
        appConfigDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    
    return self;
}

- (void) dealloc {
    appConfigDict = nil;
    
}

#pragma mark - SF App General Configuration
- (NSString *) getAppAlertTitle {
    NSString *value = [self valueForKey:@"alertTitle" inDictionary:APPCONFIG_DICT];
    return value;
}

- (NSString *) getBrandTitle {
    NSString *value = [self valueForKey:@"brandTitle" inDictionary:APPCONFIG_DICT];
    return value;
}

#pragma mark - SF In App Updater
- (NSString *) getAppUpdaterBaseUrl {
    NSString *value = [self valueForKey:@"baseUrl" inDictionary:APPCONFIG_UPDATER_DICT];
    return value;
}

- (NSString *) getAppUpdaterManfestPath {
    NSString *value = [self valueForKey:@"manifestPath" inDictionary:APPCONFIG_UPDATER_DICT];
    return value;
}

- (NSString *) getAppUpdaterUsername {
    NSString *value = [self valueForKey:@"basicauth.user" inDictionary:APPCONFIG_UPDATER_DICT];
    return value;
}

- (NSString *) getAppUpdaterPassword {
    NSString *value = [self valueForKey:@"basicauth.pwd" inDictionary:APPCONFIG_UPDATER_DICT];
    return value;
}

#pragma mark - SF App Main View Config
- (id) getMainViewController {
    NSString *value = [self valueForKey:@"type" inDictionary:APPCONFIG_MAINVIEW_DICT];
    
    if ([NSString isNotEmpty:value]) {
        if ([value isEqualToString:@"carousel"]) {
            return [[CarouselMainViewController alloc] init];
        } else  if ([value isEqualToString:@"grid"]) {
            return [[GridMainViewController alloc] init];
        }
    }
    
    // By default return a carousel implementation
    return [[CarouselMainViewController alloc] init];
}

- (BOOL) getMainViewControllerLandscapeOnly {
   return [[self valueForKey:@"landscapeOnly" inDictionary:APPCONFIG_MAINVIEW_DICT] boolValue];
}

- (GridMainConfig *) getMainGridConfig {
    GridMainConfig *config = [[GridMainConfig alloc] init];
    config.pageControlActiveColor = [self colorForKey:@"grid.pagecontrol.activeColor" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.pageControlInactiveColor = [self colorForKey:@"grid.pagecontrol.inactiveColor" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.thumbsPerPagePortrait = [self numberForKey:@"grid.thumbsPerPagePortrait" inDictionary:APPCONFIG_MAINVIEW_DICT].integerValue;
    config.thumbsPerPageLandscape = [self numberForKey:@"grid.thumbsPerPageLandscape" inDictionary:APPCONFIG_MAINVIEW_DICT].integerValue;
    config.bgImageName = [self valueForKey:@"grid.bgImage" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.bgColor = [self colorForKey:@"grid.bgColor" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.scrollBgColor = [self colorForKey:@"grid.scrollBgColor" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.titleImageRotates = [self boolForKey:@"grid.titleImageRotates" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.titleImageArray = [self arrayForKey:@"grid.titleImageArray" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.statusBarColor = [self colorForKey:@"grid.statusBar.bgColor" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.initialDownloadImageName = [self valueForKey:@"grid.initialDownloadImage" inDictionary:APPCONFIG_MAINVIEW_DICT];
    
    config.leftLogoNamed = [self valueForKey:@"carousel.logoLeft" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.rightLogoNamed = [self valueForKey:@"carousel.logoRight" inDictionary:APPCONFIG_MAINVIEW_DICT];
    
    config.leftLogoLink = [self valueForKey:@"carousel.logoLeftLink" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.rightLogoLink = [self valueForKey:@"carousel.logoRightLink" inDictionary:APPCONFIG_MAINVIEW_DICT];


    config.scrollViewFrameOffset = [self numberForKey:@"grid.scrollViewFrameOffset" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.tightLayoutFrameHeight = [self numberForKey:@"grid.tightLayoutFrameHeight" inDictionary:APPCONFIG_MAINVIEW_DICT];

    config.mainViewScrollFrameHeight = [self numberForKey:@"grid.mainViewScrollFrameHeight" inDictionary:APPCONFIG_MAINVIEW_DICT];

    return config;
}

- (CarouselMainConfig *) getMainCarouselConfig {
    CarouselMainConfig *config = [[CarouselMainConfig alloc] init];
    
    config.isReflectionOn = [self boolForKey:@"carousel.reflectionOn" inDictionary:APPCONFIG_MAINVIEW_DICT];

    config.leftLogoNamed = [self valueForKey:@"carousel.logoLeft" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.rightLogoNamed = [self valueForKey:@"carousel.logoRight" inDictionary:APPCONFIG_MAINVIEW_DICT];
    
    config.leftLogoLink = [self valueForKey:@"carousel.logoLeftLink" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.rightLogoLink = [self valueForKey:@"carousel.logoRightLink" inDictionary:APPCONFIG_MAINVIEW_DICT];
    
    config.bgColor = [self colorForKey:@"carousel.bgColor" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.bgImage = [self valueForKey:@"carousel.bgImage" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.initialBgImage = [self valueForKey:@"carousel.initialBgImage" inDictionary:APPCONFIG_MAINVIEW_DICT];
    
    // Determine of I need to set a portrait and landcape pattern for the background
    config.bgImagePortrait = [self imagePortraitForKey:@"carousel.bgImage" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.bgImageLandscape = [self imageLandscapeForKey:@"carousel.bgImage" inDictionary:APPCONFIG_MAINVIEW_DICT];
    
    config.initialBgImagePortrait = [self imagePortraitForKey:@"carousel.initialBgImage" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.initialBgImageLandscape = [self imageLandscapeForKey:@"carousel.initialBgImage" inDictionary:APPCONFIG_MAINVIEW_DICT];
    
    config.itemBgColor = [self colorForKey:@"carousel.item.bgColor" inDictionary:APPCONFIG_MAINVIEW_DICT];
    config.itemBorderColor = [self colorForKey:@"carousel.item.borderColor" inDictionary:APPCONFIG_MAINVIEW_DICT];
    
    config.defaultItemTitle = [self valueForKey:@"carousel.item.defaultItemTitle" inDictionary:APPCONFIG_MAINVIEW_DICT];
    
    // Set the type
    NSString *carouselType = [self valueForKey:@"carousel.type" inDictionary:APPCONFIG_MAINVIEW_DICT];
    
    if ([NSString isNotEmpty:carouselType]) {
        if ([carouselType isEqualToString:@"linear"]) {
            
        } else if ([carouselType isEqualToString:@"rotary"]) {
            config.carouselType = iCarouselTypeRotary;
        } else if ([carouselType isEqualToString:@"invertedrotary"]) {
            config.carouselType = iCarouselTypeInvertedRotary;
        } else if ([carouselType isEqualToString:@"cylinder"]) {
            config.carouselType = iCarouselTypeCylinder;
        } else if ([carouselType isEqualToString:@"invertedcylinder"]) {
            config.carouselType = iCarouselTypeInvertedCylinder;
        } else if ([carouselType isEqualToString:@"coverflow"]) {
            config.carouselType = iCarouselTypeCoverFlow;
        }
    } else {
        config.carouselType = iCarouselTypeRotary;
    }
    
    return config;
}

#pragma mark - SF APP Setup View Config
- (SFAppSetupConfig *)getAppSetupViewConfig {
    SFAppSetupConfig *config = [[SFAppSetupConfig alloc] init];
    
    config.bgColor = [self colorForKey:@"bgColor" inDictionary:APPCONFIG_APPSETUPCONFIG_DICT];
    config.buttonColor = [self colorForKey:@"button.bgColor" inDictionary:APPCONFIG_APPSETUPCONFIG_DICT];
    config.buttonTextColor = [self colorForKey:@"button.textColor" inDictionary:APPCONFIG_APPSETUPCONFIG_DICT];
    config.buttonTextFont = [self valueForKey:@"button.font" inDictionary:APPCONFIG_APPSETUPCONFIG_DICT];
    
    return config;
}

#pragma mark - SF App LoginView Config
- (SFLoginConfig *) getLoginViewConfig {
    SFLoginConfig* config = [[SFLoginConfig alloc] init];
    
    config.landscapeOnly = [self boolForKey:@"landscapeOnly" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    config.bgColor = [self colorForKey:@"bgColor" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    config.bgImageNamed = [self valueForKey:@"bgImage" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    config.textFieldBgColor = [self colorForKey:@"textfield.bgColor" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    config.textFieldFont = [self valueForKey:@"textfield.font" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    config.textFieldFontSize = [self numberForKey:@"textfield.fontSize" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    config.textFieldTextColor = [self colorForKey:@"textfield.textColor" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    config.requestLoginButtonImage = [self valueForKey:@"requestLoginButton.bgImage" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    config.loginButtonBgImage = [self valueForKey:@"loginButton.bgImage" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    config.textFieldRequestTextColor = [self colorForKey:@"requestLogin.textColor" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    config.helpEmailAddress = [self valueForKey:@"helpEmailAddress" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    config.helpEmailSubject = [self valueForKey:@"helpEmailSubject" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    config.helpEmailBody = [self valueForKey:@"helpEmailBody" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    config.helpAlertText = [self valueForKey:@"helpAlertText" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    config.helpTextColor = [self colorForKey:@"help.textColor" inDictionary:APPCONFIG_LOGINVIEW_DICT];
    
    return config;
}

#pragma mark - SF App Download Config
- (SFDownloadViewConfig *)getDownloadViewConfig {
    SFDownloadViewConfig *config = [[SFDownloadViewConfig alloc] init];
    
    config.landscapeOnly = [self boolForKey:@"landscapeOnly" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    config.bgColor = [self colorForKey:@"bgColor" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    config.bgImageNamed = [self valueForKey:@"bgImage" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    
    config.toggleViewFont = [self valueForKey:@"toggleView.font" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    config.toggleViewFontSize = [[self numberForKey:@"toggleView.fontSize" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT] floatValue];
    config.toggleViewTitleFont = [self valueForKey:@"toggleView.titleFont" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    config.toggleViewTitleFontSize = [[self numberForKey:@"toggleView.titleFontSize" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT] floatValue];
    
    config.toggleViewTextColor = [self colorForKey:@"toggleView.textColor" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    config.toggleViewBgColor = [self colorForKey:@"toggleView.bgColor" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    config.toggleViewToggleTintColor = [self colorForKey:@"toggleView.toggle.tintColor" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    config.doneButtonImageNamed = [self valueForKey:@"doneButton.bgImage" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    config.videoHeaderText = [self valueForKey:@"videoHeaderText" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    config.videoDetailText = [self valueForKey:@"videoDetailText" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    config.presentationHeaderText = [self valueForKey:@"presentationHeaderText" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    config.presentationDetailText = [self valueForKey:@"presentationDetailText" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    config.subTitleText = [self valueForKey:@"subTitleText" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    config.enableBigSyncByDefault = [self boolForKey:@"enableBigSyncByDefault" inDictionary:APPCONFIG_DOWNLOADCONFIG_DICT];
    
    return config;
}

#pragma mark - SF App Request Login Config
- (SFRequestLoginConfig *)getRequestLoginConfig {
    SFRequestLoginConfig *config = [[SFRequestLoginConfig alloc] init];
    
    config.landscapeOnly = [self boolForKey:@"landscapeOnly" inDictionary:APPCONFIG_REQUESTLOGIN_DICT];
    config.bgColor = [self colorForKey:@"bgColor" inDictionary:APPCONFIG_REQUESTLOGIN_DICT];
    config.bgImageNamed = [self valueForKey:@"bgImage" inDictionary:APPCONFIG_REQUESTLOGIN_DICT];
    config.selectViewBgColor = [self colorForKey:@"selectView.bgColor" inDictionary:APPCONFIG_REQUESTLOGIN_DICT];
    config.textFont = [self valueForKey:@"selectView.font" inDictionary:APPCONFIG_REQUESTLOGIN_DICT];
    config.textColor = [self colorForKey:@"selectView.textColor" inDictionary:APPCONFIG_REQUESTLOGIN_DICT];
    config.doneButtonImageNamed = [self valueForKey:@"doneButton.bgImage" inDictionary:APPCONFIG_REQUESTLOGIN_DICT];
    config.cancelButtonImageNamed = [self valueForKey:@"cancelButton.bgImage" inDictionary:APPCONFIG_REQUESTLOGIN_DICT];
    config.pickerViewBgColor = [self colorForKey:@"pickerView.bgColor" inDictionary:APPCONFIG_REQUESTLOGIN_DICT];
    config.regions = [self arrayForKey:@"regions" inDictionary:APPCONFIG_REQUESTLOGIN_DICT];
    config.requestSubjectFormatString = [self valueForKey:@"requestSubject" inDictionary:APPCONFIG_REQUESTLOGIN_DICT];
    config.requestAddresses = [self arrayForKey:@"requestAddresses" inDictionary:APPCONFIG_REQUESTLOGIN_DICT];
    config.requestBodies = [self arrayForKey:@"requestBodies" inDictionary:APPCONFIG_REQUESTLOGIN_DICT];
    
    return config;
}

#pragma mark - SF App Change Password View Config
- (SFChangePasswordConfig *)getChangePasswordConfig {
    SFChangePasswordConfig *config = [[SFChangePasswordConfig alloc] init];
    config.landscapeOnly = [self boolForKey:@"landscapeOnly" inDictionary:APPCONFIG_CHANGEPASSWORD_DICT];
    config.bgColor = [self colorForKey:@"bgColor" inDictionary:APPCONFIG_CHANGEPASSWORD_DICT];
    config.bgImageNamed = [self valueForKey:@"bgImage" inDictionary:APPCONFIG_CHANGEPASSWORD_DICT];
    config.labelFontName = [self valueForKey:@"label.font" inDictionary:APPCONFIG_CHANGEPASSWORD_DICT];
    config.labelTextColor = [self colorForKey:@"label.textColor" inDictionary:APPCONFIG_CHANGEPASSWORD_DICT];
    config.fieldBgColor = [self colorForKey:@"textField.bgColor" inDictionary:APPCONFIG_CHANGEPASSWORD_DICT];
    config.fieldTextColor = [self colorForKey:@"textField.textColor" inDictionary:APPCONFIG_CHANGEPASSWORD_DICT];
    config.fieldFontName = [self valueForKey:@"textField.font" inDictionary:APPCONFIG_CHANGEPASSWORD_DICT];
    config.doneButtonImageNamed = [self valueForKey:@"doneButton.image" inDictionary:APPCONFIG_CHANGEPASSWORD_DICT];
    config.cancelButtonImageNamed = [self valueForKey:@"cancelButton.image" inDictionary:APPCONFIG_CHANGEPASSWORD_DICT];
    
    return config;
}

#pragma mark - SF App SplashView Config
- (BOOL) getSplashViewControllerLandscapeOnly {
    return [[self valueForKey:@"landscapeOnly" inDictionary:APPCONFIG_SPLASHVIEW_DICT] boolValue];

}

- (NSString *) getSplashViewControllerType {
    return [self valueForKey:@"type" inDictionary:APPCONFIG_SPLASHVIEW_DICT];
}

#pragma mark - SF App Category Nav View Config
- (id) getCategoryNavViewController:(id<ContentViewBehavior>)path {
    NSString *value = [self valueForKey:@"type" inDictionary:APPCONFIG_CATVIEW_DICT];
    
    if ([NSString isNotEmpty:value]) {
        if ([value isEqualToString:@"basic"]) {
            return [[BasicCategoryViewController alloc] initWithCategoryPath:path];
        }
    }
    
    // By default return a Basic type implementation
    return [[BasicCategoryViewController alloc] initWithCategoryPath:path];
}

- (BOOL) getCategoryNavViewControllerLandscapeOnly {
   return [[self valueForKey:@"landscapeOnly" inDictionary:APPCONFIG_CATVIEW_DICT] boolValue];
}

- (BasicCategoryViewConfig *) getBasicCategoryViewConfig {
    BasicCategoryViewConfig *config = [[BasicCategoryViewConfig alloc] init];
    
    config.leftLogoNamed = [self valueForKey:@"basic.logoLeft" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.leftLogoLink = [self valueForKey:@"basic.logoLeftLink" inDictionary:APPCONFIG_CATVIEW_DICT];
    
    config.mainViewBgColor = [self colorForKey:@"basic.view.bgColor" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.mainViewPortBgColor = [self colorPortraitForKey:@"basic.view.bgColor" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.mainViewLandBgColor = [self colorLandscapeForKey:@"basic.view.bgColor" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.mainViewBgImageNamed = [self valueForKey:@"basic.view.bgImage" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.mainViewLandBgImageNamed = [self imageLandscapeForKey:@"basic.view.bgImage" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.mainViewPortBgImageNamed = [self imagePortraitForKey:@"basic.view.bgImage" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.displayCategoryTitle = [self boolForKey:@"basic.displayCategoryTitle" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.categoryTitleFontName = [self valueForKey:@"basic.categoryTitleFontName" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.categoryTitleFontSize = [self numberForKey:@"basic.categoryTitleFontSize" inDictionary:APPCONFIG_CATVIEW_DICT].floatValue;
    config.categoryTitleFontColor = [self colorForKey:@"basic.categoryTitleFontColor" inDictionary:APPCONFIG_CATVIEW_DICT];
    
    config.isReflectionOn = [self boolForKey:@"basic.thumbnail.reflectionOn" inDictionary:APPCONFIG_CATVIEW_DICT];
    
    config.thumbLabelTextColor = [self colorForKey:@"basic.thumbnail.label.textColor" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.thumbLabelBackgroundColor = [self colorForKey:@"basic.thumbnail.label.bgColor" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.thumbViewBackgroundColor = [self colorForKey:@"basic.thumbnail.bgColor" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.thumbHighlightBackgroundColor = [self colorForKey:@"basic.thumbnail.highlightColor" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.thumbImageBackgroundColor = [self colorForKey:@"basic.thumbnail.image.bgColor" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.thumbBorderColor = [self colorForKey:@"basic.thumbnail.borderColor" inDictionary:APPCONFIG_CATVIEW_DICT];
    
    config.thumbBgImageNamed = [self valueForKey:@"basic.thumbnail.bgImageNamed" inDictionary:APPCONFIG_CATVIEW_DICT];
    
    config.isRoundedCorners = [self boolForKey:@"basic.thumbnail.roundedCorners" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.isLabelAboveImage = [self boolForKey:@"basic.thumbnail.labelAboveImage" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.isLabelMultiLine = [self boolForKey:@"basic.thumbnail.labelMultiLine" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.thumbMargin = [self numberForKey:@"basic.thumbnail.margin" inDictionary:APPCONFIG_CATVIEW_DICT].floatValue;
    
    NSDictionary *dict = [self dictForKey:@"basic.thumbnail.scaleSize" inDictionary:APPCONFIG_CATVIEW_DICT];
    CGSize s;
    CGSizeMakeWithDictionaryRepresentation((CFDictionaryRef)dict, &s);
    config.thumbScaleSize = CGSizeMake(s.width, s.height);
    
    dict = [self dictForKey:@"basic.thumbnail.imageSize" inDictionary:APPCONFIG_CATVIEW_DICT];
    CGSizeMakeWithDictionaryRepresentation((CFDictionaryRef)dict, &s);
    config.thumbImageSize = CGSizeMake(s.width, s.height);
    
    dict = [self dictForKey:@"basic.thumbnail.reflectionSize" inDictionary:APPCONFIG_CATVIEW_DICT];
    CGSizeMakeWithDictionaryRepresentation((CFDictionaryRef)dict, &s);
    config.thumbReflectionSize = CGSizeMake(s.width, s.height);
    
    dict = [self dictForKey:@"basic.thumbnail.labelSize" inDictionary:APPCONFIG_CATVIEW_DICT];
    CGSizeMakeWithDictionaryRepresentation((CFDictionaryRef)dict, &s);
    config.thumbLabelSize = CGSizeMake(s.width, s.height);
    
    dict = [self dictForKey:@"basic.thumbnail.thumbSize" inDictionary:APPCONFIG_CATVIEW_DICT];
    CGSizeMakeWithDictionaryRepresentation((CFDictionaryRef)dict, &s);
    config.thumbSize = CGSizeMake(s.width, s.height);
    
    config.isLabelBackgroundGradient = [self boolForKey:@"basic.thumbnail.labelBackgroundGradient" inDictionary:APPCONFIG_CATVIEW_DICT];
    
    config.thumbLabelFontName = [self valueForKey:@"basic.thumbnail.labelFontName" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.thumbLabelFontSize = [self numberForKey:@"basic.thumbnail.labelFontSize" inDictionary:APPCONFIG_CATVIEW_DICT].floatValue;
    
    config.isLabelAllCaps = [self boolForKey:@"basic.thumbnail.labelAllCaps" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.isLabelShadow = [self boolForKey:@"basic.thumbnail.labelShadow" inDictionary:APPCONFIG_CATVIEW_DICT];
    dict = [self dictForKey:@"basic.thumbnail.labelShadowSize" inDictionary:APPCONFIG_CATVIEW_DICT];
    CGSizeMakeWithDictionaryRepresentation((CFDictionaryRef)dict, &s);
    config.thumbLabelShadowSize = CGSizeMake(s.width, s.height);
    
    config.thumbLabelShadowColor = [self colorForKey:@"basic.thumbnail.labelShadowColor" inDictionary:APPCONFIG_CATVIEW_DICT];
    
    config.thumbsPerPagePortrait = [self numberForKey:@"basic.thumbnail.numPerPagePortrait" inDictionary:APPCONFIG_CATVIEW_DICT].integerValue;
    config.thumbsPerPageLandscape = [self numberForKey:@"basic.thumbnail.numPerPageLandscape" inDictionary:APPCONFIG_CATVIEW_DICT].integerValue;
    
    config.pageControlActiveColor = [self colorForKey:@"basic.pagecontrol.activeColor" inDictionary:APPCONFIG_CATVIEW_DICT];
    config.pageControlInactiveColor = [self colorForKey:@"basic.pagecontrol.inactiveColor" inDictionary:APPCONFIG_CATVIEW_DICT];
    
    return config;
}

#pragma mark - SF App Portfolio Detail View Config
- (id) getPortfolioDetailViewController:(id<ContentViewBehavior>)path {
    NSString *value = [self valueForKey:@"type" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    if ([NSString isNotEmpty:value]) {
        if ([value isEqualToString:@"basic"]) {
            return [[BasicPortfolioDetailViewController alloc] initWithContentProduct:path];
        } else if ([value isEqualToString:@"tabbed"]) {
            return [[TabbedDetailViewController alloc] initWithContentProduct:path];
        }
    }
    
    // By default return a Basic type implementation
    return [[BasicPortfolioDetailViewController alloc] initWithContentProduct:path];

}

- (id)getPortfolioGalleryViewController:(id<ContentViewBehavior>)path {
    // We only have one type of Gallery layout right now.
    return [[GalleryDetailViewController alloc] initWithContentGallery:path];
}

- (BOOL) getPortfolioDetailViewControllerLandscapeOnly {
    return [[self valueForKey:@"landscapeOnly" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT] boolValue];
}

- (BasicPortfolioDetailViewConfig *) getBasicPortfolioDetailViewConfig {
    BasicPortfolioDetailViewConfig *config = [[BasicPortfolioDetailViewConfig alloc] init];
    
    config.leftLogoNamed = [self valueForKey:@"basic.logoLeft" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.leftLogoLink = [self valueForKey:@"basic.logoLeftLink" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainBgColor = [self colorForKey:@"basic.view.bgColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainPortBgColor = [self colorPortraitForKey:@"basic.view.bgColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainLandBgColor = [self colorLandscapeForKey:@"basic.view.bgColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    config.featuresViewBorderColor = [self colorForKey:@"basic.featureview.borderColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewDetailLabelBgColor = [self colorForKey:@"basic.featureview.label.product.bgColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewDetailLabelTextColor = [self colorForKey:@"basic.featureview.label.product.textColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewBenefitLabelBgColor = [self colorForKey:@"basic.featuresview.label.benefits.bgColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewBenefitLabelTextColor = [self colorForKey:@"basic.featuresview.label.benefits.textColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    config.isFeaturesLabelHidden = [self boolForKey:@"basic.features.doHide" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.isBenefitsLabelHidden = [self boolForKey:@"basic.benefits.doHide" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    return config;
}

- (TabbedPortfolioDetailViewConfig *) getTabbedPortfolioDetailViewConfig {
    TabbedPortfolioDetailViewConfig *config = [[TabbedPortfolioDetailViewConfig alloc] init];
    
    config.leftLogoNamed = [self valueForKey:@"basic.logoLeft" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.leftLogoLink = [self valueForKey:@"basic.logoLeftLink" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mailTemplate = [self valueForKey:@"mail.template" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mailRecipient = [self valueForKey:@"mail.recipient" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mailSubjectTemplate = [self valueForKey:@"mail.subjectTemplate" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mailResourceGroup = [self valueForKey:@"mail.resourceGroup" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    config.mainBgColor = [self colorForKey:@"tabbed.view.bgColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainPortBgColor = [self colorForKey:@"tabbed.view.portrait.bgColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainLandBgColor = [self colorForKey:@"tabbed.view.landscape.bgColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainBgImageNamed = [self valueForKey:@"tabbed.view.bgImage" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    // Product Title
    config.mainTitleFont = [self valueForKey:@"tabbed.view.title.font" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainTitleFontColor = [self colorForKey:@"tabbed.view.title.textColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainTitleFontSize = [[self numberForKey:@"tabbed.view.title.fontSize" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT] floatValue];
    
    // Product Info Text
    config.mainInfoTextFont = [self valueForKey:@"tabbed.view.infotext.font" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainInfoTextFontColor = [self colorForKey:@"tabbed.view.infotext.textColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainInfoTextFontSize = [[self numberForKey:@"tabbed.view.infotext.fontSize" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT] floatValue];
    config.mainInfoTextVerticalAlignment = [self contentModeForKey:@"tabbed.view.infotext.verticalAlignment" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainInfoTextHorizontalAlignment = [self textAlignmentForKey:@"tabbed.view.infotext.horizontalAlignment" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    // Bottom bar image
    config.mainBottomBarImageNamed = [self valueForKey:@"tabbed.view.bottombar.image" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    config.onlineCatalogButtonFont = [self valueForKey:@"tabbed.onlinecatalogbutton.font" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.onlineCatalogButtonTextColor = [self colorForKey:@"tabbed.onlinecatalogbutton.textColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.onlineCatalogButtonShadowColor = [self colorForKey:@"tabbed.onlinecatalogbutton.shadowColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.onlineCatalogButtonImageNamed = [self valueForKey:@"tabbed.onlinecatalogbutton.bgImage" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.onlineCatalogButtonTitle = [self valueForKey:@"tabbed.onlinecatalogbutton.title" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.onlineCatalogButtonResourceGroup = [self valueForKey:@"tabbed.onlinecatalogbutton.resourceGroup" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    config.categoryShortcutButtonEnabled = [[self valueForKey:@"tabbed.categoryshortcutbutton.enabled" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT] boolValue];
    config.categoryShortcutButtonFont = [self valueForKey:@"tabbed.categoryshortcutbutton.font" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.categoryShortcutButtonTextColor = [self colorForKey:@"tabbed.categoryshortcutbutton.textColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.categoryShortcutButtonShadowColor = [self colorForKey:@"tabbed.categoryshortcutbutton.shadowColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.categoryShortcutButtonImageNamed = [self valueForKey:@"tabbed.categoryshortcutbutton.bgImage" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.categoryShortcutButtonTitle = [self valueForKey:@"tabbed.categoryshortcutbutton.title" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.categoryShortcutButtonCategory = [self valueForKey:@"tabbed.categoryshortcutbutton.category" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    config.externalApplicationButtonEnabled = [self boolForKey:@"tabbed.externalapplicationbutton.enabled" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.externalApplicationButtonFont = [self valueForKey:@"tabbed.externalapplicationbutton.font" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.externalApplicationButtonTextColor = [self colorForKey:@"tabbed.externalapplicationbutton.textColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.externalApplicationButtonShadowColor = [self colorForKey:@"tabbed.externalapplicationbutton.shadowColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.externalApplicationButtonImageNamed = [self valueForKey:@"tabbed.externalapplicationbutton.bgImage" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.externalApplicationButtonTitle = [self valueForKey:@"tabbed.externalapplicationbutton.title" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.externalApplicationButtonAppCheckUrl = [self valueForKey:@"tabbed.externalapplicationbutton.appCheckUrl" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.externalApplicationButtonAppOpenUrl = [self valueForKey:@"tabbed.externalapplicationbutton.appOpenUrl" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    config.featuresViewBgImageNamed = [self valueForKey:@"tabbed.featuresview.bgImage" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewBgColor = [self colorForKey:@"tabbed.featuresview.bgColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewBorderColor = [self colorForKey:@"tabbed.featuresview.borderColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewTextColor = [self colorForKey:@"tabbed.featuresview.textColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    config.featuresViewTabLabelFont = [self valueForKey:@"tabbed.featuresview.tab.font" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewTabLabelFontSize = [[self numberForKey:@"tabbed.featuresview.tab.fontSize" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT] floatValue];
    config.featuresViewTabLabelVerticalAlignment = [self contentModeForKey:@"tabbed.featuresview.tab.verticalAlignment" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresviewTabLabelHorizontalAlignment = [self textAlignmentForKey:@"tabbed.featuresview.tab.horizontalAlignment" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    config.featuresViewResourceTextFont = [self valueForKey:@"tabbed.featuresview.resource.font" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewResourceTextFontSize = [[self numberForKey:@"tabbed.featuresview.resource.fontSize" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT] floatValue];
    
    config.featuresViewActiveTabLabelBgColor = [self colorForKey:@"tabbed.featuresview.tab.active.bgColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewActiveTabLabelShadowColor = [self colorForKey:@"tabbed.featuresview.tab.active.shadowColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewActiveTabLabelImageNamed = [self valueForKey:@"tabbed.featuresview.tab.active.bgImage" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewActiveTabLabelTextColor = [self colorForKey:@"tabbed.featuresview.tab.active.textColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    config.featuresViewInactiveTabLabelBgColor = [self colorForKey:@"tabbed.featuresview.tab.inactive.bgColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewInactiveTabLabelShadowColor = [self colorForKey:@"tabbed.featuresview.tab.inactive.shadowColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewInactiveTabLabelImageNamed = [self valueForKey:@"tabbed.featuresview.tab.inactive.bgImage" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.featuresViewInactiveTabLabelTextColor = [self colorForKey:@"tabbed.featuresview.tab.inactive.textColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    config.includedResourceGroup = [self valueForKey:@"tabbed.featuresview.resourceGroup" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    return config;
}

- (PortfolioDetailVideoControllerConfig *) getPortfolioDetailVideoControllerConfig {
    PortfolioDetailVideoControllerConfig *config = [[PortfolioDetailVideoControllerConfig alloc] init];
    
    config.leftLogoNamed = [self valueForKey:@"video.view.logoLeft" inDictionary:APPCONFIG_PORTFOLIO_VIDEOVIEW_DICT];
    config.leftLogoLink = [self valueForKey:@"video.view.logoLeftLink" inDictionary:APPCONFIG_PORTFOLIO_VIDEOVIEW_DICT];
    config.mainBgImageNamed = [self valueForKey:@"video.view.bgImage" inDictionary:APPCONFIG_PORTFOLIO_VIDEOVIEW_DICT];
    config.mainBgColor = [self colorForKey:@"video.view.bgColor" inDictionary:APPCONFIG_PORTFOLIO_VIDEOVIEW_DICT];
    config.mainTitleFont = [self valueForKey:@"video.view.font" inDictionary:APPCONFIG_PORTFOLIO_VIDEOVIEW_DICT];
    config.mainTitleFontColor = [self colorForKey:@"video.view.textColor" inDictionary:APPCONFIG_PORTFOLIO_VIDEOVIEW_DICT];
    config.mainBottomBarImageNamed = [self valueForKey:@"video.view.bottombar.image" inDictionary:APPCONFIG_PORTFOLIO_VIDEOVIEW_DICT];
    
    config.activeBgColor = [self colorForKey:@"video.activeview.bgColor" inDictionary:APPCONFIG_PORTFOLIO_VIDEOVIEW_DICT];
    config.inactiveBgColor = [self colorForKey:@"video.inactiveview.bgColor" inDictionary:APPCONFIG_PORTFOLIO_VIDEOVIEW_DICT];
    
    config.videoTopCategoryNamed = [self valueForKey:@"video.view.parentcategory.name" inDictionary:APPCONFIG_PORTFOLIO_VIDEOVIEW_DICT];
    
    config.numThumbsPortrait = [self numberForKey:@"video.view.thumbsPerPagePortrait" inDictionary:APPCONFIG_PORTFOLIO_VIDEOVIEW_DICT].integerValue;
    config.numThumbsLandscape = [self numberForKey:@"video.view.thumbsPerPageLandscape" inDictionary:APPCONFIG_PORTFOLIO_VIDEOVIEW_DICT].integerValue;
    
    return config;
}

- (ProductPhotoViewConfig *) getProductPhotoViewConfig {
    ProductPhotoViewConfig *config = [[ProductPhotoViewConfig alloc] init];
    
    config.doShowTabs = [[self valueForKey:@"showTabs" inDictionary:APPCONFIG_PORTFOLIO_PHOTOVIEW_DICT] boolValue];
    config.borderColor = [self colorForKey:@"borderColor" inDictionary:APPCONFIG_PORTFOLIO_PHOTOVIEW_DICT];
    config.tabReturnTextColor = [self colorForKey:@"tab.return.textColor" inDictionary:APPCONFIG_PORTFOLIO_PHOTOVIEW_DICT];
    config.tabProductTextColor = [self colorForKey:@"tab.product.textColor" inDictionary:APPCONFIG_PORTFOLIO_PHOTOVIEW_DICT];
    
    return config;
}

- (ResourcePreviewConfig *) getPortfolioResourcePreviewConfig {
    ResourcePreviewConfig *config = [[ResourcePreviewConfig alloc] init];
    
    config.usesTitleOverlay = [[self valueForKey:@"overlay.showTitleOverlay" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT] boolValue];
    config.titleColor = [self colorForKey:@"overlay.titleColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.titleFont = [self fontForName:@"overlay.font" size:@"overlay.fontSize" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.overlayColor = [self colorForKey:@"overlay.titleBgColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.overlayImageForColor = [self valueForKey:@"overlay.titleBgImageForColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    
    config.previewMainBgColor = [self colorForKey:@"main.bgColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.previewContentBgColor = [self colorForKey:@"content.bgColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.previewContentImageBgColor = [self colorForKey:@"content.img.bgColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.previewContentPdfBgColor = [self colorForKey:@"content.pdf.bgColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    
    config.docStripBorderColor = [self colorForKey:@"docstrip.borderColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.docStripTabBgColor = [self colorForKey:@"docstrip.tab.bgColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.docStripTabTextColor = [self colorForKey:@"docstrip.tab.textColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.docStripBgImageNamed = [self valueForKey:@"docstrip.bgImage" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    
    config.previewThumbHighlightBgColor = [self colorForKey:@"thumb.highlight.bgColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.previewThumbBgColor = [self colorForKey:@"thumb.bgColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.previewThumbNoPreviewBgColor = [self colorForKey:@"thumb.nopreview.bgColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.previewThumbNoPreviewTextColor = [self colorForKey:@"thumb.nopreview.textColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.previewThumbLabelBgColor = [self colorForKey:@"thumb.label.bgColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.previewThumbLabelBorderColor = [self colorForKey:@"thumb.label.borderColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.previewThumbLabelTextColor = [self colorForKey:@"thumb.label.textColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    config.previewThumbLabelFontSize = [[self valueForKey:@"thumb.label.tfontSize" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT] floatValue];
    config.previewThumbnailLabelMaxLength = [[self valueForKey:@"thumb.label.maxLength" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT] integerValue];
    
    return config;
}

- (ResourceButtonMenuConfig *) getPortfolioResourceButtonMenuConfig {
    ResourceButtonMenuConfig *config = [[ResourceButtonMenuConfig alloc] init];
    
    config.title = [self valueForKey:@"title.text" inDictionary:APPCONFIG_PORTFOLIO_RESOURCEMENU_DICT];
    config.titleTextColor = [self colorForKey:@"title.textColor" inDictionary:APPCONFIG_PORTFOLIO_RESOURCEMENU_DICT];
    config.titleBackgroundColor = [self colorForKey:@"title.BgColor" inDictionary:APPCONFIG_PORTFOLIO_RESOURCEMENU_DICT];
    config.titleBorderColor = [self colorForKey:@"titleBorderColor" inDictionary:APPCONFIG_PORTFOLIO_RESOURCEMENU_DICT];
    
    return config;
}

- (ResourceButtonConfig *) getPortfolioResourceButtonConfig:(id<ContentViewBehavior>)resourceGroup {
    ResourceButtonConfig *config = [[ResourceButtonConfig alloc] initWith:resourceGroup];
    
    config.normalStateImage = [UIImage contentFoundationResourceImageNamed:[self valueForKey:@"btn.image" inDictionary:APPCONFIG_PORTFOLIO_RESOURCEMENU_DICT]];
    config.selectedStateImage = [UIImage contentFoundationResourceImageNamed:[self valueForKey:@"btn.selectedImage" inDictionary:APPCONFIG_PORTFOLIO_RESOURCEMENU_DICT]];
    config.disableButtonColor = [self colorForKey:@"btn.disabledColor" inDictionary:APPCONFIG_PORTFOLIO_RESOURCEMENU_DICT];
    config.enableButtonColor = [self colorForKey:@"btn.enabledColor" inDictionary:APPCONFIG_PORTFOLIO_RESOURCEMENU_DICT];
    
    return config;
}

- (PdfViewControllerConfig *)getPdfViewControllerConfig {
    PdfViewControllerConfig *config = [[PdfViewControllerConfig alloc] init];
    config.autoFadeToolbar = [[self valueForKey:@"toolbar.autofade" inDictionary:APPCONFIG_DOCVIEWER_DICT] boolValue];
    return config;
}

- (ResourceTabConfig *) getResourceTabConfig:(id<ContentViewBehavior>)contentItem {
    ResourceTabConfig *config = [[ResourceTabConfig alloc] initWith:contentItem
                                                              normalStateImage:[UIImage contentFoundationResourceImageNamed:[self valueForKey:@"unselected.bgImage" inDictionary:APPCONFIG_PORTFOLIO_RESOURCETAB_DICT]]
                                                            selectedStateImage:[UIImage contentFoundationResourceImageNamed:[self valueForKey:@"selected.bgImage" inDictionary:APPCONFIG_PORTFOLIO_RESOURCETAB_DICT]]
                                                          titleFont:[UIFont fontWithName:[self valueForKey:@"title.font" inDictionary:APPCONFIG_PORTFOLIO_RESOURCETAB_DICT] size:[[self numberForKey:@"title.fontSize" inDictionary:APPCONFIG_PORTFOLIO_RESOURCETAB_DICT] floatValue]]
                                                              titleShadowColor:[self colorForKey:@"title.shadowColor" inDictionary:APPCONFIG_PORTFOLIO_RESOURCETAB_DICT]
                                                                       tabSize:CGSizeMake(129, 30)
                                                                    tabSpacing:6.0f
                                                               titleShadowSize:CGSizeMake(1, 1)
                                                                    titleColor:[self colorForKey:@"title.textColor" inDictionary:APPCONFIG_PORTFOLIO_RESOURCETAB_DICT]];
    
    config.titleSelectedFontColor = [self colorForKey:@"title.selectedTextColor" inDictionary:APPCONFIG_PORTFOLIO_RESOURCETAB_DICT];
    config.verticalAlignment = [self contentModeForKey:@"title.verticalAlignment" inDictionary:APPCONFIG_PORTFOLIO_RESOURCETAB_DICT];
    config.horizontalAlignment = [self textAlignmentForKey:@"title.horizontalAlignment" inDictionary:APPCONFIG_PORTFOLIO_RESOURCETAB_DICT];
    return config;
}

- (NSInteger) getPortfolioPreviewMoviePlayerStyle {
    NSString *moviePlayerString = [self valueForKey:@"movie.playerStyle" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
    
    NSInteger style = MPMovieControlStyleDefault;
    
    if ([[moviePlayerString uppercaseString] isEqualToString:[@"MPMovieControlStyleNone" uppercaseString]]) {
        style = MPMovieControlStyleNone;
    }
    else if ([[moviePlayerString uppercaseString] isEqualToString:[@"MPMovieControlStyleEmbedded" uppercaseString]]){
        style = MPMovieControlStyleEmbedded;
    }
    else if ([[moviePlayerString uppercaseString] isEqualToString:[@"MPMovieControlStyleFullscreen" uppercaseString]]){
        style = MPMovieControlStyleFullscreen;
    }
    
    return style;
}

- (UIColor *) getPortfolioPreviewToolbarTintColor {
    return [self colorForKey:@"toolbar.tintColor" inDictionary:APPCONFIG_PORTFOLIO_PREVIEW_DICT];
}

- (BOOL) allowPreviewForResourceItem:(NSURL *)resourceUrl {
    NSString *resourceSuffix = [[resourceUrl absoluteString] pathExtension];
    
    NSDictionary *disablePreviewDict = (NSDictionary *) [((NSDictionary *) [appConfigDict objectForKey:APPCONFIG_PORTFOLIO_PREVIEW_DICT]) objectForKey:@"disablePreviewForTypes"];
    
    if (disablePreviewDict && [disablePreviewDict objectForKey:resourceSuffix]) {
        return NO;
    }
    return YES;
}

#pragma mark - Gallery Detail View Config
- (GalleryDetailViewControllerConfig *) getGalleryDetailViewConfig {
    GalleryDetailViewControllerConfig *config = [[GalleryDetailViewControllerConfig alloc] init];
    
    config.leftLogoNamed = [self valueForKey:@"basic.logoLeft" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.leftLogoLink = [self valueForKey:@"basic.logoLeftLink" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mailTemplate = [self valueForKey:@"mail.template" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mailRecipient = [self valueForKey:@"mail.recipient" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mailSubjectTemplate = [self valueForKey:@"mail.subjectTemplate" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mailResourceGroup = [self valueForKey:@"mail.resourceGroup" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    config.mainBgColor = [self colorForKey:@"tabbed.view.bgColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainPortBgColor = [self colorForKey:@"tabbed.view.portrait.bgColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainLandBgColor = [self colorForKey:@"tabbed.view.landscape.bgColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainBgImageNamed = [self valueForKey:@"tabbed.view.bgImage" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    // Product Title
    config.mainTitleFont = [self valueForKey:@"tabbed.view.title.font" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainTitleFontColor = [self colorForKey:@"tabbed.view.title.textColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainTitleFontSize = [[self numberForKey:@"tabbed.view.title.fontSize" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT] floatValue];
    
    // Product Info Text
    config.mainInfoTextFont = [self valueForKey:@"tabbed.view.infotext.font" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainInfoTextFontColor = [self colorForKey:@"tabbed.view.infotext.textColor" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainInfoTextFontSize = [[self numberForKey:@"tabbed.view.infotext.fontSize" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT] floatValue];
    config.mainInfoTextVerticalAlignment = [self contentModeForKey:@"tabbed.view.infotext.verticalAlignment" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    config.mainInfoTextHorizontalAlignment = [self textAlignmentForKey:@"tabbed.view.infotext.horizontalAlignment" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    // Bottom bar image
    config.mainBottomBarImageNamed = [self valueForKey:@"tabbed.view.bottombar.image" inDictionary:APPCONFIG_PORTFOLIO_MAINVIEW_DICT];
    
    return config;
    
}

#pragma mark - SF App Content Configuration
- (ContentSyncConfig *) getContentSyncConfig {
    // Setup Content Sync Parameters
    ContentSyncConfig *syncConfig = [[ContentSyncConfig alloc] init];
    
    syncConfig.contentMetaDataUrl = [self getContentMetadataUrl];
    syncConfig.contentStructureUrl = [self getContentStructureUrl];
    syncConfig.isStructureEnabled = [self isContentStructureSyncEnabled];
    
    syncConfig.bundledContentZipFile = [self getBundledContentZip];
    syncConfig.localContentRoot = [self getLocalContentRoot];
    syncConfig.localSyncRoot = [self getLocalSyncRoot];
    syncConfig.localContentDocPath = [self getLocalContentDocPath];
    syncConfig.alertTitle = [self getAppAlertTitle];
    
    syncConfig.jsonAuthRequired = [self isAuthRequiredForJSON];
    syncConfig.downloadFilteringEnabled = [self isDownloadFilteringEnabled];
    syncConfig.videoFilteringEnabled = [self isVideoFilteringEnabled];
    syncConfig.presentationFilteringEnabled = [self isPresentationFilteringEnabled];
    
    return syncConfig;
}

- (NSURL *) getUserCheckUrl {
    NSString *dictKey = APPCONFIG_CONTENT_DICT;
    NSString *append = [self valueForKey:@"checkUserUri" inDictionary:dictKey];
    
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:@"sf.app.settings.cmsBaseUrl"];
    
    if (value && append) {
        NSString *url = [self tidyUrlString:[value stringByAppendingString:append]];
        return [NSURL URLWithString:url];
    }
    
    return nil;
}

- (NSURL *) getContentMetadataUrl {
    NSString *dictKey = APPCONFIG_CONTENT_DICT;
    NSString *append = [self valueForKey:@"metadataUri" inDictionary:dictKey];
    
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:@"sf.app.settings.cmsBaseUrl"];
    
    if (value && append) {
        NSString *url = [self tidyUrlString:[value stringByAppendingString:append]];
        return [NSURL URLWithString:url];
    }
    
    return nil;
}

- (NSURL *) getContentStructureUrl {
    NSString *dictKey = APPCONFIG_CONTENT_DICT;
    NSString *append = [self valueForKey:@"structureUri" inDictionary:dictKey];
    
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:@"sf.app.settings.cmsBaseUrl"];
    
    if (value && append) {
        NSString *url = [self tidyUrlString:[value stringByAppendingString:append]];
        return [NSURL URLWithString:url];
    }
    
    return nil;
}

- (BOOL) isContentStructureSyncEnabled {
    NSString *dictKey = APPCONFIG_CONTENT_DICT;
    BOOL isEnabled = [[((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:@"structureEnabled"] boolValue];
    
    return isEnabled;
}

- (BOOL) isAuthRequiredForJSON {
    NSString *dictKey = APPCONFIG_CONTENT_DICT;
    BOOL isAuthRequired = [[((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:@"jsonAuthRequired"] boolValue];
    return isAuthRequired;
}

- (BOOL) isAuthRememberLoginEnabled {
    NSString *dictKey = APPCONFIG_CONTENT_DICT;
    
    BOOL isRememberLoginEnabled = NO;
    id authRememberLogin = [((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:@"authRememberLogin"];
    
    if (authRememberLogin) {
        isRememberLoginEnabled = [authRememberLogin boolValue];
    }
    
    return isRememberLoginEnabled;
}

- (BOOL) isDownloadFilteringEnabled {
    NSString *dictKey = APPCONFIG_CONTENT_DICT;
    BOOL isEnabled = [[((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:@"downloadFilteringEnabled"] boolValue];
    return isEnabled;
}

- (BOOL) isVideoFilteringEnabled {
    NSString *dictKey = APPCONFIG_CONTENT_DICT;
    BOOL isEnabled = [[((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:@"videoFilteringEnabled"] boolValue];
    return isEnabled;
}

- (BOOL) isPresentationFilteringEnabled {
    NSString *dictKey = APPCONFIG_CONTENT_DICT;
    BOOL isEnabled = [[((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:@"presentationFilteringEnabled"] boolValue];
    return isEnabled;
}

- (NSString *) getLocalContentRoot {
    NSString *value = [self valueForKey:@"local.contentRoot" inDictionary:APPCONFIG_CONTENT_DICT];
    return value;
}
- (NSString *) getLocalContentDocPath {
    NSString *value = [self valueForKey:@"local.contentDocPath" inDictionary:APPCONFIG_CONTENT_DICT];
    return value;
}
- (NSString *) getLocalContentSymlinkRef {
    NSString *value = [self valueForKey:@"local.contentSymlinkLookup" inDictionary:APPCONFIG_CONTENT_DICT];
    return value;
}
- (NSString *) getLocalContentResourcePath {
    NSString *value = [self valueForKey:@"local.contentResourcePath" inDictionary:APPCONFIG_CONTENT_DICT];
    return value;
}
- (BOOL) doIgnoreLocalPath:(NSString *) path {
    NSDictionary *ignoreDirDict = (NSDictionary *) [((NSDictionary *) [appConfigDict objectForKey:APPCONFIG_CONTENT_DICT]) objectForKey:@"local.contentIgnoreDirs"];
    
    if (ignoreDirDict && [ignoreDirDict objectForKey:path]) {
        return YES;
    }
    return NO;
}
- (NSString *) getLocalSyncRoot {
    NSString *value = [self valueForKey:@"local.syncRoot" inDictionary:APPCONFIG_CONTENT_DICT];
    return value;
}
- (BOOL) doWordifyLabel {
    NSString *wl = [self valueForKey:@"local.content.wordifyLabels" inDictionary:APPCONFIG_CONTENT_DICT];
    return [wl boolValue];
}

- (NSArray *) getExcludedResources {
    NSArray *value = (NSArray *) [((NSDictionary *) [appConfigDict objectForKey:APPCONFIG_PORTFOLIO_PREVIEW_DICT]) objectForKey:@"excludeGroupsForPreview"];
    return value;
}

- (NSString *) getBundledContentZip {
    NSString *value = [self valueForKey:@"bundle.contentZip" inDictionary:APPCONFIG_CONTENT_DICT];
    return value;
}

#pragma mark - SF App Company Web  and HTML Info View Config
- (CompanyWebViewConfig *) getCompanyWebViewConfig {
    
    CompanyWebViewConfig *config = [[CompanyWebViewConfig alloc] init];
    
    config.toolbarTintColor = [self colorForKey:@"toolbar.tintColor" inDictionary:APPCONFIG_WEBVIEW_DICT];
    config.bgColor = [self colorForKey:@"bgColor" inDictionary:APPCONFIG_WEBVIEW_DICT];
    
    return config;
}

- (CompanyInfoHtmlViewConfig *) getCompanyInfoHtmlViewConfig {
    CompanyInfoHtmlViewConfig *config = [[CompanyInfoHtmlViewConfig alloc] init];
    
    config.logoLeft = [self valueForKey:@"logoLeft" inDictionary:APPCONFIG_INFOHTMLVIEW_DICT];
    config.logoRight = [self valueForKey:@"logoRight" inDictionary:APPCONFIG_INFOHTMLVIEW_DICT];
    config.leftLogoLink = [self valueForKey:@"logoLeftLink" inDictionary:APPCONFIG_INFOHTMLVIEW_DICT];
    config.rightLogoLink = [self valueForKey:@"logoRightLink" inDictionary:APPCONFIG_INFOHTMLVIEW_DICT];
    config.bgColor = [self colorForKey:@"bgColor" inDictionary:APPCONFIG_INFOHTMLVIEW_DICT];
    config.textColor = [self colorForKey:@"textColor" inDictionary:APPCONFIG_INFOHTMLVIEW_DICT];
    
    return config;
}

#pragma mark - SF App Toolbar Configs
- (ContentInfoToolbarConfig *) getContentInfoToolbarConfig {
    // SMM: This config handles the plain ContentInfoToolbar and the ContentInfoInsetToolbar.  Subclassing for
    // a config file seemed excessive.
    
    ContentInfoToolbarConfig *config = [[ContentInfoToolbarConfig alloc] init];
    
    config.type = [self valueForKey:@"type" inDictionary:APPCONFIG_TOOLBAR_NAV_DICT];
    if (!config.type) {
        config.type = @"basic";
    }
    config.homeBtnImageNamed = [self valueForKey:@"homeButtonIcon" inDictionary:APPCONFIG_TOOLBAR_NAV_DICT];
    config.backBtnImageNamed = [self valueForKey:@"backButtonIcon" inDictionary:APPCONFIG_TOOLBAR_NAV_DICT];
    config.bookmarkBtnImageNamed = [self valueForKey:@"bookmarkButtonIcon" inDictionary:APPCONFIG_TOOLBAR_NAV_DICT];
    config.webBtnImageNamed = [self valueForKey:@"webLinkButtonIcon" inDictionary:APPCONFIG_TOOLBAR_NAV_DICT];
    config.webBtnLink = [self valueForKey:@"webLinkUrl" inDictionary:APPCONFIG_TOOLBAR_NAV_DICT];
    config.searchBtnImageNamed = [self valueForKey:@"searchButtonIcon" inDictionary:APPCONFIG_TOOLBAR_NAV_DICT];
    config.sketchBtnImageNamed = [self valueForKey:@"sketchButtonIcon" inDictionary:APPCONFIG_TOOLBAR_NAV_DICT];
    config.refreshBtnImageNamed = [self valueForKey:@"refreshButtonIcon" inDictionary:APPCONFIG_TOOLBAR_NAV_DICT];
    config.setupBtnImageNamed = [self valueForKey:@"setupButtonIcon" inDictionary:APPCONFIG_TOOLBAR_NAV_DICT];
    
    // ContentInfoInsetToolbar specific.
    config.centerBgImageNamed = [self valueForKey:@"centerBgImage" inDictionary:APPCONFIG_TOOLBAR_NAV_DICT];
    config.leftInsetBgImageNamed = [self valueForKey:@"leftInsetBgImage" inDictionary:APPCONFIG_TOOLBAR_NAV_DICT];
    config.rightInsetBgImageNamed = [self valueForKey:@"rightInsetBgImage" inDictionary:APPCONFIG_TOOLBAR_NAV_DICT];
    
    return config;
}

#pragma mark - Sketch View Config
- (UIColor *) getSketchViewTintColor {
    UIColor *tintColor = [self colorForKey:@"toolbar.tintColor" inDictionary:APPCONFIG_SKETCHVIEW_DICT];
    
    return tintColor;
}

- (UIColor *) getSketchViewBgColor {
    UIColor *color = [self colorForKey:@"bgColor" inDictionary:APPCONFIG_SKETCHVIEW_DICT];
    
    return color;
}

#pragma mark - Private Methods
- (NSString *) tidyUrlString:(NSString *) urlString {
    if (urlString) {
        NSString *tidyUrl = urlString;
        
        // Strip http:// to start
        NSRange httpRange = [tidyUrl rangeOfString:@"http://"];
        NSRange httpsRange = [tidyUrl rangeOfString:@"https://"];
        
        if (NSNotFound != httpRange.location) {
            tidyUrl = [tidyUrl substringFromIndex:httpRange.location + httpRange.length];
            // Make sure there is no // in the URL
            tidyUrl = [tidyUrl stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
            
            // append http:// back to beginning
            tidyUrl = [@"http://" stringByAppendingString:tidyUrl];
        } else if (NSNotFound != httpsRange.location) {
            tidyUrl = [tidyUrl substringFromIndex:httpsRange.location + httpsRange.length];
            // Make sure there is no // in the URL
            tidyUrl = [tidyUrl stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
            
            // append http:// back to beginning
            tidyUrl = [@"https://" stringByAppendingString:tidyUrl];
        }
        
        return tidyUrl;
    }
    
    return urlString;
}

- (NSNumber *) numberForKey:(NSString *)key inDictionary:(NSString *)dictKey {
    NSNumber *num = (NSNumber *)[((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:key];
    return num;
}

- (NSDictionary *) dictForKey:(NSString *)key inDictionary:(NSString *)dictKey {
    NSDictionary *dict = (NSDictionary *)[((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:key];
    return dict;
}

- (NSArray *) arrayForKey:(NSString *)key inDictionary:(NSString *)dictKey {
    NSDictionary *dict = (NSDictionary *) [appConfigDict objectForKey:dictKey];
    NSArray *arr = (NSArray *)[dict objectForKey:key];
    return arr;
}

- (NSString *) valueForKey:(NSString *)key inDictionary:(NSString *)dictKey {
    NSString *value = (NSString *) [((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:key];
    
    return value;
}

- (BOOL) boolForKey:(NSString *)key inDictionary:(NSString *)dictKey {
    NSNumber *boolValue = [((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:key];
    BOOL value = [boolValue boolValue];
    
    return value;
}

- (UIFont *) fontForName:(NSString *)fontKey size:(NSString *)fontSizeKey inDictionary:(NSString *)dictKey {
    
    NSString *fontName = (NSString *) [((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:fontKey];
    NSString *fontSize = (NSString *) [((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:fontSizeKey];
    
    if ([NSString isNotEmpty:fontName] && [NSString isNotEmpty:fontSize]) {
        return [UIFont fontWithName:fontName size:[fontSize floatValue]];
    }
    
    return [UIFont fontWithName:@"HelveticaNeue" size:14];
}

- (UIColor *) colorForKey:(NSString *)key inDictionary:(NSString *)dictKey {

    NSString *colorStr = (NSString *) [((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:key];
    unsigned int colorRGB;
    
    if (colorStr) {
        // Have to check.  scanHexInt: will produce a value from a character string that is not hex.
        if ([[colorStr lowercaseString] hasPrefix:@"0x"]) {
            NSScanner *scan = [NSScanner scannerWithString:colorStr];
            
            if ([scan scanHexInt:&colorRGB]) {
                return [UIColor colorFromRGB:colorRGB];
            }
        } else if ([[colorStr lowercaseString] hasSuffix:@"png"] || [[colorStr lowercaseString] hasSuffix:@"jpg"] || [[colorStr lowercaseString] hasSuffix:@"gif"]) {
            return [UIColor colorWithPatternImage:[UIImage imageNamed:colorStr]];
        } else {
            // Handle things like clear for clearColor, gray for grayColor, etc.
            NSString *selectorString = [[colorStr lowercaseString] stringByAppendingString:@"Color"];
            SEL selector = NSSelectorFromString(selectorString);
            if ([UIColor respondsToSelector:selector]) {
                return [UIColor performSelector:selector];
            }
        }
    } 
    
    return [UIColor whiteColor];
}

- (NSString *) imagePortraitForKey:(NSString *)key inDictionary:(NSString *)dictKey {
    
    NSString *colorStr = (NSString *) [((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:key];
    
    if (colorStr) {
        colorStr = [colorStr lowercaseString];
        
        // Backgrounds may be different between ios7 (full screen) vs pre ios7
        UIImage *image  = nil;
        
       if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
           NSString *pre7ColorStr = colorStr;
           if ([pre7ColorStr hasSuffix:@"png"]) {
               pre7ColorStr = [pre7ColorStr stringByReplacingOccurrencesOfString:@".png" withString:@"-port-pre7.png"];
           } else if ([pre7ColorStr hasSuffix:@"jpg"]) {
               pre7ColorStr = [pre7ColorStr stringByReplacingOccurrencesOfString:@".jpg" withString:@"-port-pre7.jpg"];
           } else if ([pre7ColorStr hasSuffix:@"gif"]) {
               pre7ColorStr = [pre7ColorStr stringByReplacingOccurrencesOfString:@".png" withString:@"-port-pre7.gif"];
           }
           
           // Check for pre7 image
           image = [UIImage imageNamed:pre7ColorStr];
        }
        
        // There is no pre7 image so fallback
        if (image == nil) {
            if ([colorStr hasSuffix:@"png"]) {
                colorStr = [colorStr stringByReplacingOccurrencesOfString:@".png" withString:@"-port.png"];
            } else if ([colorStr hasSuffix:@"jpg"]) {
                colorStr = [colorStr stringByReplacingOccurrencesOfString:@".jpg" withString:@"-port.jpg"];
            } else if ([colorStr hasSuffix:@"gif"]) {
                colorStr = [colorStr stringByReplacingOccurrencesOfString:@".png" withString:@"-port.gif"];
            }
            
            image = [UIImage imageNamed:colorStr];
        }
        
        return colorStr;
    }
    
    return nil;
}

- (UIColor *) colorPortraitForKey:(NSString *)key inDictionary:(NSString *)dictKey {
    NSString *colorStr = [self imagePortraitForKey:key inDictionary:dictKey];
    if (colorStr) {
        UIImage *image = [UIImage imageNamed:colorStr];
        return [UIColor colorWithPatternImage:image];
    }
    return nil;
}



- (NSString *) imageLandscapeForKey:(NSString *)key inDictionary:(NSString *)dictKey {
    
    NSString *colorStr = (NSString *) [((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:key];
    
    if (colorStr) {
        colorStr = [colorStr lowercaseString];
        
        // Backgrounds may be different between ios7 (full screen) vs pre ios7
        UIImage *image  = nil;
        
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            NSString *pre7ColorStr = colorStr;
            if ([pre7ColorStr hasSuffix:@"png"]) {
                pre7ColorStr = [pre7ColorStr stringByReplacingOccurrencesOfString:@".png" withString:@"-land-pre7.png"];
            } else if ([pre7ColorStr hasSuffix:@"jpg"]) {
                pre7ColorStr = [pre7ColorStr stringByReplacingOccurrencesOfString:@".jpg" withString:@"-land-pre7.jpg"];
            } else if ([pre7ColorStr hasSuffix:@"gif"]) {
                pre7ColorStr = [pre7ColorStr stringByReplacingOccurrencesOfString:@".png" withString:@"-land-pre7.gif"];
            }
            
            // Check for pre7 image
            image = [UIImage imageNamed:pre7ColorStr];
        }
        
        // There is no pre7 image so fallback
        if (image == nil) {
            if ([colorStr hasSuffix:@"png"]) {
                colorStr = [colorStr stringByReplacingOccurrencesOfString:@".png" withString:@"-land.png"];
            } else if ([colorStr hasSuffix:@"jpg"]) {
                colorStr = [colorStr stringByReplacingOccurrencesOfString:@".jpg" withString:@"-land.jpg"];
            } else if ([colorStr hasSuffix:@"gif"]) {
                colorStr = [colorStr stringByReplacingOccurrencesOfString:@".png" withString:@"-land.gif"];
            }
            
            image = [UIImage imageNamed:colorStr];
        }
        
        return colorStr;
    }
    return nil;
}

- (UIColor *) colorLandscapeForKey:(NSString *)key inDictionary:(NSString *)dictKey {
    NSString *colorStr = [self imageLandscapeForKey:key inDictionary:dictKey];
    if (colorStr) {
        UIImage *image = [UIImage imageNamed:colorStr];
        return [UIColor colorWithPatternImage:image];
    }
    return nil;
}

// These don't handle all UIViewContentMode values.
- (UIViewContentMode) contentModeForKey: (NSString *)key inDictionary: (NSString *) dictKey {
    
    NSString *modeStr = (NSString *) [((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:key];
    
    UIViewContentMode mode = UIViewContentModeCenter;
    
    if (modeStr) {
        if ([@"UIViewContentModeTop" caseInsensitiveCompare:modeStr] == NSOrderedSame) {
            mode = UIViewContentModeTop;
        } else if ([@"UIViewContentModeBottom" caseInsensitiveCompare:modeStr] == NSOrderedSame) {
            mode = UIViewContentModeBottom;
        }
    }
    
    return mode;
}

// These don't handle all NSTextAlignment values.
- (NSTextAlignment) textAlignmentForKey: (NSString *)key inDictionary: (NSString *) dictKey {
    NSString *alignStr = (NSString *) [((NSDictionary *) [appConfigDict objectForKey:dictKey]) objectForKey:key];
    
    NSTextAlignment align = NSTextAlignmentCenter;
    
    if (alignStr) {
        if ([@"NSTextAlignmentLeft" caseInsensitiveCompare:alignStr] == NSOrderedSame) {
            align = NSTextAlignmentLeft;
        } else if ([@"NSTextAlignmentRight" caseInsensitiveCompare:alignStr] == NSOrderedSame) {
            align = NSTextAlignmentRight;
        }
    }
    
    return align;
}

@end

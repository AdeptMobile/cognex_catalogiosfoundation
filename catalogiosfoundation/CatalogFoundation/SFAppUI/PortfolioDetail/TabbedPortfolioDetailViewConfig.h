//
//  TabbedPortfolioDetailViewConfig.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 4/3/13.
//  Copyright (c) 2013 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TabbedPortfolioDetailViewConfig : NSObject {
    
}

@property (nonatomic, assign, readonly) BOOL landscapeOnly;

// Page logo and where it links (if anywhere)
@property (nonatomic, strong) NSString *leftLogoNamed;
@property (nonatomic, strong) NSString *leftLogoLink;
@property (nonatomic, strong) NSString *mailTemplate;
@property (nonatomic, strong) NSString *mailRecipient;
@property (nonatomic, strong) NSString *mailSubjectTemplate;
@property (nonatomic, strong) NSString *mailResourceGroup;

// Main view look
@property (nonatomic, strong) UIColor *mainBgColor;
@property (nonatomic, strong) UIColor *mainPortBgColor;
@property (nonatomic, strong) UIColor *mainLandBgColor;
@property (nonatomic, strong) NSString *mainBgImageNamed;

@property (nonatomic, strong) NSString *mainTitleFont;
@property (nonatomic, strong) UIColor *mainTitleFontColor;
@property (nonatomic, assign) CGFloat mainTitleFontSize;

@property (nonatomic, strong) NSString *mainInfoTextFont;
@property (nonatomic, strong) UIColor *mainInfoTextFontColor;
@property (nonatomic, assign) CGFloat mainInfoTextFontSize;
@property (nonatomic, assign) UIViewContentMode mainInfoTextVerticalAlignment;
@property (nonatomic, assign) NSTextAlignment mainInfoTextHorizontalAlignment;

@property (nonatomic, strong) NSString *mainBottomBarImageNamed;

// Online Catalog look
@property (nonatomic, strong) NSString *onlineCatalogButtonFont;
@property (nonatomic, strong) UIColor *onlineCatalogButtonTextColor;
@property (nonatomic, strong) UIColor *onlineCatalogButtonShadowColor;
@property (nonatomic, strong) NSString *onlineCatalogButtonImageNamed;
@property (nonatomic, strong) NSString *onlineCatalogButtonTitle;
@property (nonatomic, strong) NSString *onlineCatalogButtonResourceGroup;

// Category Shortcut look
@property (nonatomic, assign) BOOL categoryShortcutButtonEnabled;
@property (nonatomic, strong) NSString *categoryShortcutButtonFont;
@property (nonatomic, strong) UIColor *categoryShortcutButtonTextColor;
@property (nonatomic, strong) UIColor *categoryShortcutButtonShadowColor;
@property (nonatomic, strong) NSString *categoryShortcutButtonImageNamed;
@property (nonatomic, strong) NSString *categoryShortcutButtonTitle;
// If this is set all shortcut buttons will go to this category instead of using the
// button title to look for a category.
@property (nonatomic, strong) NSString *categoryShortcutButtonCategory;

// External application launch button
@property (nonatomic, assign) BOOL externalApplicationButtonEnabled;
@property (nonatomic, strong) NSString *externalApplicationButtonFont;
@property (nonatomic, strong) UIColor *externalApplicationButtonTextColor;
@property (nonatomic, strong) UIColor *externalApplicationButtonShadowColor;
@property (nonatomic, strong) NSString *externalApplicationButtonImageNamed;
@property (nonatomic, strong) NSString *externalApplicationButtonTitle;
@property (nonatomic, strong) NSString *externalApplicationButtonAppCheckUrl;
@property (nonatomic, strong) NSString *externalApplicationButtonAppOpenUrl;

// Features/Info look
@property (nonatomic, strong) NSString *featuresViewBgImageNamed;
@property (nonatomic, strong) UIColor *featuresViewBgColor;
@property (nonatomic, strong) UIColor *featuresViewBorderColor;
@property (nonatomic, strong) UIColor *featuresViewTextColor;

// Fonts
@property (nonatomic, strong) NSString *featuresViewTabLabelFont;
@property (nonatomic, assign) CGFloat featuresViewTabLabelFontSize;
@property (nonatomic, assign) UIViewContentMode featuresViewTabLabelVerticalAlignment;
@property (nonatomic, assign) NSTextAlignment featuresviewTabLabelHorizontalAlignment;

@property (nonatomic, strong) NSString *featuresViewResourceTextFont;
@property (nonatomic, assign) CGFloat featuresViewResourceTextFontSize;

// Active Tab look
@property (nonatomic, strong) UIColor *featuresViewActiveTabLabelBgColor;
@property (nonatomic, strong) UIColor *featuresViewActiveTabLabelShadowColor;
@property (nonatomic, strong) NSString *featuresViewActiveTabLabelImageNamed;
@property (nonatomic, strong) UIColor *featuresViewActiveTabLabelTextColor;

// Inactive Tabs look
@property (nonatomic, strong) UIColor *featuresViewInactiveTabLabelBgColor;
@property (nonatomic, strong) UIColor *featuresViewInactiveTabLabelShadowColor;
@property (nonatomic, strong) NSString *featuresViewInactiveTabLabelImageNamed;
@property (nonatomic, strong) UIColor *featuresViewInactiveTabLabelTextColor;

@property (nonatomic, strong) NSString *includedResourceGroup;

@end

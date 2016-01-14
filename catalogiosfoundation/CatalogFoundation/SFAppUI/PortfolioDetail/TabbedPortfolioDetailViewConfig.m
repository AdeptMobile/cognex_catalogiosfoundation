//
//  TabbedPortfolioDetailViewConfig.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 4/3/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import "TabbedPortfolioDetailViewConfig.h"

@implementation TabbedPortfolioDetailViewConfig

@synthesize landscapeOnly = _landscapeOnly;

// Page logo and where it links (if anywhere)
@synthesize leftLogoNamed = _leftLogoNamed;
@synthesize leftLogoLink = _leftLogoLink;

// Main view look
@synthesize mainBgColor = _mainBgColor;
@synthesize mainPortBgColor = _mainPortBgColor;
@synthesize mainLandBgColor = _mainLandBgColor;
@synthesize mainBgImageNamed = _mainBgImageNamed;

@synthesize mainTitleFont = _mainTitleFont;
@synthesize mainTitleFontColor = _mainTitleFontColor;
@synthesize mainTitleFontSize = _mainTitleFontSize;

@synthesize mainInfoTextFont = _mainInfoTextFont;
@synthesize mainInfoTextFontColor = _mainInfoTextFontColor;
@synthesize mainInfoTextFontSize = _mainInfoTextFontSize;
@synthesize mainInfoTextVerticalAlignment = _mainInfoTextVerticalAlignment;
@synthesize mainInfoTextHorizontalAlignment = _mainInfoTextHorizontalAlignment;

@synthesize mainBottomBarImageNamed = _mainBottomBarImageNamed;
@synthesize mailTemplate = _mailTemplate;
@synthesize mailRecipient = _mailRecipient;
@synthesize mailSubjectTemplate = _mailSubjectTemplate;
@synthesize mailResourceGroup = _mailResourceGroup;

// Online Catalog Button look
@synthesize onlineCatalogButtonFont = _onlineCatalogButtonFont;
@synthesize onlineCatalogButtonTextColor = _onlineCatalogButtonTextColor;
@synthesize onlineCatalogButtonShadowColor  = _onlineCatalogButtonShadowColor;
@synthesize onlineCatalogButtonImageNamed = _onlineCatalogButtonImageNamed;
@synthesize onlineCatalogButtonTitle = _onlineCatalogButtonTitle;
@synthesize onlineCatalogButtonResourceGroup = _onlineCatalogButtonResourceGroup;

// Category Shortcut look
@synthesize categoryShortcutButtonEnabled = _categoryShortcutButtonEnabled;
@synthesize categoryShortcutButtonFont = _categoryShortcutButtonFont;
@synthesize categoryShortcutButtonTextColor = _categoryShortcutButtonTextColor;
@synthesize categoryShortcutButtonShadowColor  = _categoryShortcutButtonShadowColor;
@synthesize categoryShortcutButtonImageNamed = _categoryShortcutButtonImageNamed;
@synthesize categoryShortcutButtonTitle = _categoryShortcutButtonTitle;
@synthesize categoryShortcutButtonCategory = _categoryShortcutButtonCategory;

// External application button
@synthesize externalApplicationButtonEnabled = _externalApplicationButtonEnabled;
@synthesize externalApplicationButtonFont = _externalApplicationButtonFont;
@synthesize externalApplicationButtonTextColor = _externalApplicationButtonTextColor;
@synthesize externalApplicationButtonShadowColor = _externalApplicationButtonShadowColor;
@synthesize externalApplicationButtonImageNamed = _externalApplicationButtonImageNamed;
@synthesize externalApplicationButtonTitle = _externalApplicationButtonTitle;
@synthesize externalApplicationButtonAppCheckUrl = _externalApplicationButtonAppCheckUrl;
@synthesize externalApplicationButtonAppOpenUrl = _externalApplicationButtonAppOpenUrl;

// Features/Info look
@synthesize featuresViewBgImageNamed = _featuresViewBgImageNamed;
@synthesize featuresViewBgColor = _featuresViewBgColor;
@synthesize featuresViewBorderColor = _featuresViewBorderColor;
@synthesize featuresViewTextColor = _featuresViewTextColor;

// Fonts
@synthesize featuresViewTabLabelFont = _featuresViewTabLabelFont;
@synthesize featuresViewTabLabelFontSize = _featuresViewTabLabelFontSize;
@synthesize featuresViewTabLabelVerticalAlignment = _featuresViewTabLabelVerticalAlignment;
@synthesize featuresviewTabLabelHorizontalAlignment = _featuresviewTabLabelHorizontalAlignment;

@synthesize featuresViewResourceTextFont = _featuresViewResourceTextFont;
@synthesize featuresViewResourceTextFontSize = _featuresViewResourceTextFontSize;

// Active Tab look
@synthesize featuresViewActiveTabLabelBgColor = _featuresViewActiveTabLabelBgColor;
@synthesize featuresViewActiveTabLabelShadowColor = _featuresViewActiveTabLabelShadowColor;
@synthesize featuresViewActiveTabLabelImageNamed = _featuresViewActiveTabLabelImageNamed;
@synthesize featuresViewActiveTabLabelTextColor = _featuresViewActiveTabLabelTextColor;

// Inactive Tabs look
@synthesize featuresViewInactiveTabLabelBgColor = _featuresViewInactiveTabLabelBgColor;
@synthesize featuresViewInactiveTabLabelShadowColor = _featuresViewInactiveTabLabelShadowColor;
@synthesize featuresViewInactiveTabLabelImageNamed = _featuresViewInactiveTabLabelImageNamed;
@synthesize featuresViewInactiveTabLabelTextColor = _featuresViewInactiveTabLabelTextColor;

@synthesize includedResourceGroup = _includedResourceGroup;

#pragma mark - init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        // The tabbed view is set up for landscape orientation only.
        _landscapeOnly = YES;
    }
    
    return self;
}

@end

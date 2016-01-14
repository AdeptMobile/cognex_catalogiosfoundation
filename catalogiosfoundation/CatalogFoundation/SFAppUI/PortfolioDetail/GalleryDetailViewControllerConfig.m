//
//  GalleryDetailViewControllerConfig.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 1/30/15.
//  Copyright (c) 2015 Object Partners Inc. All rights reserved.
//

#import "GalleryDetailViewControllerConfig.h"

@implementation GalleryDetailViewControllerConfig

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


#pragma mark - init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        // The gallery view is set up for landscape orientation only.
        _landscapeOnly = YES;
    }
    
    return self;
}

@end

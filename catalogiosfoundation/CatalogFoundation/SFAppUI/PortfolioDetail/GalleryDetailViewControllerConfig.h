//
//  GalleryDetailViewControllerConfig.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 1/30/15.
//  Copyright (c) 2015 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GalleryDetailViewControllerConfig : NSObject {
    
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

@end

//
//  PortfolioDetailVideoControllerConfig.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 4/10/13.
//  Copyright (c) 2013 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PortfolioDetailVideoControllerConfig : NSObject

// Page logo and where it links (if anywhere)
@property (nonatomic, strong) NSString *leftLogoNamed;
@property (nonatomic, strong) NSString *leftLogoLink;

@property (nonatomic, strong) NSString *mainBgImageNamed;
@property (nonatomic, strong) UIColor *mainBgColor;
@property (nonatomic, strong) NSString *mainTitleFont;
@property (nonatomic, strong) UIColor *mainTitleFontColor;

@property (nonatomic, strong) NSString *mainBottomBarImageNamed;

@property (nonatomic, strong) UIColor *activeBgColor;
@property (nonatomic, strong) UIColor *inactiveBgColor;

@property (nonatomic, strong) NSString *videoTopCategoryNamed;

@property (nonatomic, assign) NSInteger numThumbsPortrait;
@property (nonatomic, assign) NSInteger numThumbsLandscape;

@end

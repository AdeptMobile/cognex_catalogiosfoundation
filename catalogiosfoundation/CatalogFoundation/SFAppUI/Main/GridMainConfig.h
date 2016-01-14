//
//  GridMainConfig.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/1/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GridMainConfig : NSObject

@property (nonatomic, strong) UIColor *pageControlActiveColor;
@property (nonatomic, strong) UIColor *pageControlInactiveColor;
@property (nonatomic, assign) NSInteger thumbsPerPagePortrait;
@property (nonatomic, assign) NSInteger thumbsPerPageLandscape;
@property (nonatomic, copy) NSString *bgImageName;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *scrollBgColor;
@property (nonatomic, assign) BOOL titleImageRotates;
@property (nonatomic, strong) NSArray *titleImageArray;
@property (nonatomic, strong) UIColor *statusBarColor;
@property (nonatomic, copy) NSString *initialDownloadImageName;
@property (nonatomic, copy) NSString *defaultMastheadImage;
@property (nonatomic, strong) NSString *leftLogoNamed;
@property (nonatomic, strong) NSString *rightLogoNamed;
@property (nonatomic, strong) NSString *leftLogoLink;
@property (nonatomic, strong) NSString *rightLogoLink;

@property (nonatomic, assign) NSNumber *scrollViewFrameOffset;
@property (nonatomic, assign) NSNumber *tightLayoutFrameHeight;
@property (nonatomic, assign) NSNumber *mainViewScrollFrameHeight;


@end

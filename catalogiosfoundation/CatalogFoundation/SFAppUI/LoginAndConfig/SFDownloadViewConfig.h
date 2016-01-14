//
//  SFDownloadViewConfig.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/6/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFDownloadViewConfig : NSObject

@property (nonatomic, assign) BOOL landscapeOnly;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, copy) NSString *bgImageNamed;

@property (nonatomic, copy) NSString *toggleViewFont;
@property (nonatomic, assign) CGFloat toggleViewFontSize;

@property (nonatomic, copy) NSString *toggleViewTitleFont;
@property (nonatomic, assign) CGFloat toggleViewTitleFontSize;

@property (nonatomic, strong) UIColor *toggleViewTextColor;
@property (nonatomic, strong) UIColor *toggleViewBgColor;
@property (nonatomic, strong) UIColor *toggleViewToggleTintColor;
@property (nonatomic, copy) NSString *doneButtonImageNamed;
@property (nonatomic, copy) NSString *videoHeaderText;
@property (nonatomic, copy) NSString *videoDetailText;
@property (nonatomic, copy) NSString *presentationHeaderText;
@property (nonatomic, copy) NSString *presentationDetailText;
@property (nonatomic, copy) NSString *subTitleText;

@property (nonatomic, assign) BOOL enableBigSyncByDefault;
@end

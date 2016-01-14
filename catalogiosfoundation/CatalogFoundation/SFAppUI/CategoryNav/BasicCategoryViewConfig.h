//
//  BasicCategoryViewConfig.h
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/5/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasicCategoryViewConfig : NSObject {
    
}

@property (nonatomic, strong) NSString *leftLogoNamed;
@property (nonatomic, strong) NSString *leftLogoLink;

@property (nonatomic, strong) UIColor *mainViewBgColor;
@property (nonatomic, strong) UIColor *mainViewPortBgColor;
@property (nonatomic, strong) UIColor *mainViewLandBgColor;
@property (nonatomic, strong) NSString *mainViewBgImageNamed;
@property (nonatomic, strong) NSString *mainViewLandBgImageNamed;
@property (nonatomic, strong) NSString *mainViewPortBgImageNamed;
@property (nonatomic, assign) BOOL displayCategoryTitle;
@property (nonatomic, strong) NSString *categoryTitleFontName;
@property (nonatomic, assign) CGFloat categoryTitleFontSize;
@property (nonatomic, strong) UIColor *categoryTitleFontColor;

@property (nonatomic, strong) UIColor *thumbLabelTextColor;
@property (nonatomic, strong) UIColor *thumbLabelBackgroundColor;
@property (nonatomic, strong) UIColor *thumbViewBackgroundColor;
@property (nonatomic, strong) UIColor *thumbHighlightBackgroundColor;
@property (nonatomic, strong) UIColor *thumbImageBackgroundColor;
@property (nonatomic, strong) UIColor *thumbBorderColor;
@property (nonatomic, strong) NSString *thumbBgImageNamed;

@property (nonatomic, assign, getter=isReflectionOn) BOOL isReflectionOn;
@property (nonatomic, assign, getter=isRoundedCorners) BOOL isRoundedCorners;
@property (nonatomic, assign, getter=isLabelAboveImage) BOOL isLabelAboveImage;
@property (nonatomic, assign, getter=isLabelMultiLine) BOOL isLabelMultiLine;

@property (nonatomic, assign) CGFloat thumbMargin;
@property (nonatomic, assign) CGSize thumbScaleSize;
@property (nonatomic, assign) CGSize thumbImageSize;
@property (nonatomic, assign) CGSize thumbReflectionSize;
@property (nonatomic, assign) CGSize thumbLabelSize;
@property (nonatomic, assign) CGSize thumbSize;
@property (nonatomic, assign, getter = isLabelBackgroundGradient) BOOL isLabelBackgroundGradient;
@property (nonatomic, strong) NSString *thumbLabelFontName;
@property (nonatomic, assign) CGFloat thumbLabelFontSize;
@property (nonatomic, assign, getter=isLabelAllCaps) BOOL isLabelAllCaps;
@property (nonatomic, assign, getter=isLabelShadow) BOOL isLabelShadow;
@property (nonatomic, assign) CGSize thumbLabelShadowSize;
@property (nonatomic, strong) UIColor *thumbLabelShadowColor;
@property (nonatomic, assign) NSInteger thumbsPerPageLandscape;
@property (nonatomic, assign) NSInteger thumbsPerPagePortrait;

@property (nonatomic, strong) UIColor *pageControlActiveColor;
@property (nonatomic, strong) UIColor *pageControlInactiveColor;

@end

//
//  CarouselMainConfig.h
//  CatalogFoundation
//
//  Created by Torey Lomenda on 1/31/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iCarousel.h"

@interface CarouselMainConfig : NSObject

@property (nonatomic, assign) iCarouselType carouselType;

@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) NSString *bgImage;
@property (nonatomic, strong) NSString *initialBgImage;

@property (nonatomic, strong) NSString *bgImagePortrait;
@property (nonatomic, strong) NSString *bgImageLandscape;
@property (nonatomic, strong) NSString *initialBgImagePortrait;
@property (nonatomic, strong) NSString *initialBgImageLandscape;

@property (nonatomic, strong) UIColor *itemBgColor;
@property (nonatomic, strong) UIColor *itemBorderColor;
// If this is set it tells us which item should be showed as the default/front
// item when the carousel is presented.
@property (nonatomic, strong) NSString *defaultItemTitle;

@property (nonatomic, strong) NSString *leftLogoNamed;
@property (nonatomic, strong) NSString *rightLogoNamed;

@property (nonatomic, strong) NSString *leftLogoLink;
@property (nonatomic, strong) NSString *rightLogoLink;

@property (nonatomic, assign, getter=isReflectionOn) BOOL isReflectionOn;

@end

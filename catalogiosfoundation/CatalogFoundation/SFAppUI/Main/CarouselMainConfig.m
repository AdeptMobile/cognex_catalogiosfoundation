//
//  CarouselMainConfig.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 1/31/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import "CarouselMainConfig.h"

@implementation CarouselMainConfig
@synthesize carouselType = _carouselType;

@synthesize bgColor = _bgColor;
@synthesize bgImagePortrait = _bgImagePortrait;
@synthesize bgImageLandscape = _bgImageLandscape;

@synthesize itemBgColor = _itemBgColor;
@synthesize itemBorderColor = _itemBorderColor;

@synthesize leftLogoNamed = _leftLogoNamed;
@synthesize rightLogoNamed = _rightLogoNamed;

@synthesize leftLogoLink = _leftLogoLink;
@synthesize rightLogoLink = _rightLogoLink;

@synthesize defaultItemTitle = _defaultItemTitle;

@synthesize isReflectionOn = _isReflectionOn;

#pragma mark - init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        // Configure anything here
        self.isReflectionOn = YES;
    }
    
    return self;
}


#pragma mark - Accessor Methods

#pragma mark - Public Methods

#pragma mark - Private Methods
@end

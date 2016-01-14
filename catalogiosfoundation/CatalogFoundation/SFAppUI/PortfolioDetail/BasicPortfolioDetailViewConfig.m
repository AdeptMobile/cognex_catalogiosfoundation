//
//  BasicPortfolioDetailViewConfig.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/5/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import "BasicPortfolioDetailViewConfig.h"

@implementation BasicPortfolioDetailViewConfig
@synthesize leftLogoNamed = _leftLogoNamed;
@synthesize leftLogoLink = _leftLogoLink;

@synthesize mainBgColor = _mainBgColor;
@synthesize mainPortBgColor = _mainPortBgColor;
@synthesize mainLandBgColor = _mainLandBgColor;

@synthesize featuresViewBorderColor = _featuresViewBorderColor;
@synthesize featuresViewDetailLabelBgColor = _featuresViewDetailLabelBgColor;
@synthesize featuresViewDetailLabelTextColor = _featuresViewDetailLabelTextColor;
@synthesize featuresViewBenefitLabelBgColor = _featuresViewBenefitLabelBgColor;
@synthesize featuresViewBenefitLabelTextColor = _featuresViewBenefitLabelTextColor;

@synthesize isFeaturesLabelHidden = _isFeaturesLabelHidden;
@synthesize isBenefitsLabelHidden = _isBenefitsLabelHidden;

#pragma mark - init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        // Configure anything here
        self.isFeaturesLabelHidden = NO;
        self.isBenefitsLabelHidden = NO;
    }
    
    return self;
}


#pragma mark - Accessor Methods

#pragma mark - Public Methods

#pragma mark - Private Methods
@end

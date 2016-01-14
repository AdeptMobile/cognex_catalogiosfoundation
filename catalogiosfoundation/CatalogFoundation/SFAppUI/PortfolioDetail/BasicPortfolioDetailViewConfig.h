//
//  BasicPortfolioDetailViewConfig.h
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/5/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasicPortfolioDetailViewConfig : NSObject {
    NSString *leftLogoNamed;
    NSString *leftLogoLink;
    
    UIColor *mainBgColor;
    UIColor *mainPortBgColor;
    UIColor *mainLandBgColor;
    
    UIColor *featuresViewBorderColor;
    UIColor *featuresViewDetailLabelBgColor;
    UIColor *featuresViewDetailLabelTextColor;
    UIColor *featuresViewBenefitLabelBgColor;
    UIColor *featuresViewBenefitLabelTextColor;
    
    BOOL isFeaturesLabelHidden;
    BOOL isBenefitsLabelHidden;
}
@property (nonatomic, strong) NSString *leftLogoNamed;
@property (nonatomic, strong) NSString *leftLogoLink;

@property (nonatomic, strong) UIColor *mainBgColor;
@property (nonatomic, strong) UIColor *mainPortBgColor;
@property (nonatomic, strong) UIColor *mainLandBgColor;

@property (nonatomic, strong) UIColor *featuresViewBorderColor;
@property (nonatomic, strong) UIColor *featuresViewDetailLabelBgColor;
@property (nonatomic, strong) UIColor *featuresViewDetailLabelTextColor;
@property (nonatomic, strong) UIColor *featuresViewBenefitLabelBgColor;
@property (nonatomic, strong) UIColor *featuresViewBenefitLabelTextColor;

@property (nonatomic, assign, getter=isFeaturesLabelHidden) BOOL isFeaturesLabelHidden;
@property (nonatomic, assign, getter=isBenefitsLabelHidden) BOOL isBenefitsLabelHidden;

@end

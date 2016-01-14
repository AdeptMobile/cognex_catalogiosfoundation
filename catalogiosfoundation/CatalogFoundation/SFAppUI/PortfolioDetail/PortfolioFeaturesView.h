//
//  ProductFeaturesView.h
//  SickApp
//
//  Created by Steven McCoole on 4/24/12.
//  Copyright (c) 2012 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContentViewBehavior.h"

#import "DTCoreText.h"

@interface PortfolioFeaturesView : UIView {
    id<ContentViewBehavior> contentProduct;
    
    UILabel *featuresLabel;
    
    UILabel *benefitsLabel;
    
    DTAttributedTextView *featuresTextView;
    DTAttributedTextView *benefitsTextView;
    UIView *borderView;
    
    NSAttributedString *featuresString;
    NSAttributedString *benefitsString;
    
    BOOL showingFeatures;
}

@property (nonatomic, strong) id<ContentViewBehavior> contentProduct;
@property (nonatomic, strong) NSAttributedString *featuresString;
@property (nonatomic, strong) NSAttributedString *benefitsString;
@property (nonatomic, assign) BOOL showingFeatures;

-(id) initWithFrame:(CGRect)frame andContentProduct:(id<ContentViewBehavior>) aContentProduct;

@end

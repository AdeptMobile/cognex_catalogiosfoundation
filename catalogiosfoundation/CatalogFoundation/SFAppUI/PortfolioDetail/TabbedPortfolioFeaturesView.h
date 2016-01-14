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

@interface TabbedPortfolioFeaturesView : UIView {

}

@property (nonatomic, strong) DTAttributedTextView *textView;

@property (nonatomic, strong) id<ContentViewBehavior> contentProduct;
@property (nonatomic) BOOL showingFeatures;

-(id) initWithFrame:(CGRect)frame andContentProduct:(id<ContentViewBehavior>) aContentProduct;

@end

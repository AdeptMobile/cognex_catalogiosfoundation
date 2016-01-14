//
//  ProductInfoView.h
//  ToloApp
//
//  Created by Torey Lomenda on 6/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContentViewBehavior.h"

#import "ProductPhotoViewConfig.h"

@interface ProductPhotoView : UIView {
}

@property (nonatomic, strong) id<ContentViewBehavior> contentProduct;

@property (nonatomic, strong) ProductPhotoViewConfig *viewConfig;

@property (nonatomic, strong) UIImageView *productTabImage;
@property (nonatomic, strong) UIImageView *productCatTabImage;

@property (nonatomic, strong) UILabel *productLabel;
@property (nonatomic, strong) UILabel *productCatLabel;
@property (nonatomic, strong) UIImageView *productImage;

-(id) initWithFrame:(CGRect)frame contentProduct:(id<ContentViewBehavior>)aContentProduct;

@end

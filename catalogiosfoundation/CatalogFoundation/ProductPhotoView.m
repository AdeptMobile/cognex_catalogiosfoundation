//
//  ProductInfoView.m
//  ToloApp
//
//  Created by Torey Lomenda on 6/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ProductPhotoView.h"
#import "ContentUtils.h"

#import "SFAppConfig.h"

#import "UIView+ViewLayout.h"
#import "NSString+Extensions.h"
#import "UIColor+Chooser.h"
#import "UIImage+Extensions.h"
#import "NSFileManager+Extensions.h"
#import "UIImage+CatalogFoundationResourceImage.h"

#define TAB_LABEL_WIDTH 244.0f
#define TAB_LABEL_HEIGHT  30.0f

@interface ProductPhotoView()

- (void) setupTabLabels;

@end

@implementation ProductPhotoView

@synthesize contentProduct = _contentProduct;
@synthesize viewConfig = _viewConfig;
@synthesize productTabImage = _productTabImage;
@synthesize productCatTabImage = _productCatTabImage;
@synthesize productLabel = _productLabel;
@synthesize productCatLabel = _productCatLabel;
@synthesize productImage = _productImage;

#pragma mark -
#pragma mark init/dealloc
- (id)initWithFrame:(CGRect)frame contentProduct:(id<ContentViewBehavior>)aContentProduct {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentProduct = aContentProduct;
        
        // View properties
        self.viewConfig = [[SFAppConfig sharedInstance] getProductPhotoViewConfig];
        
        // Product Labels
        [self setupTabLabels];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -
#pragma mark Layout Subviews code
- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect productImageFrame;
    
    if (self.viewConfig && self.viewConfig.doShowTabs) {
        CGRect categoryTabFrame = CGRectMake(0, 0, TAB_LABEL_WIDTH, TAB_LABEL_HEIGHT);
        CGRect productTabFrame = CGRectMake(self.bounds.size.width - TAB_LABEL_WIDTH, 0, TAB_LABEL_WIDTH, TAB_LABEL_HEIGHT);
        productImageFrame = CGRectMake(0, TAB_LABEL_HEIGHT, self.bounds.size.width, self.bounds.size.height - TAB_LABEL_HEIGHT); 
        
        self.productCatTabImage.frame = categoryTabFrame;
        self.productCatLabel.frame = categoryTabFrame;
        self.productTabImage.frame = productTabFrame;
        self.productLabel.frame = productTabFrame;
    } else {
        productImageFrame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
    
    self.productImage.frame = productImageFrame;
    
    if (self.viewConfig) {
        [self.productImage applyBorderStyle:self.viewConfig.borderColor withBorderWidth:2.0f withShadow:NO];
    }
}

#pragma mark -
#pragma mark Private Methods
- (void) setupTabLabels {
    if (self.viewConfig && self.viewConfig.doShowTabs) {
        self.productCatLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _productCatLabel.textColor = self.viewConfig.tabReturnTextColor;
        _productCatLabel.textAlignment = NSTextAlignmentCenter;
        _productCatLabel.text = @"Return To Products";
        _productCatLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _productCatLabel.backgroundColor = [UIColor clearColor];
        _productCatLabel.adjustsFontSizeToFitWidth = YES;
        _productCatLabel.userInteractionEnabled = YES;
        
        self.productLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _productLabel.textColor = self.viewConfig.tabProductTextColor;
        _productLabel.textAlignment = NSTextAlignmentCenter;
        _productLabel.text = [self.contentProduct contentTitle];
        _productLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _productLabel.backgroundColor = [UIColor clearColor];
        _productLabel.adjustsFontSizeToFitWidth = YES;
        _productLabel.userInteractionEnabled = NO;
        
        self.productTabImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        _productTabImage.image = [UIImage contentFoundationResourceImageNamed:@"tab-black-square.png"];
        
        _productCatTabImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        _productCatTabImage.image = [UIImage contentFoundationResourceImageNamed:@"tab-grey-square.png"];
        
        [self addSubview:_productCatTabImage];
        [self addSubview:_productTabImage];
        [self addSubview:_productLabel];
        [self addSubview:_productCatLabel];
    }
    
    self.productImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    _productImage.contentMode = UIViewContentModeScaleAspectFit;
    
    if ([self.contentProduct hasImages]) {
        _productImage.image = [UIImage imageWithContentsOfFile:[[self.contentProduct contentImages] objectAtIndex:0]];
    } else {
        _productImage.image = [UIImage contentFoundationResourceImageNamed:@"not-found.png"];
    }
    _productImage.userInteractionEnabled = YES;

    [self addSubview:_productImage];
}

@end

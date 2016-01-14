//
//  ProductThumbnailConfig.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 2/20/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ProductThumbnailConfig.h"

#define THUMBNAIL_WIDTH  100.0f
#define THUMBNAIL_HEIGHT 140.0f
#define DEFAULT_LABEL_HEIGHT 20.0f

@implementation ProductThumbnailConfig

@synthesize highlightBackgroundColor;
@synthesize labelTextColor;
@synthesize labelBackgroundColor;
@synthesize noPreviewLabelTextColor;
@synthesize noPreviewLabelBackgroundColor;
@synthesize thumbnailImageBackgroundColor;
@synthesize thumbnailViewBackgroundColor;

@synthesize labelMultiLine;
@synthesize isLabelAllCaps;

@synthesize scaleSize;
@synthesize imageSize;
@synthesize reflectionSize;
@synthesize labelSize;
@synthesize backgroundImageName;
@synthesize iconBorderColor;
@synthesize margin;
@synthesize labelBackgroundGradient;

@synthesize isLabelAboveImage;
@synthesize roundedCorners;
@synthesize labelFont;
@synthesize labelShadowColor;
@synthesize labelShadowOffset;

@synthesize isReflectionOn = _isReflectionOn;


#pragma mark - init/dealloc methods
- (id) init {
    self = [super init];
    if (self) {
        self.scaleSize = CGSizeMake(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT);
        self.imageSize = CGSizeMake(0.0f, 0.0f);
        self.reflectionSize = CGSizeMake(0.0f, 0.0f);
        // A zero value means to use the full width or height.
        self.labelSize = CGSizeMake(0.0f, DEFAULT_LABEL_HEIGHT);
        self.backgroundImageName = nil;
        self.iconBorderColor = nil;
        self.margin = 0.0f;
        self.labelBackgroundGradient = NO;
        
        self.labelMultiLine = NO;
        self.isLabelAllCaps = NO;
        self.highlightBackgroundColor = [UIColor grayColor];
        self.labelTextColor = [UIColor blackColor];
        self.labelBackgroundColor = [UIColor clearColor];
        self.noPreviewLabelBackgroundColor = [UIColor whiteColor];
        self.noPreviewLabelTextColor = [UIColor blackColor];
        self.thumbnailImageBackgroundColor = [UIColor clearColor];
        self.thumbnailViewBackgroundColor = [UIColor whiteColor];
        
        self.roundedCorners = NO;
        self.isLabelAboveImage = NO;
        self.labelFont = nil;
        self.labelShadowColor = nil;
        self.labelShadowOffset = CGSizeZero;
        
        self.isReflectionOn = YES;

    }
    return self;
}

@end

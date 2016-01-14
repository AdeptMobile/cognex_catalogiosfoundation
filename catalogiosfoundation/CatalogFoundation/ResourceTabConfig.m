//
//  ResourceTabConfig.m
//  CatalogFoundation
//
//  Created by Chris Pflepsen on 8/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ResourceTabConfig.h"

#import "UIImage+Extensions.h"
#import "UIImage+CatalogFoundationResourceImage.h"

@implementation ResourceTabConfig
@synthesize buttonTag;

@synthesize contentItem;
@synthesize buttonTitle;
@synthesize normalStateImage;
@synthesize selectedStateImage;

@synthesize tabSize;
@synthesize titleFont;
@synthesize titleShadowSize;
@synthesize titleShadowColor;
@synthesize titleFontColor;
@synthesize titleSelectedFontColor;
@synthesize verticalAlignment;
@synthesize horizontalAlignment;

#pragma mark -
#pragma mark init/dealloc

- (id) initWith: (id<ContentViewBehavior>)aContentItem normalStateImage:(UIImage *)normalImg selectedStateImage:(UIImage *)selectedImg titleFont:(UIFont *)font titleShadowColor:(UIColor *)shadowColor tabSize:(CGSize)size tabSpacing:(CGFloat)spacing titleShadowSize:(CGSize)shadowSize titleColor:(UIColor *)titleColor {
    self = [super init];
    
    if (self) {
        // Configure anything here
        self.buttonTag = NO_BUTTON_TAG;
        self.contentItem = aContentItem;
        self.buttonTitle = [self.contentItem contentTitle];
        
        self.normalStateImage = normalImg;
        self.selectedStateImage = selectedImg;
        
        self.titleFont = font;
        self.titleShadowColor = shadowColor;
        self.titleShadowSize = shadowSize;
        self.tabSize = size;
        self.tabSpacing = spacing;
        self.titleFontColor = titleColor;
        
        // Default selected color
        self.titleSelectedFontColor = [UIColor blackColor];
        
        self.verticalAlignment = UIViewContentModeCenter;
        self.horizontalAlignment = NSTextAlignmentCenter;
        
    }
    
    return self;
}


@end

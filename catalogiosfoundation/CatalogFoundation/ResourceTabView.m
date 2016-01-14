//
//  ResourceTabView.m
//  CatalogFoundation
//
//  Created by Chris Pflepsen on 8/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ResourceTabView.h"


@implementation ResourceTabView

@synthesize backgroundImageView, viewConfig, titleLabel;

- (id)initWithFrame:(CGRect)frame config:(ResourceTabConfig *)tabConfig
{
    self = [super initWithFrame:frame];
    if (self) {
        
        viewConfig = tabConfig;
        
        CGRect originFrame = frame;
        originFrame.origin = CGPointMake(0, 0);
        
        backgroundImageView = [[UIImageView alloc] initWithFrame:originFrame];
        backgroundImageView.image = tabConfig.normalStateImage;
        
        [self addSubview:backgroundImageView];
        
        titleLabel = [[FXLabel alloc] initWithFrame:originFrame];
        [titleLabel setText:[tabConfig.buttonTitle uppercaseString]];
        
        titleLabel.font = tabConfig.titleFont;
        titleLabel.shadowOffset = tabConfig.titleShadowSize;
        titleLabel.shadowColor = tabConfig.titleShadowColor;
        titleLabel.textColor = tabConfig.titleFontColor;
        titleLabel.textAlignment = tabConfig.horizontalAlignment;
        titleLabel.contentMode = tabConfig.verticalAlignment;
        titleLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:titleLabel];
    }
    return self;
}


@end

//
//  ResourceButtonConfig.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/17/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ResourceButtonConfig.h"

#import "UIImage+Extensions.h"
#import "UIImage+CatalogFoundationResourceImage.h"
#import "UIColor+Chooser.h"

@implementation ResourceButtonConfig
@synthesize buttonTag;

@synthesize resourceGroup;
@synthesize buttonTitle;
@synthesize normalStateImage;
@synthesize selectedStateImage;

@synthesize disableButtonColor;
@synthesize enableButtonColor;

#pragma mark -
#pragma mark init/dealloc
- (id) initWith:(id<ContentViewBehavior>)aResourceGroup {
    self = [self initWith:aResourceGroup
                enabledColor: [UIColor colorFromRGB:0xFFFFFF] disabledColor:[UIColor colorFromRGB:0x677983]
                normalStateImage:[UIImage contentFoundationResourceImageNamed:@"resourcegroup-btn-normal.png"] selectedStateImage:[UIImage contentFoundationResourceImageNamed:@"resourcegroup-btn-selected.png"]];
    
    return self;
}

- (id) initWith:(id<ContentViewBehavior>)aResourceGroup enabledColor:(UIColor *)anEnabledColor disabledColor:(UIColor *)aDisabledColor {
    self = [self initWith:aResourceGroup enabledColor: anEnabledColor disabledColor:aDisabledColor
                    normalStateImage:[UIImage contentFoundationResourceImageNamed:@"resourcegroup-btn-normal.png"] selectedStateImage:[UIImage contentFoundationResourceImageNamed:@"resourcegroup-btn-selected.png"]];
    
    return self;
}

- (id) initWith: (id<ContentViewBehavior>)aResourceGroup enabledColor:(UIColor *)anEnabledColor disabledColor:(UIColor *)aDisabledColor
                    normalStateImage:(UIImage *)normalImg selectedStateImage:(UIImage *)selectedImg {
    self = [super init];
    
    if (self) {
        // Configure anything here
        self.buttonTag = NO_BUTTON_TAG;
        self.resourceGroup = aResourceGroup;
        self.buttonTitle = [self.resourceGroup contentTitle];
        self.enableButtonColor = anEnabledColor;
        self.disableButtonColor = aDisabledColor;
        
        self.normalStateImage = normalImg;
        self.selectedStateImage = selectedImg;
    }
    
    return self;
}


#pragma mark -
#pragma mark Accessor Methods

#pragma mark - 
#pragma mark Public Methods

#pragma mark -
#pragma mark Private Methods

@end

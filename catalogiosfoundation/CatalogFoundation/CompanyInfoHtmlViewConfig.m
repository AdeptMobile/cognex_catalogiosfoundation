//
//  CompanyInfoHtmlViewConfig.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/4/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import "CompanyInfoHtmlViewConfig.h"

@implementation CompanyInfoHtmlViewConfig
@synthesize logoLeft = _logoLeft;
@synthesize logoRight = _logoRight;
@synthesize leftLogoLink = _leftLogoLink;
@synthesize rightLogoLink = _rightLogoLink;
@synthesize bgColor = _bgColor;
@synthesize textColor = _textColor;

#pragma mark - init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        // Configure anything here
        _bgColor = [UIColor whiteColor];
    }
    
    return self;
}


#pragma mark - Accessor Methods

#pragma mark - Public Methods

#pragma mark - Private Methods

@end

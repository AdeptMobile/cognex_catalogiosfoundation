//
//  ProductPhotoViewConfig.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/6/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import "ProductPhotoViewConfig.h"

@implementation ProductPhotoViewConfig
@synthesize borderColor = _borderColor;
@synthesize tabReturnTextColor = _tabReturnTextColor;
@synthesize tabProductTextColor = _tabProductTextColor;
@synthesize doShowTabs = _doShowTabs;

#pragma mark - init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        // Configure anything here
    }
    
    return self;
}


#pragma mark - Accessor Methods

#pragma mark - Public Methods

#pragma mark - Private Methods

@end

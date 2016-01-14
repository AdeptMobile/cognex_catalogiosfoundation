//
//  ResourceButtonMenuConfig.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/17/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ResourceButtonMenuConfig.h"

@implementation ResourceButtonMenuConfig
@synthesize title;
@synthesize titleTextColor;
@synthesize titleBackgroundColor;
@synthesize titleBorderColor;

@synthesize buttonConfigList;


#pragma mark -
#pragma mark init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        self.buttonConfigList = [NSMutableArray arrayWithCapacity:0];
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

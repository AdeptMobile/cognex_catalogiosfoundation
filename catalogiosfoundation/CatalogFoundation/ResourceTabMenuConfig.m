//
//  ResourceTabMenuConfig.m
//  CatalogFoundation
//
//  Created by Chris Pflepsen on 8/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ResourceTabMenuConfig.h"

@implementation ResourceTabMenuConfig

@synthesize tabConfigList;

#pragma mark -
#pragma mark init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        self.tabConfigList = [NSMutableArray arrayWithCapacity:0];
    }
    
    return self;
}


@end

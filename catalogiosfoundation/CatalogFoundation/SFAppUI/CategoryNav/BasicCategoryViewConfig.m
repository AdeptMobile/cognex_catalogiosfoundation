//
//  BasicCategoryViewConfig.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/5/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import "BasicCategoryViewConfig.h"

@implementation BasicCategoryViewConfig

#pragma mark - init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        // Configure anything here
        self.isReflectionOn = YES;
        self.thumbsPerPagePortrait = 9;
        self.thumbsPerPageLandscape = 6;
        self.displayCategoryTitle = NO;
    }
    
    return self;
}


#pragma mark - Accessor Methods

#pragma mark - Public Methods

#pragma mark - Private Methods
@end

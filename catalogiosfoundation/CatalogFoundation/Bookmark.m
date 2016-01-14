//
//  Bookmark.m
//  ToloApp
//
//  Created by Torey Lomenda on 7/26/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Bookmark.h"


@implementation Bookmark

@synthesize name;
@synthesize pageNumber;

#pragma mark -
#pragma mark init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        // Initialization code
    }
    
    return self;
}


#pragma mark - 
#pragma mark Public Methods
- (NSString *) toString {
    return [NSString stringWithFormat:@"%@::%u", name, [pageNumber unsignedIntValue]];
}

@end

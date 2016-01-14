//
//  ProductReference.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/2/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "DetailReference.h"

@implementation DetailReference

@synthesize name;
@synthesize detailId;
@synthesize detailType;
@synthesize detailThumbnail;

#pragma mark - init/dealloc
- (id) init {
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - public methods
- (NSString *) toString {
    // This is used when we store the reference in the user default settings as a detail favorite.
    // We don't include the image for that.
    return [NSString stringWithFormat:@"%@::%@::%@", name, detailId, detailType];
}

@end

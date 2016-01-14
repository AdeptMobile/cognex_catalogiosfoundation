//
//  ControllerReference.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ControllerReference.h"

@implementation ControllerReference

@synthesize name;
@synthesize controllerIndex;
@synthesize controllerThumbnail;
@synthesize controllerThumbnailPath;

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
    return [NSString stringWithFormat:@"%@::%ld::%@", name, (long)controllerIndex, controllerThumbnailPath];
}
@end

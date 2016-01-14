//
//  ThumbnailLoadOperation.m
//  ToloApp
//
//  Created by Torey Lomenda on 7/17/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ThumbnailLoadOperation.h"


@implementation ThumbnailLoadOperation

@synthesize thumbnailView;

#pragma mark - 
#pragma mark init/dealloc Methods
- (id) initWithThumbnailView:(ProductThumbnailView *)aThumbnailView {
    self = [super init];
    
    if (self) {
        self.thumbnailView = aThumbnailView;
    }
    
    return self;
}


#pragma mark - MAIN
- (void) main {
    // Need to create an auto release pool for the operation
    @autoreleasepool {
    
    // Load the image for the preview
        UIImage *thumbnailImage = [thumbnailView loadThumbnailImage];
        
        // On the main thread add the preview image
        [thumbnailView performSelectorOnMainThread:@selector(thumbnailImageLoaded:) withObject:thumbnailImage waitUntilDone:YES];
    
    }
}

@end

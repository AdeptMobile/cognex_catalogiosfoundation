//
//  ResourceLoadPreviewOperation.m
//  ToloApp
//
//  Created by Torey Lomenda on 7/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ResourceLoadPreviewOperation.h"

#import "ContentUtils.h"
@implementation ResourceLoadPreviewOperation

@synthesize previewView;

-(id) initWithPreviewView:(ResourceItemPreviewView *)aPreviewView {
    self = [super init];
    
    if (self) {
        self.previewView = aPreviewView;
    }
    
    return self;
}


- (void) main {
    // Need to create an auto release pool for the operation
    @autoreleasepool {
    
    // Load the image for the preview
        UIImage *previewImage = [previewView loadPreviewImage];
        
        // On the main thread add the preview image
        [previewView performSelectorOnMainThread:@selector(previewImageLoaded:) withObject:previewImage waitUntilDone:YES];
    
    }
}
@end

//
//  ResourceLoadPreviewOperation.h
//  ToloApp
//
//  Created by Torey Lomenda on 7/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ResourceItemPreviewView.h"

@interface ResourceLoadPreviewOperation : NSOperation {
    ResourceItemPreviewView *previewView;
}

@property (nonatomic, strong) ResourceItemPreviewView *previewView;

- (id) initWithPreviewView: (ResourceItemPreviewView *) aPreviewView;

@end

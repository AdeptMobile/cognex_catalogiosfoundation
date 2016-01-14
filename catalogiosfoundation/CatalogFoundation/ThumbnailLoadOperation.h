//
//  ThumbnailLoadOperation.h
//  ToloApp
//
//  Created by Torey Lomenda on 7/17/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductThumbnailView.h"

@interface ThumbnailLoadOperation : NSOperation {
    ProductThumbnailView *thumbnailView;
}

@property (nonatomic, strong) ProductThumbnailView *thumbnailView;

- (id) initWithThumbnailView: (ProductThumbnailView *) aThumbnailView;

@end

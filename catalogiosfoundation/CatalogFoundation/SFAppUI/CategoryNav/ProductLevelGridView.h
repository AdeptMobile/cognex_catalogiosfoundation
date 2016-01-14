//
//  ProductLevelRowView.h
//  SickApp
//
//  Created by Steven McCoole on 2/15/12.
//  Copyright (c) 2012 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Layout.h"
#import "ProductThumbnailView.h"
#import "ProductThumbnailConfig.h"

@interface ProductLevelGridView : UIView {
    id<ProductThumbnailDelegate> __weak thumbnailDelegate;
    
    NSUInteger pageNumber;
    NSUInteger numOfThumbnailViews;
    NSArray *levelPaths;
    NSArray *itemThumbnailViews;
        
    NSOperationQueue *operationQueue;
    
    Layout *layout;
    Layout *portraitLayout;
}

@property (nonatomic, weak) id<ProductThumbnailDelegate> thumbnailDelegate;

@property (nonatomic, assign) NSUInteger pageNumber;
@property (readonly, assign) NSUInteger numOfThumbnailViews;
@property (nonatomic, strong) NSArray *levelPaths;

@property (nonatomic, strong) Layout *layout;
@property (nonatomic, strong) Layout *portraitLayout;

- (id) initWithFrame:(CGRect)frame levelPaths:(NSArray *)paths numberOfThumbnailViews:(NSUInteger)numberOfViews andPage:(NSUInteger)page;

- (void) loadAllThumbnailImages;

@end

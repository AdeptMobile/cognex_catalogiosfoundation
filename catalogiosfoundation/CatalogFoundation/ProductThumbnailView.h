//
//  ContentThumbnailView.h
//  ToloApp
//
//  Created by Torey Lomenda on 6/7/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContentViewBehavior.h"

#import "TabLabelView.h"
#import "ExpandOverlayViewController.h"
#import "ProductThumbnailConfig.h"

@protocol ProductThumbnailDelegate;

@interface ProductThumbnailView : UIView<ExpandFromThumbnail> {
    id<ProductThumbnailDelegate> __weak delegate;
    
    id<ContentViewBehavior> itemContentPath;
    
    UIControl *thumbnailControlView;
    
    UIView *highlightedView;
    UIView *thumbnailView;
    UILabel *itemLabel;
    UIImageView *thumbnailImage;
    UIImageView *thumbnailReflection;
    
    UIActivityIndicatorView *thumbnailImageLoadingView;
    
    CGSize scaleSize;
    CGSize imageSize;
    CGSize reflectionSize;
    CGSize labelSize;
    
    ProductThumbnailConfig *config;
}

@property (nonatomic, strong) id<ContentViewBehavior> itemContentPath;
@property (nonatomic, weak) id<ProductThumbnailDelegate> delegate;
@property (nonatomic, strong) UIImageView *thumbnailImage;

- (id) initWithFrame:(CGRect)frame thumbnailConfig: (ProductThumbnailConfig *)config andItemPath: (id<ContentViewBehavior>)itemPath;

- (UIImage *) getThumbnail;

- (UIImage *) loadThumbnailImage;
- (void) thumbnailImageLoaded: (UIImage *) image;

@end

@protocol ProductThumbnailDelegate <NSObject>

- (void) thumbnailTapped: (ProductThumbnailView *) tappedThumbnailView;

@end

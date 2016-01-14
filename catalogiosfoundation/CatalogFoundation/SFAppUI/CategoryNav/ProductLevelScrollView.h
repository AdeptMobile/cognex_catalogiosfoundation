//
//  ProductLevelScrollView.h
//  SickApp
//
//  Created by Steven McCoole on 4/13/12.
//  Copyright (c) 2012 Object Partners Inc. All rights reserved.
//

#import "ContentViewBehavior.h"

#import "UIViewWithLayout.h"
#import "HorizontalLayout.h"
#import "BorderLayout.h"
#import "FillLayout.h"

#import "GrayPageControl.h"
#import "ProductThumbnailView.h"

#import "GridMainConfig.h"


@interface ProductLevelScrollView : UIViewWithLayout<UIScrollViewDelegate> {
    
}

@property (nonatomic, strong) NSArray * catalogPathsArray;

@property (nonatomic, strong) UIScrollView *levelScrollView;
@property (nonatomic, strong) GrayPageControl *levelPageControl;
@property (nonatomic, assign) BOOL pageControlUsed;
@property (nonatomic, assign) NSInteger numPages;
@property (nonatomic, assign) NSInteger numThumbsPortrait;
@property (nonatomic, assign) NSInteger numThumbsLandscape;

@property (nonatomic, strong) NSMutableArray *subLevelViewItems;

@property (readonly, strong) HorizontalLayout *scrollingLayout;

@property (nonatomic, weak) id<ProductThumbnailDelegate> thumbnailDelegate;

@property (nonatomic, strong) id<ContentViewBehavior> levelPath;
@property (nonatomic, strong) NSArray *mainPanelArray;

- (id) initWithFrame:(CGRect)frame mainPanelArray:(NSArray *)panelArray;
- (id) initWithFrame:(CGRect)frame levelPath:(id<ContentViewBehavior>)path;
- (void) loadSubLevelThumbnailImages;

@property (nonatomic, strong) GridMainConfig *config;

@end

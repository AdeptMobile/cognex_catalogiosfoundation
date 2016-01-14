//
//  ProductLevelRowView.m
//  SickApp
//
//  Created by Steven McCoole on 2/15/12.
//  Copyright (c) 2012 Object Partners Inc. All rights reserved.
//

#import "ProductLevelGridView.h"

#import "ContentViewBehavior.h"
#import "SFAppConfig.h"

#import "BasicCategoryViewConfig.h"

#import "ThumbnailLoadOperation.h"
#import "GridLayout.h"
#import "HorizontalLayout.h"

#define DEFAULT_THUMBNAIL_VIEWS 6
#define DEFAULT_THUMBNAIL_COLS 3

@interface ProductLevelGridView()

- (void) addItemThumbnails;
- (AbstractLayout *)layoutForView:(NSInteger)viewNum;

@end

@implementation ProductLevelGridView
@synthesize thumbnailDelegate;

@synthesize pageNumber;
@synthesize numOfThumbnailViews;
@synthesize levelPaths;

@synthesize layout;
@synthesize portraitLayout;

#pragma mark - init/dealloc methods
- (id) initWithFrame:(CGRect)frame {
    NSAssert(NO, @"Please use initWithFrame: levelPaths: numberOfThumbnailViews: andPage:");
    return nil;
}

- (id) initWithFrame:(CGRect)frame levelPaths:(NSArray *)paths numberOfThumbnailViews:(NSUInteger)numberOfViews andPage:(NSUInteger)page {
    self = [super initWithFrame:frame];
    if (self) {
        if (paths) {
            levelPaths = paths;
        } else {
            levelPaths = nil;
        }
        pageNumber = page;
        numOfThumbnailViews = numberOfViews;
        
        // add thumbnails
        [self addItemThumbnails];
        
        // Initialize the layout for the view
        
        // These layouts should really be calculated but there isn't enough time to come up with a
        // good system for it at the moment.  SMM, Donaldson Torit project 5/1/14
        if (numberOfViews == 12) {
            layout = [GridLayout margin:@"0px 24px 0px 24px" padding:@"0px" valign:@"center" halign:@"center"
                                   rows:[GridRow height:@"33%" cells:
                                         [GridCell width:@"25%" useGridLayoutProps:YES layout:[self layoutForView:0]],
                                         [GridCell width:@"25%" useGridLayoutProps:YES layout:[self layoutForView:1]],
                                         [GridCell width:@"25%" useGridLayoutProps:YES layout:[self layoutForView:2]],
                                         [GridCell width:@"25%" useGridLayoutProps:YES layout:[self layoutForView:3]],
                                         nil],
                      [GridRow height:@"33%" cells:
                       [GridCell width:@"25%" useGridLayoutProps:YES layout:[self layoutForView:4]],
                       [GridCell width:@"25%" useGridLayoutProps:YES layout:[self layoutForView:5]],
                       [GridCell width:@"25%" useGridLayoutProps:YES layout:[self layoutForView:6]],
                       [GridCell width:@"25%" useGridLayoutProps:YES layout:[self layoutForView:7]],
                       nil],
                      [GridRow height:@"34%" cells:
                       [GridCell width:@"25%" useGridLayoutProps:YES layout:[self layoutForView:8]],
                       [GridCell width:@"25%" useGridLayoutProps:YES layout:[self layoutForView:9]],
                       [GridCell width:@"25%" useGridLayoutProps:YES layout:[self layoutForView:10]],
                       [GridCell width:@"25%" useGridLayoutProps:YES layout:[self layoutForView:11]],
                       nil],
                      nil];

        } else if (numberOfViews == 9) {

            layout = [GridLayout margin:@"0px 24px 0px 24px" padding:@"0px" valign:@"center" halign:@"center"
                                   rows:[GridRow height:@"33%" cells:
                                           [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:0]],
                                           [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:1]],
                                           [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:2]],
                                                        nil],
                                        [GridRow height:@"33%" cells:
                                                [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:3]],
                                                [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:4]],
                                                [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:5]],
                                                        nil],
                                        [GridRow height:@"34%" cells:
                                                [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:6]],
                                                [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:7]],
                                                [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:8]],
                                                        nil],
                            nil];

        } else {

            layout = [GridLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"center"
                                   rows:[GridRow height:@"50%" cells:
                                         [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:0]],
                                         [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:1]],
                                         [GridCell width:@"34%" useGridLayoutProps:YES layout:[self layoutForView:2]],
                                         nil],
                      [GridRow height:@"50%" cells:
                       [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:3]],
                       [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:4]],
                       [GridCell width:@"34%" useGridLayoutProps:YES layout:[self layoutForView:5]],
                       nil],
                      nil];
        }

        portraitLayout = [GridLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"center"
                                        rows:[GridRow height:@"33%" cells:
                                              [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:0]],
                                              [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:1]],
                                              [GridCell width:@"34%" useGridLayoutProps:YES layout:[self layoutForView:2]],
                                              nil],
                                            [GridRow height:@"33%" cells:
                                             [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:3]],
                                             [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:4]],
                                             [GridCell width:@"34%" useGridLayoutProps:YES layout:[self layoutForView:5]],
                                             nil],
                                            [GridRow height:@"34%" cells:
                                             [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:6]],
                                             [GridCell width:@"33%" useGridLayoutProps:YES layout:[self layoutForView:7]],
                                             [GridCell width:@"34%" useGridLayoutProps:YES layout:[self layoutForView:8]],
                                             nil],
                           nil];        

        
        // Setup the operation queue
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:4];
    }
    return self;
}

- (void) dealloc {
    
    itemThumbnailViews = nil;
        
    
    
    operationQueue = nil;
    
}

#pragma mark - Accessors/Setters
- (void) setThumbnailDelegate:(id<ProductThumbnailDelegate>)aThumbnailDelegate {
    if (thumbnailDelegate != aThumbnailDelegate) {
        thumbnailDelegate = aThumbnailDelegate;
        if (itemThumbnailViews) {
            for(ProductThumbnailView *thumb in itemThumbnailViews) {
                thumb.delegate = thumbnailDelegate;
            }
        }
    }
}

#pragma mark - Public Methods
- (void) loadAllThumbnailImages {
    for (ProductThumbnailView *thumbnail in itemThumbnailViews) {
        ThumbnailLoadOperation *loadThumbnailOperation = [[ThumbnailLoadOperation alloc] initWithThumbnailView:thumbnail];
        
        [operationQueue addOperation:loadThumbnailOperation];
    }
}

#pragma mark - Layout Code
- (void) layoutSubviews {
    [super layoutSubviews];
    
    // Determine spacing between items based on orientation
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        [portraitLayout layoutForView:self];
    } else {
        [layout layoutForView:self];        
    }
}

#pragma mark - Private Methods
- (void) addItemThumbnails {
    NSInteger startIndex = numOfThumbnailViews * pageNumber;
    if (levelPaths && startIndex < [levelPaths count]) {
        
        // Configure the product thumbnail view
        ProductThumbnailConfig *config = [[ProductThumbnailConfig alloc] init];
        BasicCategoryViewConfig *basicNavConfig = [[SFAppConfig sharedInstance] getBasicCategoryViewConfig];
        
        config.isReflectionOn = basicNavConfig.isReflectionOn;
        config.roundedCorners = basicNavConfig.isRoundedCorners;
        
        config.labelMultiLine = basicNavConfig.isLabelMultiLine;
        config.labelTextColor = basicNavConfig.thumbLabelTextColor;
        config.labelBackgroundColor = basicNavConfig.thumbLabelBackgroundColor;
        config.thumbnailViewBackgroundColor = basicNavConfig.thumbViewBackgroundColor;
        config.highlightBackgroundColor = basicNavConfig.thumbHighlightBackgroundColor;
        config.thumbnailImageBackgroundColor = basicNavConfig.thumbImageBackgroundColor;
        config.backgroundImageName = basicNavConfig.thumbBgImageNamed;
        
        config.margin = basicNavConfig.thumbMargin;
        config.scaleSize = basicNavConfig.thumbScaleSize;
        config.imageSize = basicNavConfig.thumbImageSize;
        config.reflectionSize = basicNavConfig.thumbReflectionSize;
        if (basicNavConfig.thumbLabelFontName && basicNavConfig.thumbLabelFontName > 0) {
            CGFloat fontSize = (basicNavConfig.thumbLabelFontSize > 0) ? basicNavConfig.thumbLabelFontSize : 14.0f;
            config.labelFont = [UIFont fontWithName:basicNavConfig.thumbLabelFontName size:fontSize];
        }
        config.labelSize = basicNavConfig.thumbLabelSize;
        config.labelBackgroundGradient = basicNavConfig.isLabelBackgroundGradient;
        config.iconBorderColor = basicNavConfig.thumbBorderColor;
        config.isLabelAllCaps = basicNavConfig.isLabelAllCaps;
        config.isLabelAboveImage = basicNavConfig.isLabelAboveImage;
        if (basicNavConfig.isLabelShadow) {
            config.labelShadowOffset = basicNavConfig.thumbLabelShadowSize;
            config.labelShadowColor = basicNavConfig.thumbLabelShadowColor;
        }
        
        NSMutableArray *itemsList = [NSMutableArray arrayWithCapacity:numOfThumbnailViews];
        NSInteger currentIndex = startIndex;
        while (currentIndex < [levelPaths count] && currentIndex < (startIndex + numOfThumbnailViews)) {
            ProductThumbnailView *thumbnailView = [[ProductThumbnailView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, basicNavConfig.thumbSize.width, basicNavConfig.thumbSize.height)
                                                                              thumbnailConfig:config
                                                                                  andItemPath:(id<ContentViewBehavior>)[levelPaths objectAtIndex:currentIndex]];
            if (thumbnailDelegate) {
                thumbnailView.delegate = thumbnailDelegate;
            }
            
            [self addSubview:thumbnailView];
            
            [itemsList addObject:thumbnailView];
            thumbnailView = nil;
            currentIndex++;

        }
        itemThumbnailViews = [NSArray arrayWithArray:itemsList];
    }
}

- (AbstractLayout *)layoutForView:(NSInteger)viewNum {
    if (viewNum >= [itemThumbnailViews count]) {
        return nil;
    } else {
        return [HorizontalLayout items:[ViewItem viewItemFor:(UIView *)[itemThumbnailViews objectAtIndex:viewNum]], nil];
    }
}
@end

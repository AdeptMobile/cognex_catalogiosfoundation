//
//  ProductLevelScrollView.m
//  SickApp
//
//  Created by Steven McCoole on 4/13/12.
//  Copyright (c) 2012 Object Partners Inc. All rights reserved.
//

#import "ProductLevelScrollView.h"
#import "SFAppConfig.h"

#import "ContentUtils.h"

#import "UIColor+Chooser.h"

#import "AbstractLayout.h"
#import "ProductLevelGridView.h"

#pragma mark - Private Interface
@interface ProductLevelScrollView()

@property (nonatomic, strong) AbstractLayout *looseLayout; // Used for SICK style layouts
@property (nonatomic, strong) AbstractLayout *tightLayout; // Used for Donaldson style layouts

- (void)changePage:(UIPageControl *)aPageControl;

@end

#pragma mark - Implementation
@implementation ProductLevelScrollView

@synthesize thumbnailDelegate;
@synthesize levelPath;
@synthesize scrollingLayout;

@synthesize levelScrollView;
@synthesize levelPageControl;
@synthesize pageControlUsed;
@synthesize numPages;
@synthesize numThumbsPortrait;  // Number of thumbnails per page Portrait
@synthesize numThumbsLandscape; // Number of thumbnails per page Landscape
@synthesize subLevelViewItems;

@synthesize catalogPathsArray;
@synthesize mainPanelArray;

@synthesize looseLayout;
@synthesize tightLayout;
@synthesize config;


#pragma mark - Constructors
-(id)initWithFrame:(CGRect)frame mainPanelArray:(NSArray *)panelArray{
    self = [super initWithFrame:frame];
    if (self) {
        if (panelArray) {
            mainPanelArray = panelArray;
        }
        else{
            mainPanelArray = nil;
        }

        config = [[SFAppConfig sharedInstance] getMainGridConfig];
        [self setupView];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame levelPath:(id<ContentViewBehavior>)path {
    self = [super initWithFrame:frame];
    if (self) {
        if (path) {
            levelPath = path;
        } else {
            levelPath = nil;
        }
        [self setupView];
    }
    return self;
}

-(void) setupView {
        
    subLevelViewItems = [NSMutableArray arrayWithCapacity:0];
    
    // This is not required.  config background at container view level
    // self.backgroundColor = [[ContentConfig sharedInstance] lookupColorForProperty:@"com.opi.content.productlevelcontentview.bgColor"];
    
    levelScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    levelScrollView.backgroundColor = [UIColor clearColor];
    levelScrollView.maximumZoomScale = 1.0f;
    levelScrollView.minimumZoomScale = 1.0f;
    levelScrollView.clipsToBounds = YES;
    levelScrollView.showsHorizontalScrollIndicator = NO;
    levelScrollView.showsVerticalScrollIndicator = NO;
    levelScrollView.pagingEnabled = YES;
    
    levelPageControl = [[GrayPageControl alloc] initWithFrame:CGRectZero];
    levelPageControl.hidesForSinglePage = YES;
    levelPageControl.numberOfPages = 1;
    levelPageControl.currentPage = 0;
    
    scrollingLayout = [HorizontalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"left" items:nil];
    
    [self addSubview:levelScrollView];
    [self addSubview:levelPageControl];
    
    
    
    looseLayout = [BorderLayout margin:@"0px" padding:@"0px"
                            north:nil
                            south:[BorderRegion size:@"40px" useBorderLayoutProps:NO
                                              layout:[HorizontalLayout margin:@"0px" padding:@"0px"
                                                                       valign:@"center" halign:@"center"
                                                                        items:[ViewItem viewItemFor:levelPageControl], nil]]
                             east:nil
                             west:nil
                           center:[BorderRegion layout:[FillLayout items:[ViewItem viewItemFor:levelScrollView], nil]]];
    
    // By default use the SICK style layout
    layout = looseLayout;

    NSString *tightLayoutFrameHeight = (config.scrollViewFrameOffset == nil) ? @"450px" : [NSString stringWithFormat:@"%@%@", config.tightLayoutFrameHeight.stringValue, @"px"];

    tightLayout = [BorderLayout margin:@"0px" padding:@"0px"
                            north:[BorderRegion size:tightLayoutFrameHeight useBorderLayoutProps:YES layout:[FillLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"center" items:[ViewItem viewItemFor:levelScrollView], nil]]
                            south:[BorderRegion size:@"40px" useBorderLayoutProps:YES layout:
                                   [HorizontalLayout margin:@"0px 0px 5px 0px" padding:@"0px"
                                                     valign:@"bottom" halign:@"center"
                                                      items:[ViewItem viewItemFor:levelPageControl], nil]]
                             east:nil
                             west:nil
                           center:nil];
    
    // Set up the scroll view delegate and the page control action handler
    levelScrollView.delegate = self;
    [levelPageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
}

#pragma mark - Dealloc
- (void) dealloc {
    if (levelPath) {
        levelPath = nil;
    }
    levelPageControl = nil;
    levelScrollView = nil;
    subLevelViewItems = nil;
    scrollingLayout = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Layout Code
- (void) layoutSubviews {
    [super layoutSubviews];
    
    NSUInteger thumbnailsPerPage = 0;
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        //assert(self.numThumbsPortrait > 0);
        thumbnailsPerPage = self.numThumbsPortrait == 0 ? 9 : self.numThumbsPortrait;
    } else {
        //assert(self.numThumbsLandscape > 0);
        thumbnailsPerPage = self.numThumbsLandscape == 0 ? 6 : self.numThumbsLandscape;
    }
    
    // Reset the layout
    [[scrollingLayout viewItems] removeAllObjects];
    [subLevelViewItems removeAllObjects];
    for (UIView *v in levelScrollView.subviews) {
        [v removeFromSuperview];
    }
    
    NSMutableArray *subLevelList = [NSMutableArray arrayWithCapacity:0];
    if (levelPath) {
        if ([levelPath hasCategories]) {
            [subLevelList addObjectsFromArray:[levelPath contentCategories]];
        }
        if ([levelPath hasProducts]) {
            [subLevelList addObjectsFromArray:[levelPath contentProducts]];
            
        }
        if ([levelPath hasIndustries]) {
            [subLevelList addObjectsFromArray:[levelPath contentIndustries]];
        }
        if ([levelPath hasGalleries]) {
            [subLevelList addObjectsFromArray:[levelPath contentGalleries]];
        }
        if ([levelPath hasResources]) {
            NSArray *contentResources = [levelPath contentResources];
            
            for (id<ContentViewBehavior> nextResource in contentResources) {
                if ([[nextResource contentTitle] isEqualToString:@"Videos"]) {
                    [subLevelList addObjectsFromArray:[nextResource contentResourceItems]];
                }
            }
            
        }
    } else if(mainPanelArray) {
        [subLevelList addObjectsFromArray:mainPanelArray];
    }
    
    if (subLevelList && [subLevelList count] > 0) {
        numPages = ([subLevelList count] / thumbnailsPerPage) + (([subLevelList count] % thumbnailsPerPage > 0) ? 1 : 0);
        levelPageControl.numberOfPages = numPages;
        for (int i = 0; i < numPages; i++) {
            ProductLevelGridView *gridView = [[ProductLevelGridView alloc] initWithFrame:CGRectZero 
                                                                              levelPaths:[NSArray arrayWithArray:subLevelList]
                                                                  numberOfThumbnailViews:thumbnailsPerPage
                                                                                 andPage:i];
            if (thumbnailDelegate) {
                gridView.thumbnailDelegate = thumbnailDelegate;
            }
            
            // Hold to be able to message them
            [subLevelViewItems addObject:gridView];
            
            // Add to the scroll view
            [levelScrollView addSubview:gridView];
            
            // Add to the scroll view layout
            [scrollingLayout addItem:[ViewItem viewItemFor:gridView width:@"100%" height:@"100%"]];
            
        }
    }
    
    [layout layoutForView:self];
    
    // Make sure we have views in the scroll view otherwise we'll crash trying to lay out
    // non-existing ones.
    if (subLevelList && [subLevelList count] > 0) {
        [scrollingLayout layoutForView:levelScrollView];
        
        [self loadSubLevelThumbnailImages];
    }
}

#pragma mark - Accessors/Setters
- (void) setThumbnailDelegate:(id<ProductThumbnailDelegate>)aThumbnailDelegate {
    if (thumbnailDelegate != aThumbnailDelegate) {
        thumbnailDelegate = aThumbnailDelegate;
        for (ProductLevelGridView *grid in subLevelViewItems) {
            grid.thumbnailDelegate = thumbnailDelegate;
        }
    }
}

- (void) setNumThumbsLandscape:(NSInteger)aNumThumbsLandscape {
    if (numThumbsLandscape != aNumThumbsLandscape) {
        numThumbsLandscape = aNumThumbsLandscape;
        // For now being bigger means its the Donaldson style layout
        if (numThumbsLandscape > 9) {
            layout = tightLayout;
        } else {
            layout = looseLayout;
        }
    }
}

#pragma mark - Public Methods
- (void) loadSubLevelThumbnailImages {
    for (ProductLevelGridView *view in subLevelViewItems) {
        [view loadAllThumbnailImages];
    }
}

#pragma mark - UIScrollView Delegate Methods
- (void) scrollViewDidScroll:(UIScrollView *)aScrollView {
	
    if (pageControlUsed) {
		// If we scrolled because of the page control just return.
		return;
	}
	
	// Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = aScrollView.frame.size.width;
    int page = floor((aScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    levelPageControl.currentPage = page;
	
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

- (void)changePage:(UIPageControl *)aPageControl {
	NSInteger page = aPageControl.currentPage;
	
	// update the scroll view to the appropriate page
    CGRect frame = levelScrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [levelScrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}


@end

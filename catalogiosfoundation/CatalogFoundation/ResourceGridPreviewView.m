//
//  ResourceGridPreviewView.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 2/2/15.
//  Copyright (c) 2015 Object Partners Inc. All rights reserved.
//

#import "ResourceGridPreviewView.h"

#import "ResourceItemPreviewView.h"
#import "ResourceLoadPreviewOperation.h"

#import "UIImage+Resize.h"
#import "UIView+ViewLayout.h"
#import "UIColor+Chooser.h"
#import "UIImage+Extensions.h"
#import "UIImage+CatalogFoundationResourceImage.h"
#import "NSArray+Helpers.h"

#import "SFAppConfig.h"

#import "ContentUtils.h"
#import "AlertUtils.h"

#define PREVIEW_PORTRAIT_WIDTH 141.0f
#define PREVIEW_LANDSCAPE_WIDTH 238.0f
#define PREVIEW_HEIGHT 183.0f

#define PADDING_HEIGHT 10.0f

@interface ResourceGridPreviewView()

- (void) setupCollectionView;

@end

@implementation ResourceGridPreviewView

@synthesize contentGallery;
@synthesize docPreviewCollectionView;
@synthesize flowLayout;
@synthesize resourcePathList;
@synthesize productNavigationController;
@synthesize loadPreviewsQueue;
@synthesize mailSetupDelegate;

#pragma mark - Initialize/Dealloc
- (id)initWithFrame:(CGRect)frame productNavController:(UIViewController *)productNavController mailSetupDelegate:(NSObject<MailSetupDelegate> *)aMailSetupDelegate andContentGallery:(id<ContentViewBehavior>)aContentGallery {
    self = [super initWithFrame:frame];
    if (self) {
        contentGallery = aContentGallery;
        productNavigationController = productNavController;
        mailSetupDelegate = aMailSetupDelegate;
        previewList = [[NSMutableArray alloc] init];
        loadPreviewsQueue = [[NSOperationQueue alloc] init];
        [loadPreviewsQueue setMaxConcurrentOperationCount:4];
        
        // setup the subviews
        [self setupCollectionView];
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame productNavController:(UIViewController *)productNavController andContentGallery:(id<ContentViewBehavior>)aContentGallery {
    return [self initWithFrame:frame productNavController:productNavController mailSetupDelegate:nil andContentGallery:aContentGallery];
}

- (void)dealloc {
    
    [loadPreviewsQueue cancelAllOperations];
    
    mailSetupDelegate = nil;
    if (docPreviewCollectionView) {
        docPreviewCollectionView.dataSource = nil;
        docPreviewCollectionView.delegate = nil;
    }
}

#pragma mark -
#pragma mark Layout subviews code
- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (docPreviewCollectionView) {
        CGRect collectionFrame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        docPreviewCollectionView.frame = collectionFrame;
    }
}

#pragma mark - Loading Previews logic
- (void) loadPreviews:(NSString *) resourceTitle withResources:(NSArray *) aResourcePathList {
    
    // Will release any previous handle to resources
    self.resourcePathList = aResourcePathList;
    [previewList removeAllObjects];
    
    NSArray *resourcesAvailable = self.resourcePathList;
    NSUInteger idx = 0;
    for (id<ContentViewBehavior>resourceItem in resourcesAvailable) {
        CGFloat width =  PREVIEW_PORTRAIT_WIDTH;
        CGFloat height = PREVIEW_HEIGHT;
        
        ResourcePreviewConfig *config = [[SFAppConfig sharedInstance] getPortfolioResourcePreviewConfig];
        
        if (config.overlayImageForColor) {
            config.overlayColor = [UIColor colorWithPatternImage:[UIImage contentFoundationResourceImageNamed:config.overlayImageForColor]];
        } else if (config.overlayColor) {
            config.overlayColor = [config.overlayColor colorByChangingAlphaTo:0.3f];
        } else {
            config.overlayColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }
        
        //If the input was invalid just use the system font
        if (!config.titleFont) {
            config.titleFont = [UIFont boldSystemFontOfSize:16.0f];
        }
        
        
        ResourceItemPreviewView *previewView = [[ResourceItemPreviewView alloc]
                                                initWithFrame:CGRectMake(0, 0, width, height)
                                                productNavController:self.productNavigationController
                                                andResourceItem:resourceItem andConfig:config];
        previewView.mailSetupDelegate = self.mailSetupDelegate;
        previewView.resourceImageStatusDelegate = self;
        
        previewView.tag = idx;
        previewView.productNavigationController = productNavigationController;
        
        // Start loading the resource image
        ResourceLoadPreviewOperation *operation = [[ResourceLoadPreviewOperation alloc] initWithPreviewView:previewView];
        
        [loadPreviewsQueue addOperation:operation];
        [previewList addObject:previewView];
        idx++;
    }
    
    if (docPreviewCollectionView) {
        [docPreviewCollectionView reloadData];
    }
}

- (void) onPreviewTapped:(UITapGestureRecognizer *)tapGesture {
    NSInteger indexTag = tapGesture.view.tag;
    
    [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Open Document at index: %ld", (long)indexTag] withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
}

#pragma mark - Public Methods
- (BOOL) allPreviewsLoaded {
    BOOL collectionViewLoaded = [previewList count] == [resourcePathList count];
    return collectionViewLoaded && loadPreviewsQueue.operationCount == 0;
}

- (BOOL) allImagesLoaded:(ResourceItemPreviewView *)riPreviewView {
    if ([NSArray isNotEmpty:previewList]) {
        for (ResourceItemPreviewView *view in previewList) {
            if (view.previewImageView == nil || view.previewImageView.image == nil) {
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - UICollectionView Datasource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *resourcesAvailable = self.resourcePathList;
    if (resourcesAvailable) {
        return [resourcesAvailable count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (previewList && indexPath.item < [previewList count]) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"previewCell" forIndexPath:indexPath];
        [cell.contentView addSubview:[previewList objectAtIndex:indexPath.item]];
        return cell;
    }
    return nil;
}

#pragma mark - Private Methods
- (void) setupCollectionView {
    if (docPreviewCollectionView == nil) {
        // Configure layout
        
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [self.flowLayout setItemSize:CGSizeMake(PREVIEW_PORTRAIT_WIDTH, PREVIEW_HEIGHT)];
        [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        self.flowLayout.minimumInteritemSpacing = 10.0f;
        
        docPreviewCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) collectionViewLayout:self.flowLayout];
        [self addSubview:docPreviewCollectionView];
        docPreviewCollectionView.dataSource = self;
        docPreviewCollectionView.delegate = self;
        
        [docPreviewCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"previewCell"];
        docPreviewCollectionView.backgroundColor = [UIColor clearColor];
        
        docPreviewCollectionView.bounces = YES;
        [docPreviewCollectionView setShowsHorizontalScrollIndicator:NO];
        [docPreviewCollectionView setShowsVerticalScrollIndicator:YES];
        [docPreviewCollectionView setPagingEnabled:YES];
    }
}

@end

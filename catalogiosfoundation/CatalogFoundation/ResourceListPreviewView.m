//
//  ResourcePreviewView.m
//  ToloApp
//
//  Created by Torey Lomenda on 6/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ResourceListPreviewView.h"

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

#define LABEL_WIDTH 206.0f
#define LABEL_HEIGHT 30.0f

#define STRIP_PADDING 10.0f

#define PREVIEW_PORTRAIT_WIDTH 141.0f
#define PREVIEW_LANDSCAPE_WIDTH 238.0f
#define PREVIEW_HEIGHT 183.0f

#define PADDING_HEIGHT 10.0f

@interface ResourceListPreviewView()

- (void) setupTabLabel;
- (void) setupStripView;

@end


@implementation ResourceListPreviewView

@synthesize contentProduct;

@synthesize docPreviewStripView;
@synthesize resourcePathList;
@synthesize productNavigationController;
@synthesize loadPreviewsQueue;
@synthesize mailSetupDelegate;

#pragma mark - 
#pragma mark Initialize/Dealloc
- (id)initWithFrame:(CGRect)frame productNavController:(UIViewController *)productNavController mailSetupDelegate:(NSObject<MailSetupDelegate> *)aMailSetupDelegate withTabs:(BOOL)displayTabs andContentProduct:(id<ContentViewBehavior>)aContentProduct {
    self = [super initWithFrame:frame];
    if (self) {
        contentProduct = aContentProduct;
        productNavigationController = productNavController;
        mailSetupDelegate = aMailSetupDelegate;
        
        loadPreviewsQueue = [[NSOperationQueue alloc] init];
        [loadPreviewsQueue setMaxConcurrentOperationCount:4];
        
        // setup the subviews
        if (displayTabs) {
            [self setupTabLabel];
        }
        [self setupStripView];
    }
    return self;

}

- (id)initWithFrame:(CGRect)frame productNavController:(UIViewController *)productNavController mailSetupDelegate:(NSObject<MailSetupDelegate> *)aMailSetupDelegate andContentProduct:(id<ContentViewBehavior>)aContentProduct {
    return [self initWithFrame:frame productNavController:productNavController mailSetupDelegate:aMailSetupDelegate withTabs:YES andContentProduct:aContentProduct];
}

- (id)initWithFrame:(CGRect)frame productNavController:(UIViewController *)productNavController andContentProduct:(id<ContentViewBehavior>)aContentProduct {
    return [self initWithFrame:frame productNavController:productNavController mailSetupDelegate:nil withTabs:YES andContentProduct:aContentProduct];
}

- (void)dealloc {
    
    
    
    [loadPreviewsQueue cancelAllOperations];
    
    mailSetupDelegate = nil;
    
}

#pragma mark -
#pragma mark Loading Previews logic
- (void) loadPreviews:(NSString *) resourceTitle withResources:(NSArray *) aResourcePathList {
    // Set the label text
    resourceLabel.text = resourceTitle;
    
    // Will release any previous handle to resources
    self.resourcePathList = aResourcePathList;
    
    if (docPreviewStripView) {
        [docPreviewStripView reloadData];
    }
}

- (void) onPreviewTapped:(UITapGestureRecognizer *)tapGesture {
    NSInteger indexTag = tapGesture.view.tag;
    
    [AlertUtils showModalAlertMessage:[NSString stringWithFormat:@"Open Document at index: %ld", (long)indexTag] withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
}

#pragma mark - 
#pragma mark Public Methods
- (BOOL) allPreviewsLoaded {
    BOOL stripViewLoaded = [docPreviewStripView.itemViews count] == [resourcePathList count];
    return stripViewLoaded && loadPreviewsQueue.operationCount == 0;
}

#pragma mark -
#pragma mark Strip View Datasource
- (NSUInteger) totalItemsInStripView:(StripView *)stripView {
    return [self numberOfItemsToLoadInStripView:stripView];
}
- (NSUInteger) numberOfItemsToLoadInStripView:(StripView *)stripView {
    NSArray *resourcesAvailable = self.resourcePathList;
    
    if (resourcesAvailable) {
        return [resourcesAvailable count];
    }
    
    return 0;
}

- (UIView *) stripView:(StripView *)stripView itemViewForIndex:(NSUInteger)index {
    NSArray *resourcesAvailable = self.resourcePathList;
    
    if (resourcesAvailable && index < [resourcesAvailable count]) {
        id<ContentViewBehavior> resourceItem = (id<ContentViewBehavior>)[resourcesAvailable objectAtIndex:index];
        CGFloat width =  PREVIEW_PORTRAIT_WIDTH;
        CGFloat height = stripView.bounds.size.height - (2 * PADDING_HEIGHT);
        
        if ([[resourceItem contentType] isEqualToString:CONTENT_TYPE_INDUSTRY_PRODUCT]) {
            UIImage *preview = [UIImage imageWithContentsOfFile:[resourceItem contentThumbNail]];
            if (preview && preview.size.width > width) {
                width = height * preview.size.width/preview.size.height;
            }
        } else {
            NSString *resourcePath = [resourceItem contentFilePath];
            
            // Determine if preview should be in lanscape or portrait (PDFs will always be portrait)
            if (![ContentUtils isPDFFile:resourcePath]) {
                if ([ContentUtils isImageFile:resourcePath]) {
                    UIImage *preview = [UIImage imageWithContentsOfFile:resourcePath];
                    
                    if (preview && preview.size.width > width) {
                        width = height * preview.size.width/preview.size.height;
                    }
                } else if ([ContentUtils isMovieFile:resourcePath]) {
                    width = PREVIEW_LANDSCAPE_WIDTH;
                }
            }
        }
        
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
        
        previewView.tag = index;
        previewView.productNavigationController = productNavigationController;
        
        // Start loading the resource image
        ResourceLoadPreviewOperation *operation = [[ResourceLoadPreviewOperation alloc] initWithPreviewView:previewView];
        
        [loadPreviewsQueue addOperation:operation];
        return previewView;
    }  
    
    return nil;
}

- (BOOL) allImagesLoaded:(ResourceItemPreviewView *)riPreviewView {
    NSArray *previewItems = docPreviewStripView.itemViews;
    if ([NSArray isNotEmpty:previewItems]) {
        for (ResourceItemPreviewView *view in previewItems) {
            if (view.previewImageView == nil || view.previewImageView.image == nil) {
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark -
#pragma mark Layout subviews code
- (void) layoutSubviews {
    [super layoutSubviews];
    
    if (docPreviewStripView) {
        CGRect stripFrame = CGRectMake(0, LABEL_HEIGHT, self.bounds.size.width, self.bounds.size.height - LABEL_HEIGHT);
        
        docPreviewStripView.frame = stripFrame;
        [docPreviewStripView applyBorderStyle:[[SFAppConfig sharedInstance] getPortfolioResourcePreviewConfig].docStripBorderColor withBorderWidth:2.0f withShadow:NO];
    }
}

#pragma mark -
#pragma mark Private Methods
- (void) setupTabLabel {
    ResourcePreviewConfig *config = [[SFAppConfig sharedInstance] getPortfolioResourcePreviewConfig];
    resourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, LABEL_WIDTH, LABEL_HEIGHT)];
    resourceLabel.textColor = config.docStripTabTextColor;
    resourceLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    resourceLabel.textAlignment = NSTextAlignmentCenter;
    
    if ([contentProduct hasResources]) {
        // Find out if we have an resource groups that need to be excluded from the menu.
        NSArray *excludedResources = [[SFAppConfig sharedInstance] getExcludedResources];
        for (id<ContentViewBehavior> resourceGroup in [contentProduct contentResources]) {
            BOOL display = YES;
            if (excludedResources && [excludedResources count] > 0) {
                NSString *resourceGroupTitle = [resourceGroup contentTitle];
                for (NSString *ex in excludedResources) {
                    if ([ex isEqualToString:resourceGroupTitle]) {
                        display = NO;
                        break;
                    }
                }
            }
            if (display) {
                resourceLabel.text = [resourceGroup contentTitle];
                break;
            }
        }
    }
    resourceLabel.backgroundColor = [UIColor clearColor];
    resourceLabel.adjustsFontSizeToFitWidth = YES;
    
    resourceTab = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LABEL_WIDTH, LABEL_HEIGHT)];
    resourceTab.backgroundColor = config.docStripTabBgColor;
    
    [self addSubview:resourceTab];
    [self addSubview:resourceLabel];
}

- (void) setupStripView {
    ResourcePreviewConfig *config = [[SFAppConfig sharedInstance] getPortfolioResourcePreviewConfig];
    
    // TL:  Needed to start with a zero frame in order to layout properly with our Layout Manager code
    self.docPreviewStripView = [[StripView alloc] initWithFrame:CGRectZero];
    
    docPreviewStripView.delegate = self;
    docPreviewStripView.datasource = self;
    
    docPreviewStripView.paddingTop = STRIP_PADDING;
    docPreviewStripView.paddingBottom = STRIP_PADDING;
    docPreviewStripView.paddingLeft = STRIP_PADDING;
    docPreviewStripView.paddingRight = STRIP_PADDING;
    
    if (config.docStripBgImageNamed) {
        [docPreviewStripView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage contentFoundationResourceImageNamed:config.docStripBgImageNamed]]];
    }
    
    [self addSubview:docPreviewStripView];
}

@end

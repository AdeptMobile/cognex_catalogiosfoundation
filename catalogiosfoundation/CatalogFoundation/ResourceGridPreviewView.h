//
//  ResourceGridPreviewView.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 2/2/15.
//  Copyright (c) 2015 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ContentViewBehavior.h"
#import "ResourceItemPreviewView.h"
#import "MailSetupDelegate.h"

@interface ResourceGridPreviewView : UIView<UICollectionViewDataSource, UICollectionViewDelegate, ResourceImageStatusDelegate> {
    @private
    NSMutableArray *previewList;
    
    @public
    id<ContentViewBehavior> contentGallery;
    
    UICollectionView *docPreviewCollectionView;
    UICollectionViewFlowLayout *flowLayout;
    
    NSArray *resourcePathList;
    
    UIViewController *__weak productNavigationController;
    
    NSOperationQueue *loadPreviewsQueue;
    
    NSObject<MailSetupDelegate> *__weak mailSetupDelegate;
}

@property (nonatomic, strong) id<ContentViewBehavior> contentGallery;

@property (nonatomic, strong) UICollectionView *docPreviewCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) NSArray *resourcePathList;
@property (nonatomic, strong) NSOperationQueue *loadPreviewsQueue;

// We want a pointer to our navigation controller (this class does not own it)
@property (nonatomic, weak) UIViewController *productNavigationController;
@property (nonatomic, weak) NSObject<MailSetupDelegate> *mailSetupDelegate;

- (id)initWithFrame:(CGRect)frame productNavController:(UIViewController *)productNavController mailSetupDelegate:(NSObject<MailSetupDelegate> *)aMailSetupDelegate andContentGallery:(id<ContentViewBehavior>)aContentGallery;

- (id) initWithFrame:(CGRect)frame productNavController: (UIViewController *)productNavController andContentGallery:(id<ContentViewBehavior>) aContentGallery;

- (void) loadPreviews: (NSString *) resourceTitle withResources: (NSArray *) aResourcePathList;

- (void) onPreviewTapped:(UITapGestureRecognizer *) tapGesture;

- (BOOL) allPreviewsLoaded;

@end

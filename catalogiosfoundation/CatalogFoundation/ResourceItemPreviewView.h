//
//  ResourceItemPreviewView.h
//  ToloApp
//
//  Created by Torey Lomenda on 7/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AFNetworking/AFNetworking.h>
#import "UIProgressView+AFNetworking.h"

#import "UICustomLabel.h"

#import "ContentViewBehavior.h"

#import "ResourcePreviewController.h"
#import "ExpandOverlayViewController.h"
#import "MailSetupDelegate.h"
#import "ResourcePreviewConfig.h"
#import "AlertProgressHUD.h"

@class ResourceItemPreviewView;

@protocol ResourceImageStatusDelegate <NSObject>

- (BOOL) allImagesLoaded:(ResourceItemPreviewView *)riPreviewView;

@end

@interface ResourceItemPreviewView : UIView<UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate> {
    
    id<ContentViewBehavior> resourceItem;
    
    ResourcePreviewConfig *viewConfig;
    
    NSURL *resourceItemUrl;
    NSString *resourceItemLabel;
    NSString *resourcePreviewImagePath;
    NSURL *resourceExternalLink;
    NSNumber *resourceStartPage;
    
    UIView *highlightedView;
    UIImageView *previewImageView;
    
    UIView *labelTabView;
    UICustomLabel *previewLabel;
    
    UITextView *previewTextView;
    UIActivityIndicatorView *previewImageLoadingView;
    
    UIViewController *__weak productNavigationController;
    UIDocumentInteractionController *docInteractionController;
    
    ExpandOverlayViewController *overlayController;
    
    NSObject<MailSetupDelegate> *__weak mailSetupDelegate;
    
    // A Handle to the ResourceListPreviewView to check for all images being loaded
    NSObject<ResourceImageStatusDelegate> *__weak resourceImageStatusDelegate;
    
    AlertProgressHUD *downloadProgressView;
    UIView *downloadCustomView;
    UILabel *downloadProgressLabel;
    UIProgressView *downloadProgress;
    UIButton *downloadCancelButton;
    AFHTTPRequestOperation *currentOperation;
}

@property (nonatomic, strong) UIImageView *previewImageView;

@property (nonatomic, weak) UIViewController *productNavigationController;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;

@property (nonatomic, weak) NSObject<ResourceImageStatusDelegate> *resourceImageStatusDelegate;

@property (nonatomic, strong) ExpandOverlayViewController *overlayController;
@property (nonatomic, weak) NSObject<MailSetupDelegate> *mailSetupDelegate;

- (id) initWithFrame:(CGRect)frame productNavController: (UIViewController *) productNavController andResourceItem:(id<ContentViewBehavior>)aResourceItem;
- (id) initWithFrame:(CGRect)frame productNavController:(UIViewController *)productNavController andResourceItem:(id<ContentViewBehavior>)aResourceItem andConfig:(ResourcePreviewConfig *)config;
- (UIImage *) loadPreviewImage;
- (void) previewImageLoaded: (UIImage *) image;
@end

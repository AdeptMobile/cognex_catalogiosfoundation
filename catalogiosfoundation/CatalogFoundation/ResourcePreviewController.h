//
//  ProductContentViewController.h
//  ToloApp
//
//  Created by Torey Lomenda on 6/3/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import <MessageUI/MessageUI.h>
#import "MailSetupDelegate.h"
#import "ResourcePreviewToolbarView.h"

@interface ResourcePreviewController : UIViewController<MFMailComposeViewControllerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate, ResourcePreviewToolbarDelegate, UIScrollViewDelegate> {
    NSURL *documentUrl;
    
    UIView *contentView;
    UIView *previewView;
    
    UIImageView *previewImageView;
    
    // If Quick Look Framework is required
    QLPreviewController *previewController;
    
    ResourcePreviewToolbarView *toloToolbar;
    
    BOOL doResizeOnWillAppear;
    
    NSObject<MailSetupDelegate> *__weak mailSetupDelegate;
}

@property (nonatomic, weak) NSObject<MailSetupDelegate> *mailSetupDelegate;

- (id) initWithUrl: (NSURL *) url;

@end

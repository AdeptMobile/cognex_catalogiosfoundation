//
//  ToloWebViewController.h
//  ToloApp
//
//  Created by Torey Lomenda on 6/26/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "CompanyWebViewConfig.h"

enum {
    ToloWebViewControllerAvailableActionsNone             = 0,
    ToloWebViewControllerAvailableActionsOpenInSafari     = 1 << 0,
    ToloWebViewControllerAvailableActionsMailLink         = 1 << 1,
    ToloWebViewControllerAvailableActionsCopyLink         = 1 << 2
};

typedef NSUInteger ToloWebViewControllerAvailableActions;

@interface CompanyWebViewController : UIViewController<UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    NSURL *toloWebUrl;
    
    UIWebView *toloWebView;
    UIToolbar *toolbar;
    UIActivityIndicatorView *loadingWebPageIndicator;
    
    UIBarButtonItem *closeButton;
    UIBarButtonItem *backBarButtonItem;
    UIBarButtonItem *forwardBarButtonItem;
    UIBarButtonItem *refreshBarButtonItem;
    UIBarButtonItem *stopBarButtonItem;
    UIBarButtonItem *actionBarButtonItem;
    UIBarButtonItem *sketchBarButtonItem;
    
    ToloWebViewControllerAvailableActions availableActions;
    
    UIImage * logoImage;
    
    CompanyWebViewConfig *config;
}

@property (nonatomic, strong) NSURL *toloWebUrl;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *closeButton;
@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *sketchBarButtonItem;
@property (nonatomic, readwrite) ToloWebViewControllerAvailableActions availableActions;
@property (nonatomic, strong)     UIImage * logoImage;

@property (nonatomic, strong) CompanyWebViewConfig *config;

- (id) initWithUrl: (NSURL *) url andConfig: (CompanyWebViewConfig *) aConfig;
- (id) initWithUrl: (NSURL *) url andLogo:(UIImage *) logo andConfig: (CompanyWebViewConfig *) aConfig;
@end

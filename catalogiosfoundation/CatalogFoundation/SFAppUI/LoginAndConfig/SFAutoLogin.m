//
//  SFAutoLogin.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 7/3/15.
//  Copyright (c) 2015 Object Partners Inc. All rights reserved.
//

#import "SFAutoLogin.h"

#import "SFAppConfig.h"

#import "ContentUtils.h"
#import "AlertUtils.h"

#import "UIView+ViewLayout.h"
#import "NSString+Extensions.h"

#import <AFNetworking/AFNetworking.h>

@implementation SFAutoLogin

#pragma mark - Standard Login Operation
+ (void) loginWith: (NSString *) username andPassword: (NSString *) password
    showAlertForErrors: (BOOL) showErrorAlert then: (void (^)(BOOL isLoginSuccessful)) executeBlock {
    
    [SFAutoLogin saveCredentialsFor:username andPassword:password];
    
    [SFAutoLogin attachLoggingInView];
    
    NSURL *checkUserUrl = [[SFAppConfig sharedInstance] getUserCheckUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:checkUserUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
    [request setHTTPMethod:@"HEAD"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
   
    NSURLCredential *credential = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceForSession];
    [operation setCredential:credential];
    
    NSString *authFailMsg = NSLocalizedString(@"Login failure.  Please check your username and password and try again.  If you need support, request it by selecting \"Need Help Logging In?\" below.", nil);
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([operation.response statusCode] == 200) {
            [SFAutoLogin setLastLoginTime];
            
            [SFAutoLogin detachLoggingInView];
            
            executeBlock(YES);
        } else {
            if (showErrorAlert) {
                [AlertUtils showModalAlertMessage:authFailMsg withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
            }
            NSLog(@"Login got non-200 status code: %ld", (long)operation.response.statusCode);
            
            [SFAutoLogin clearAutoLogin];
            executeBlock(NO);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (showErrorAlert) {
            [AlertUtils showModalAlertMessage:authFailMsg withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
        }
        
        NSLog(@"Login failure, url: %@, status code: %ld, message: %@", [checkUserUrl absoluteString], (long)operation.response.statusCode, error.localizedDescription);
        
        [SFAutoLogin clearAutoLogin];
        executeBlock(NO);
    }];
    
    [operation start];
}

#pragma mark - Auto Login Operations
+ (BOOL) doAutoLogin {
    SFAppConfig *config = [SFAppConfig sharedInstance];
    
    if (config.isAuthRememberLoginEnabled && [NSString isNotEmpty:[SFAutoLogin getAutoLoginUserName]]) {
        return YES;
    }
    
    return NO;
}

+ (void) autoLoginShowAlertForErrors:(BOOL)showErrorAlert then:(void (^)(BOOL))executeBlock {
    // Kickoff Auto Login Process
    NSString *username = [SFAutoLogin getAutoLoginUserName];
    NSString *password = [SFAutoLogin getAutoLoginPassword];
    
    [SFAutoLogin loginWith:username andPassword:password showAlertForErrors:showErrorAlert then:^(BOOL isLoginSuccessful) {
        executeBlock(isLoginSuccessful);
    }];
}

+ (void) attachLoggingInView {
    // Attach a auto login view to the visible view....Kickoff autologin
    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    
    if ([appDelegate respondsToSelector:@selector(window)]) {
        UIViewController *visibleController = nil;
        UIViewController *rootController = ((UIWindow *) [appDelegate window]).rootViewController;
        
        if ([rootController isKindOfClass:[UINavigationController class]]) {
            visibleController = ((UINavigationController *) rootController).visibleViewController;
        } else {
            visibleController = rootController;
        }
        
        SFAutoLoginView *autoLoginView = [[SFAutoLoginView alloc] initWithFrame:visibleController.view.bounds];
        [visibleController.view addSubview:autoLoginView];
        [visibleController.view bringSubviewToFront:autoLoginView];
        [visibleController.view setNeedsLayout];
    }
}
+ (void) detachLoggingInView {
    // Remove Auto Login View if visible
    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    
    if ([appDelegate respondsToSelector:@selector(window)]) {
        UIViewController *visibleController = nil;
        UIViewController *rootController = ((UIWindow *) [appDelegate window]).rootViewController;
        
        if ([rootController isKindOfClass:[UINavigationController class]]) {
            visibleController = ((UINavigationController *) rootController).visibleViewController;
        } else {
            visibleController = rootController;
        }
        
        for (UIView *subview in visibleController.view.subviews) {
            if ([subview isKindOfClass:[SFAutoLoginView class]]) {
                [subview removeFromSuperview];
            }
        }
        [visibleController.view setNeedsLayout];
    }
}

+ (void) clearAutoLogin {
    [ContentUtils removeUsernameInKeychain];
    [ContentUtils removePasswordInKeychain];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastLoginTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Remove Auto Login View if visible
    [SFAutoLogin detachLoggingInView];
}

#pragma mark - Auto Login Support
+ (void) saveCredentialsFor: (NSString *) username andPassword: (NSString *) password {
    SFAppConfig *config = [SFAppConfig sharedInstance];
    
    if (config.isAuthRememberLoginEnabled) {
        [ContentUtils setUsernameInKeychain:username];
        [ContentUtils setPasswordInKeychain:password];
    }
}
+ (void) setLastLoginTime {
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate new] forKey:@"lastLoginTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSDate *) getLastLoginTime {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"lastLoginTime"];
}

+ (NSString *) getAutoLoginUserName {
    NSString *username = [ContentUtils getUsernameFromKeychain];
    return username;
}
+ (NSString *) getAutoLoginPassword {
    NSString *password = [ContentUtils getPasswordFromKeychain];
    return password;
}
@end

@implementation SFAutoLoginView

#pragma mark - init/dealloc Methods
/** Initializes the view with CGRect frame.
 *
 * @param frame CGRect
 *
 * @return id
 */
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0 blue:0/255.0 alpha:0.6f];
        SFLoginConfig *config = [[SFAppConfig sharedInstance] getLoginViewConfig];
        
        // Initialize subviews
        self.loginActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.loginMsgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        // Configure Subviews
        [_loginActivityIndicator startAnimating];
        
        _loginMsgLabel.backgroundColor = [UIColor clearColor];
        _loginMsgLabel.font = [UIFont fontWithName:config.textFieldFont size:18.0f];
        _loginMsgLabel.textColor = [UIColor whiteColor];
        _loginMsgLabel.textAlignment = NSTextAlignmentCenter;
        _loginMsgLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Authorizing for %@", nil), [SFAutoLogin getAutoLoginUserName]];
        
        // Assemble Views
        [self addSubview:_loginActivityIndicator];
        [self addSubview:_loginMsgLabel];
    }
    return self;
}

/** dealloc/cleanup the instance */
- (void) dealloc {
}

#pragma mark - Subview Mgmt
- (void) removeSubviews {
    if (self.subviews.count > 0) {
        for (UIView *subview in self.subviews) {
            [subview removeFromSuperview];
        }
    }
}

#pragma mark - Custom Drawing Code
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark - Layout Code
/** Override layoutSubviews to control subview layout
 *
 */
- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    if (!CGRectIsEmpty(bounds)) {
        // Center the activity indicator
        [self.loginActivityIndicator centerOn:self];
        
        CGRect activityFrame = self.loginActivityIndicator.frame;
        self.loginMsgLabel.frame = CGRectMake(0, activityFrame.origin.y + activityFrame.size.height, bounds.size.width, 44.0f);
    }
}

#pragma mark - Accessor Methods

#pragma mark - Public Methods

#pragma mark - Private Methods

@end

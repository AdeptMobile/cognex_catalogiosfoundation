//
//  SFAutoLogin.h
//  CatalogFoundation
//
//  Created by Torey Lomenda on 7/3/15.
//  Copyright (c) 2015 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFAutoLogin : NSObject

#pragma mark - Standard Login Operation
+ (void) loginWith: (NSString *) username andPassword: (NSString *) password showAlertForErrors: (BOOL)
            showErrorAlert then: (void (^)(BOOL isLoginSuccessful)) executeBlock;

#pragma mark - Auto Login Operations
+ (BOOL) doAutoLogin;
+ (void) autoLoginShowAlertForErrors: (BOOL) showErrorAlert then: (void (^)(BOOL isLoginSuccessful)) executeBlock;
+ (void) clearAutoLogin;

#pragma mark - Auto Login Support
+ (void) saveCredentialsFor: (NSString *) username andPassword: (NSString *) password;
+ (void) setLastLoginTime;
+ (NSDate *) getLastLoginTime;

+ (NSString *) getAutoLoginUserName;
+ (NSString *) getAutoLoginPassword;

@end

@interface SFAutoLoginView : UIView

@property (nonatomic, strong) UIActivityIndicatorView *loginActivityIndicator;
@property (nonatomic, strong) UILabel *loginMsgLabel;

@end

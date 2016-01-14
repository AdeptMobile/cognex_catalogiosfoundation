//
//  SFLoginView.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/4/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewWithLayout.h"
#import "ExtUITextField.h"

@protocol SFLoginViewDelegate <NSObject>

- (void)loginButtonTapped:(id)loginButton;
- (void)requestLoginButtonTapped:(id)requestLoginButton;
- (void)needHelpButtonTapped:(id)needHelpButton;

@end

@interface SFLoginView : UIViewWithLayout

@property (nonatomic, weak) id<SFLoginViewDelegate> delegate;

@property (nonatomic, strong) ExtUITextField *usernameField;
@property (nonatomic, strong) ExtUITextField *passwordField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UILabel *requestLoginLabel;
@property (nonatomic, strong) UIButton *requestLoginButton;
@property (nonatomic, strong) UIButton *needHelpButton;

@end

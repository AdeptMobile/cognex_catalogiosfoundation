//
//  SFLoginView.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/4/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import "SFLoginView.h"
#import "SFLoginConfig.h"
#import "SFAppConfig.h"
#import "UIImage+Extensions.h"

#import "GridLayout.h"
#import "HorizontalLayout.h"

@interface SFLoginView()

- (void)loginButtonTapped:(id)loginButton;
- (void)requestLoginButtonTapped:(id)requestLoginButton;
- (void)needHelpButtonTapped:(id)needHelpButton;

@end

@implementation SFLoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        SFLoginConfig *config = [[SFAppConfig sharedInstance] getLoginViewConfig];
        
        if (config.bgImageNamed) {
            self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageResource:config.bgImageNamed]];
        } else {
            self.backgroundColor = config.bgColor;
        }
        
        self.usernameField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
        self.usernameField.edgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        self.usernameField.backgroundColor = config.textFieldBgColor;
        self.usernameField.font = [UIFont fontWithName:config.textFieldFont size:[config.textFieldFontSize floatValue]];
        self.usernameField.textColor = config.textFieldTextColor;
        self.usernameField.textAlignment = NSTextAlignmentLeft;
        self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.usernameField.placeholder = NSLocalizedString(@"Username", nil);
        [self addSubview:self.usernameField];
        
        self.passwordField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
        self.passwordField.edgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
        self.passwordField.backgroundColor = config.textFieldBgColor;
        self.passwordField.font = [UIFont fontWithName:config.textFieldFont size:[config.textFieldFontSize floatValue]];
        self.passwordField.textColor = config.textFieldTextColor;
        self.passwordField.textAlignment = NSTextAlignmentLeft;
        self.passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.passwordField.secureTextEntry = YES;
        self.passwordField.placeholder = NSLocalizedString(@"Password", nil);
        [self addSubview:self.passwordField];
        
        self.loginButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.loginButton setImage:[UIImage imageResource:config.loginButtonBgImage] forState:UIControlStateNormal];
        [self.loginButton addTarget:self action:@selector(loginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.loginButton];
        
        self.requestLoginLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.requestLoginLabel.backgroundColor = [UIColor clearColor];
        self.requestLoginLabel.font = [UIFont fontWithName:config.textFieldFont size:18.0f];
        self.requestLoginLabel.textColor = config.textFieldRequestTextColor;
        self.requestLoginLabel.textAlignment = NSTextAlignmentCenter;
        self.requestLoginLabel.text = NSLocalizedString(@"Don't have a Login?", nil);
        [self addSubview:self.requestLoginLabel];
        
        self.requestLoginButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.requestLoginButton setImage:[UIImage imageResource:config.requestLoginButtonImage] forState:UIControlStateNormal];
        [self.requestLoginButton addTarget:self action:@selector(requestLoginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.requestLoginButton];
        
        self.needHelpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.needHelpButton setTitleColor:config.textFieldRequestTextColor forState:UIControlStateNormal];
        
        [self.needHelpButton setBackgroundColor:[UIColor clearColor]];
        self.needHelpButton.titleLabel.font = [UIFont fontWithName:config.textFieldFont size:18.0f];
        [self.needHelpButton setTitleColor:config.helpTextColor forState:UIControlStateNormal];
        [self.needHelpButton setTitle:(NSLocalizedString(@"Need Help Logging In?", nil)) forState:UIControlStateNormal];
        [self.needHelpButton addTarget:self action:@selector(needHelpButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.needHelpButton];
        
        layout = [GridLayout margin:@"0px" padding:@"10px 0px 10px 0px" valign:@"bottom" halign:@"center"
                  rows:[GridRow height:@"520px"
                                          cells:[GridCell width:@"100%" horizontalLayoutFor:[ViewItem viewItemFor:nil], nil], nil],
                       [GridRow height:@"60px" cells:
                                                [GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"left" items:
                                                    [ViewItem viewItemFor:nil width:@"184px" height:@"60px"],
                                                    [ViewItem viewItemFor:self.usernameField width:@"260px" height:@"44px"],
                                                    [ViewItem viewItemFor:nil width:@"22px" height:@"60px"],
                                                    [ViewItem viewItemFor:self.passwordField width:@"260px" height:@"44px"],
                                                    [ViewItem viewItemFor:nil width:@"44px" height:@"60px"],
                                                    [ViewItem viewItemFor:self.loginButton width:@"160px" height:@"60px"],
                                                 nil]], nil],
                      [GridRow height:@"26px" cells:
                                               [GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"left" items:
                                                [ViewItem viewItemFor:nil width:@"196px" height:@"26px"],
                                                [ViewItem viewItemFor:self.needHelpButton width:@"224px" height:@"26px"],
                                                
                                                nil]], nil],
                  [GridRow height:@"28px"
                            cells:[GridCell width:@"100%" horizontalLayoutFor:[ViewItem viewItemFor:nil], nil], nil],
        
                       [GridRow height:@"30px" cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"center" items:[ViewItem viewItemFor:self.requestLoginLabel width:@"366px" height:@"30px"], nil]], nil],
                  [GridRow height:@"60px" cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"bottom" halign:@"center" items:[ViewItem viewItemFor:self.requestLoginButton width:@"366px" height:@"60px"],nil]], nil],
                  nil];
        
    }
    return self;
}

#pragma mark - layout code
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [layout layoutForView:self];
}

#pragma mark - Button event handlers
- (void)loginButtonTapped:(id)loginButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginButtonTapped:)]) {
        [self.delegate loginButtonTapped:loginButton];
    }
}

- (void)requestLoginButtonTapped:(id)requestLoginButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestLoginButtonTapped:)]) {
        [self.delegate requestLoginButtonTapped:requestLoginButton];
    }
}

- (void)needHelpButtonTapped:(id)needHelpButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(needHelpButtonTapped:)]) {
        [self.delegate needHelpButtonTapped:needHelpButton];
    }
}
@end

//
//  SFAppLayoutView.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/11/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import "SFAppSetupView.h"
#import "VerticalLayout.h"
#import "UIImage+Extensions.h"
#import "UIImage+RoundedCorner.h"
#import "UIScreen+Helpers.h"
#import "SFAppConfig.h"
#import "SFAppSetupConfig.h"

@interface SFAppSetupView()

- (void)handleDownloadButtonPressed:(id)dlButton;
- (void)handlePasswordButtonPressed:(id)pwButton;
- (void)handleLogoutButtonPressed:(id)logOutButton;

@end

@implementation SFAppSetupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        SFAppSetupConfig *config = [[SFAppConfig sharedInstance] getAppSetupViewConfig];
        
        // TODO: Make configurable in the future
        self.backgroundColor = config.bgColor;
        
        CGFloat multiplier = 1.0f;
        if ([UIScreen isRetinaDisplay]) {
            multiplier = 2.0f;
        }
        
        UIImage *buttonImage = [UIImage imageWithColor:config.buttonColor ofSize:CGSizeMake(186.0f * multiplier, 32.0f * multiplier)];
        UIImage *rndImage = [buttonImage roundedCornerImage:4 * (NSInteger)multiplier borderSize:0];
        
        BOOL authRequired = [[SFAppConfig sharedInstance] isAuthRequiredForJSON];
        BOOL downloadFilteringEnabled = [[SFAppConfig sharedInstance] isDownloadFilteringEnabled];
        
        UIButton *dlButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dlButton setBackgroundImage:rndImage forState:UIControlStateNormal];
        dlButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        dlButton.titleLabel.font = [UIFont fontWithName:config.buttonTextFont size:15.0f];
        dlButton.titleLabel.textColor = config.buttonTextColor;
        [dlButton setTitle:NSLocalizedString(@"Download Files", nil) forState:UIControlStateNormal];
        [dlButton addTarget:self action:@selector(handleDownloadButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        if (downloadFilteringEnabled) {
            [self addSubview:dlButton];
        }
        
        UIButton *pwButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [pwButton setBackgroundImage:rndImage forState:UIControlStateNormal];
        pwButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        pwButton.titleLabel.font = [UIFont fontWithName:config.buttonTextFont size:15.0f];
        pwButton.titleLabel.textColor = config.buttonTextColor;
        [pwButton setTitle:NSLocalizedString(@"Change Password", nil) forState:UIControlStateNormal];
        [pwButton addTarget:self action:@selector(handlePasswordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        if (authRequired) {
            [self addSubview:pwButton];
        }
        
        UIButton *loButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loButton setBackgroundImage:rndImage forState:UIControlStateNormal];
        loButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        loButton.titleLabel.font = [UIFont fontWithName:config.buttonTextFont size:15.0f];
        loButton.titleLabel.textColor = config.buttonTextColor;
        [loButton setTitle:NSLocalizedString(@"Log Out", nil) forState:UIControlStateNormal];
        [loButton addTarget:self action:@selector(handleLogoutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        if (authRequired) {
            [self addSubview:loButton];
        }
        
        if (authRequired == YES && downloadFilteringEnabled == YES) {
            layout = [VerticalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"center"
                                      items:
                      [ViewItem viewItemFor:nil width:@"100%" height:@"54px"],
                      [ViewItem viewItemFor:dlButton width:@"186px" height:@"32px"],
                      [ViewItem viewItemFor:nil width:@"100%" height:@"32px"],
                      [ViewItem viewItemFor:pwButton width:@"186px" height:@"32px"],
                      [ViewItem viewItemFor:nil width:@"100%" height:@"32px"],
                      [ViewItem viewItemFor:loButton width:@"186px" height:@"32px"],
                      nil];
        } else if (authRequired == YES && downloadFilteringEnabled == NO) {
            // Only the change password and logout buttons showing
            layout = [VerticalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"center"
                                      items:
                      [ViewItem viewItemFor:nil width:@"100%" height:@"86px"],
                      [ViewItem viewItemFor:pwButton width:@"186px" height:@"32px"],
                      [ViewItem viewItemFor:nil width:@"100%" height:@"32px"],
                      [ViewItem viewItemFor:loButton width:@"186px" height:@"32px"],
                      nil];
        } else {
            // Only the download button showing
            layout = [VerticalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"center"
                                      items:
                      [ViewItem viewItemFor:nil width:@"100%" height:@"118px"],
                      [ViewItem viewItemFor:dlButton width:@"186px" height:@"32px"],
                      nil];
        }
        
    }
    return self;
}

#pragma mark - layout code
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [layout layoutForView:self];
    
}

- (void)handleDownloadButtonPressed:(id)dlButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadSetupButtonPressed:)]) {
        [self.delegate downloadSetupButtonPressed:dlButton];
    }
}

- (void)handlePasswordButtonPressed:(id)pwButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(passwordSetupButtonPressed:)]) {
        [self.delegate passwordSetupButtonPressed:pwButton];
    }
}

- (void)handleLogoutButtonPressed:(id)logOutButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(logoutButtonPressed:)]) {
        [self.delegate logoutButtonPressed:logOutButton];
    }
}

@end

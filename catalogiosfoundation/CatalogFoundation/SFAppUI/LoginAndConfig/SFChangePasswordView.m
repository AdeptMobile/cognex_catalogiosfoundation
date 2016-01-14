//
//  SFChangePasswordView.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/12/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import "SFChangePasswordView.h"
#import "SFChangePasswordConfig.h"
#import "SFAppConfig.h"

#import "UIImage+Extensions.h"
#import "VerticalLayout.h"
#import "HorizontalLayout.h"
#import "GridLayout.h"

@interface SFChangePasswordView()

@property (nonatomic, strong) AbstractLayout *roundedLayout;

- (void) doneButtonPressed:(id)doneButton;
- (void) cancelButtonPressed:(id)cancelButton;

@end

@implementation SFChangePasswordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        SFChangePasswordConfig *config = [[SFAppConfig sharedInstance] getChangePasswordConfig];
        
        if (config.bgImageNamed) {
            self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageResource:config.bgImageNamed]];
        } else {
            self.backgroundColor = config.bgColor;
        }
        
        self.roundedView = [[UIViewWithLayout alloc] initWithFrame:CGRectZero];
        self.roundedView.backgroundColor = [UIColor colorWithRed:0.0f green:130.0f/255.0f blue:200.0f/255.0f alpha:1.0f];;
        self.roundedView.layer.cornerRadius = 8.0f;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = [UIFont fontWithName:config.labelFontName size:24.0f];
        titleLabel.textColor = config.labelTextColor;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = NSLocalizedString(@"Change Password", nil);
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.roundedView addSubview:titleLabel];
        
        UILabel *currentPwLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        currentPwLabel.font = [UIFont fontWithName:config.labelFontName size:14.0f];
        currentPwLabel.textColor = config.labelTextColor;
        currentPwLabel.textAlignment = NSTextAlignmentLeft;
        currentPwLabel.text = NSLocalizedString(@"Current Password", nil);
        currentPwLabel.backgroundColor = [UIColor clearColor];
        [self.roundedView addSubview:currentPwLabel];

        self.currentPwField = [[UITextField alloc] initWithFrame:CGRectZero];
        self.currentPwField.backgroundColor = config.fieldBgColor;
        self.currentPwField.font = [UIFont fontWithName:config.fieldFontName size:14.0f];
        self.currentPwField.textColor = config.fieldTextColor;
        self.currentPwField.textAlignment = NSTextAlignmentLeft;
        self.currentPwField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.currentPwField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.currentPwField.secureTextEntry = YES;
        [self.roundedView addSubview:self.currentPwField];
        
        UILabel *newPwLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        newPwLabel.font = [UIFont fontWithName:config.labelFontName size:14.0f];
        newPwLabel.textColor = config.labelTextColor;
        newPwLabel.textAlignment = NSTextAlignmentLeft;
        newPwLabel.text = NSLocalizedString(@"New Password", nil);
        newPwLabel.backgroundColor = [UIColor clearColor];
        [self.roundedView addSubview:newPwLabel];

        self.enterNewPwField = [[UITextField alloc] initWithFrame:CGRectZero];
        self.enterNewPwField.backgroundColor = config.fieldBgColor;
        self.enterNewPwField.font = [UIFont fontWithName:config.fieldFontName size:14.0f];
        self.enterNewPwField.textColor = config.fieldTextColor;
        self.enterNewPwField.textAlignment = NSTextAlignmentLeft;
        self.enterNewPwField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.enterNewPwField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.enterNewPwField.secureTextEntry = YES;
        [self.roundedView addSubview:self.enterNewPwField];
        
        UILabel *confirmNewPwLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        confirmNewPwLabel.font = [UIFont fontWithName:config.labelFontName size:14.0f];
        confirmNewPwLabel.textColor = config.labelTextColor;
        confirmNewPwLabel.textAlignment = NSTextAlignmentLeft;
        confirmNewPwLabel.text = NSLocalizedString(@"Confirm New Password", nil);
        confirmNewPwLabel.backgroundColor = [UIColor clearColor];
        [self.roundedView addSubview:confirmNewPwLabel];
        
        self.confirmNewPwField = [[UITextField alloc] initWithFrame:CGRectZero];
        self.confirmNewPwField.backgroundColor = config.fieldBgColor;
        self.confirmNewPwField.font = [UIFont fontWithName:config.fieldFontName size:14.0f];
        self.confirmNewPwField.textColor = config.fieldTextColor;
        self.confirmNewPwField.textAlignment = NSTextAlignmentLeft;
        self.confirmNewPwField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.confirmNewPwField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.confirmNewPwField.secureTextEntry = YES;
        [self.roundedView addSubview:self.confirmNewPwField];

        UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [doneButton setImage:[UIImage imageResource:config.doneButtonImageNamed] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.roundedView addSubview:doneButton];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [cancelButton setImage:[UIImage imageResource:config.cancelButtonImageNamed] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.roundedView addSubview:cancelButton];

        [self addSubview:self.roundedView];
        
        self.roundedLayout = [GridLayout margin:@"10px 18px 10px 18px" padding:@"0px" valign:@"center" halign:@"left" rows:[GridRow height:@"30px"
                            cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"left" items:[ViewItem viewItemFor:titleLabel width:@"100%" height:@"30px"], nil]], nil],
                 [GridRow height:@"20px"
                            cells:[GridCell width:@"100%" horizontalLayoutFor:[ViewItem viewItemFor:nil], nil], nil],
                [GridRow height:@"30px"
                            cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"left" items:[ViewItem viewItemFor:currentPwLabel width:@"100%" height:@"100%"], nil]], nil],
                [GridRow height:@"30px"
                            cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"left" items:[ViewItem viewItemFor:self.currentPwField width:@"280px" height:@"100%"], nil]], nil],
                [GridRow height:@"10px"
                            cells:[GridCell width:@"100%" horizontalLayoutFor:[ViewItem viewItemFor:nil], nil], nil],
                [GridRow height:@"30px"
                            cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"left" items:[ViewItem viewItemFor:newPwLabel width:@"100%" height:@"100%"], nil]], nil],
                [GridRow height:@"30px"
                            cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"left" items:[ViewItem viewItemFor:self.enterNewPwField width:@"280px" height:@"100%"], nil]], nil],
                [GridRow height:@"10px"
                            cells:[GridCell width:@"100%" horizontalLayoutFor:[ViewItem viewItemFor:nil], nil], nil],
                [GridRow height:@"30px"
                            cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"left" items:[ViewItem viewItemFor:confirmNewPwLabel width:@"100%" height:@"100%"], nil]], nil],
                [GridRow height:@"30px"
                            cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"left" items:[ViewItem viewItemFor:self.confirmNewPwField width:@"280px" height:@"100%"], nil]], nil],
                [GridRow height:@"20px"
                            cells:[GridCell width:@"100%" horizontalLayoutFor:[ViewItem viewItemFor:nil], nil], nil],
                             
                [GridRow height:@"36px"
                            cells:[GridCell width:@"308px" useGridLayoutProps:NO
                            layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"center" items:
                                    [ViewItem viewItemFor:doneButton width:@"96px" height:@"36px"],
                                    [ViewItem viewItemFor:nil width:@"132px" height:@"36px"],
                                    [ViewItem viewItemFor:cancelButton width:@"96px" height:@"36px"],
                                    nil]], nil],
                             nil];
        
        layout = [VerticalLayout margin:@"0px 0px 0px 330px" padding:@"0px" valign:@"top" halign:@"left" items:[ViewItem viewItemFor:nil width:@"100%" height:@"254px"],
                  [ViewItem viewItemFor:self.roundedView width:@"366px" height:@"344px"],
                  nil];
        
    }
    return self;
}

#pragma mark - layout code
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [layout layoutForView:self];
    [self.roundedLayout layoutForView:self.roundedView];
    
}

- (void) doneButtonPressed:(id)doneButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(doneButtonTapped:)]) {
        [self.delegate doneButtonTapped:doneButton];
    }
}
- (void) cancelButtonPressed:(id)cancelButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelButtonTapped:)]) {
        [self.delegate cancelButtonTapped:cancelButton];
    }
}

@end

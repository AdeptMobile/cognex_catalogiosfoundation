//
//  SFRequestLoginView.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/6/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import "SFRequestLoginView.h"
#import "SFRequestLoginConfig.h"
#import "SFAppConfig.h"
#import "ContentUtils.h"
#import "VerticalLayout.h"
#import "GridLayout.h"
#import "HorizontalLayout.h"

#import "UIImage+Extensions.h"

@interface SFRequestLoginView()

@property (nonatomic, strong) UIViewWithLayout *regionView;
@property (nonatomic, strong) AbstractLayout *regionLayout;

- (void) doneButtonPressed:(id)doneButton;

@end

@implementation SFRequestLoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        SFRequestLoginConfig *config = [[SFAppConfig sharedInstance] getRequestLoginConfig];
        
        if (config.bgImageNamed) {
            self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageResource:config.bgImageNamed]];
        } else {
            self.backgroundColor = config.bgColor;
        }
        
        self.regionView = [[UIViewWithLayout alloc] initWithFrame:CGRectZero];
        self.regionView.backgroundColor = config.selectViewBgColor;
        self.regionView.layer.cornerRadius = 8.0f;
        
        NSString *boldFont = [NSString stringWithFormat:@"%@-Bold", config.textFont];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = [UIFont fontWithName:boldFont size:20.0f];
        titleLabel.textColor = config.textColor;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = NSLocalizedString(@"Request Login", nil);
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.regionView addSubview:titleLabel];

        UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subTitleLabel.font = [UIFont fontWithName:config.textFont size:12.0f];
        subTitleLabel.textColor = config.textColor;
        subTitleLabel.numberOfLines = 0;
        subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        subTitleLabel.textAlignment = NSTextAlignmentLeft;
        subTitleLabel.text = NSLocalizedString(@"Reminder: All Donaldson employees can use their universal login information to access the app. Dealers and Distributors who can access Torit QuickSuite (TQS) can use their TQS login to access the app.  Dealers and distributors who do not have access, please select your region.  An email with your contact information will be sent to the appropriate Donaldson contact for review.  If approved, you login information will be sent to you via email in 3-5 business days.", nil);
        subTitleLabel.backgroundColor = [UIColor clearColor];
        [self.regionView addSubview:subTitleLabel];

        UILabel *regionPickTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        regionPickTitle.font = [UIFont fontWithName:boldFont size:12.0f];
        regionPickTitle.textColor = config.textColor;
        regionPickTitle.textAlignment = NSTextAlignmentLeft;
        regionPickTitle.text = NSLocalizedString(@"Select Region", nil);
        regionPickTitle.backgroundColor = [UIColor clearColor];
        [self.regionView addSubview:regionPickTitle];
        
        self.regionPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        self.regionPicker.backgroundColor = config.pickerViewBgColor;
        self.regionPicker.delegate = self;
        self.regionPicker.dataSource = self;
        [self.regionView addSubview:self.regionPicker];
        
        [self addSubview:self.regionView];
        
        self.doneButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.doneButton setImage:[UIImage imageResource:config.doneButtonImageNamed] forState:UIControlStateNormal];
        [self.doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.doneButton];
        
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.cancelButton setImage:[UIImage imageResource:config.cancelButtonImageNamed] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelButton];
        
        self.regionLayout = [VerticalLayout margin:@"20px" padding:@"0px" valign:@"top" halign:@"left"
                            items:
                              [ViewItem viewItemFor:titleLabel width:@"100%" height:@"28px"],
                              [ViewItem viewItemFor:nil width:@"100%" height:@"4px"],
                              [ViewItem viewItemFor:subTitleLabel width:@"100%" height:@"150px"],
                              [ViewItem viewItemFor:nil width:@"100%" height:@"12px"],
                              [ViewItem viewItemFor:regionPickTitle width:@"100%" height:@"24px"],
                              [ViewItem viewItemFor:self.regionPicker width:@"100%" height:@"162px"],
                             nil];

        layout = [GridLayout margin:@"0px 0px 0px 324px" padding:@"0px" valign:@"top" halign:@"left"
                   rows:[GridRow height:@"258px"
                            cells:[GridCell width:@"100%" horizontalLayoutFor:[ViewItem viewItemFor:nil], nil], nil],
                  [GridRow height:@"418px"
                            cells:[GridCell width:@"360px" useGridLayoutProps:NO layout:
                                   [HorizontalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"left" items:[ViewItem viewItemFor:self.regionView width:@"360px" height:@"418px"], nil]], nil],
                  [GridRow height:@"10px"
                            cells:[GridCell width:@"100%" horizontalLayoutFor:[ViewItem viewItemFor:nil], nil], nil],
                  [GridRow height:@"36px" cells:[GridCell width:@"360px" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"left" items:[ViewItem viewItemFor:nil width:@"146px" height:@"36px"],
                      [ViewItem viewItemFor:self.cancelButton width:@"96px" height:@"36px"],
                      [ViewItem viewItemFor:nil width:@"22px" height:@"36px"],
                      [ViewItem viewItemFor:self.doneButton width:@"96px" height:@"36px"],
                            nil]], nil],
                  nil];
        
    }
    return self;
}

#pragma mark - layout code
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [layout layoutForView:self];
    [self.regionLayout layoutForView:self.regionView];
    
}

#pragma mark - UIPickerView Delegate and DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    SFRequestLoginConfig *config = [[SFAppConfig sharedInstance] getRequestLoginConfig];
    return [config.regions objectAtIndex:row];
}

#pragma mark - UIButton Event Handlers
- (void)doneButtonPressed:(id)doneButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(doneButtonTapped:)]) {
        [self.delegate doneButtonTapped:doneButton];
    }
}

- (void)cancelButtonPressed:(id)cancelButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelButtonTapped:)]) {
        [self.delegate cancelButtonTapped:cancelButton];
    }
}

@end

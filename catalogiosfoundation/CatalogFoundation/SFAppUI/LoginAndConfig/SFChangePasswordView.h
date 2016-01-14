//
//  SFChangePasswordView.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/12/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import "UIViewWithLayout.h"

@protocol SFChangePasswordViewDelegate <NSObject>

- (void)doneButtonTapped:(id)doneButton;
- (void)cancelButtonTapped:(id)cancelButton;

@end

@interface SFChangePasswordView : UIViewWithLayout

@property (nonatomic, weak) id<SFChangePasswordViewDelegate>delegate;

@property (nonatomic, strong) UITextField *currentPwField;
@property (nonatomic, strong) UITextField *enterNewPwField;
@property (nonatomic, strong) UITextField *confirmNewPwField;
@property (nonatomic, strong) UIViewWithLayout *roundedView;

@end

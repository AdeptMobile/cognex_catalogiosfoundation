//
//  SFRequestLoginView.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/6/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import "UIViewWithLayout.h"

@protocol SFRequestLoginViewDelegate <NSObject>

- (void)doneButtonTapped:(id)doneButton;
- (void)cancelButtonTapped:(id)cancelButton;

@end
@interface SFRequestLoginView : UIViewWithLayout<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) id<SFRequestLoginViewDelegate> delegate;
@property (nonatomic, strong) UIPickerView *regionPicker;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *cancelButton;

@end

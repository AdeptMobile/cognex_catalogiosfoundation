//
//  SFDownloadConfigView.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/6/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import "UIViewWithLayout.h"

@protocol SFDownloadViewDelegate <NSObject>

- (void) doneButtonTapped:(id)doneButton;

@end

@interface SFDownloadConfigView : UIViewWithLayout

@property (nonatomic, weak) id<SFDownloadViewDelegate> delegate;
@property (nonatomic, strong) UISwitch *allVideoSwitch;
@property (nonatomic, strong) UISwitch *allPresentationSwitch;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, assign) BOOL individualVideoDeletion;

@end

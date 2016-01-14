//
//  SyncProgressHudView.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/6/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "UIViewWithLayout.h"

@class SyncProgressHudView;

@protocol SyncProgressHudViewDelegate <NSObject>

- (void) syncProgressHudView:(SyncProgressHudView *)aSyncProgressView applyChangesButtonPressed:(id)applyChangesButton;

@optional
- (void) syncProgressHudView:(SyncProgressHudView *)aSyncProgressView applyChangesButtonLongPressed:(id)applyChangesButton;

@end

@interface SyncProgressHudView : UIViewWithLayout {
    NSInteger totalSyncFiles;
    NSInteger downloadedSyncFiles;
    
    UIProgressView *progressView;
    UILabel *progressLabel;
    UIView *lineView;
    
    UIButton *applyChangesButton;
    
    NSObject<SyncProgressHudViewDelegate>* __weak delegate;
    
}

@property (nonatomic, assign) NSInteger totalSyncFiles;
@property (nonatomic, assign) NSInteger downloadedSyncFiles;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;

@property (nonatomic, strong) UIButton *applyChangesButton;

@property (nonatomic, weak) NSObject<SyncProgressHudViewDelegate>* delegate;

@end

//
//  ToloContentProgressView.h
//  ToloApp
//
//  Created by Torey Lomenda on 7/11/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ToloContentProgressView : UIView {
    NSInteger totalContentChanges;
    NSInteger appliedContentChanges;
    
    UILabel *progressMsgLabel;
    UILabel *progressStatusLabel;
    UIProgressView *progressView;
}

@property (nonatomic, assign) NSInteger totalContentChanges;
@property (nonatomic, assign) NSInteger appliedContentChanges;

- (void) setupForUnpackContentProgress;
- (void) setupForApplySyncChancesProgress;
- (void) setupForInitialDownloadProgress;
@end

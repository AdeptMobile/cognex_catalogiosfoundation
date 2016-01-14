//
//  ToloContentProgressView.m
//  ToloApp
//
//  Created by Torey Lomenda on 7/11/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ToloContentProgressView.h"

#import "UIView+ViewLayout.h"
#import "UIColor+Chooser.h"

#define LABEL_FONT_SIZE 18.0f
#define LABEL_HEIGHT 20.0f
#define LABEL_SPACING 5.0f

#define UNPACKING_CONTENT_MSG @"Initial install delay, please wait..."
#define APPLY_CHANGES_MSG @"Applying changes to app resources..."
#define DOWNLOAD_CONTENT_MSG @"Initial download in progress, this may take awhile..."
#define PROGRESS_STATUS_MSG @"%ld of %ld"

@interface ToloContentProgressView()

@end

@implementation ToloContentProgressView

@synthesize totalContentChanges;
@synthesize appliedContentChanges;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Add the labels and progress indicator
        progressMsgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        progressMsgLabel.backgroundColor = [UIColor clearColor];
        progressMsgLabel.textAlignment = NSTextAlignmentCenter;
        progressMsgLabel.textColor = [UIColor colorFromRGB:0x666666];
        progressMsgLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
        
        // progress status label
        progressStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        progressStatusLabel.hidden = YES;
        progressStatusLabel.backgroundColor = [UIColor clearColor];
        progressStatusLabel.textAlignment = NSTextAlignmentCenter;
        progressStatusLabel.textColor = [UIColor colorFromRGB:0x666666];
        progressStatusLabel.font = [UIFont italicSystemFontOfSize:LABEL_FONT_SIZE];
        
        // progress indicator
        progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        
        [self addSubview:progressMsgLabel];
        [self addSubview:progressStatusLabel];
        [self addSubview:progressView];
        
    }
    return self;
}




#pragma mark -
#pragma mark Accessors
//=========================================================== 
// - setTotalContentChanges:
//=========================================================== 
- (void)setTotalContentChanges:(NSInteger)aTotalContentChanges {
    totalContentChanges = aTotalContentChanges;
    appliedContentChanges = 0;
    
    // Update and show the progress status label
    progressStatusLabel.text = [NSString stringWithFormat:PROGRESS_STATUS_MSG, (long)appliedContentChanges, (long)totalContentChanges];
    
    if (totalContentChanges > 0 && progressStatusLabel.hidden) {
        progressStatusLabel.hidden = NO;
    } else if (!progressStatusLabel.hidden) {
        progressStatusLabel.hidden = YES;
    }
}

//=========================================================== 
// - setAppliedContentChanges:
//=========================================================== 
- (void)setAppliedContentChanges:(NSInteger)anAppliedContentChanges {
    appliedContentChanges = anAppliedContentChanges;
    
    // Update and show the progress status label
    progressStatusLabel.text = [NSString stringWithFormat:PROGRESS_STATUS_MSG, (long)appliedContentChanges, (long)totalContentChanges];
    
    // Update progress
    float progress = (float) appliedContentChanges/(float) totalContentChanges;
    progressView.progress = progress;
    
    if (progressStatusLabel.hidden) {
        progressStatusLabel.hidden = NO;
    }
}



#pragma mark -
#pragma mark Public Methods
- (void) setupForUnpackContentProgress {
    progressMsgLabel.text = UNPACKING_CONTENT_MSG;
    progressView.progress = 0.0f;
    
    self.totalContentChanges = 0;
}

- (void) setupForApplySyncChancesProgress {
    progressMsgLabel.text = APPLY_CHANGES_MSG;
    progressView.progress = 0.0f;
    
    self.totalContentChanges = 0;
}

- (void) setupForInitialDownloadProgress {
    progressMsgLabel.text = DOWNLOAD_CONTENT_MSG;
    progressView.progress = 0.0f;
    
    self.totalContentChanges = 0;
}

#pragma mark -
#pragma mark Layout and drawing code
- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect progressMsgFrame = CGRectMake(0, 0, self.bounds.size.width, LABEL_HEIGHT);
    CGRect progressStatusFrame = CGRectMake(0, LABEL_HEIGHT + LABEL_SPACING, self.bounds.size.width, LABEL_HEIGHT);
    CGRect progressViewFrame = CGRectMake(0, LABEL_HEIGHT*2 + LABEL_SPACING*2, self.bounds.size.width, progressView.frame.size.height);
    
    progressMsgLabel.frame = progressMsgFrame;
    progressStatusLabel.frame = progressStatusFrame;
    progressView.frame = progressViewFrame;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
@end

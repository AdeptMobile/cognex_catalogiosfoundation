//
//  SyncProgressHudView.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/6/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "SyncProgressHudView.h"

#import "UIColor+Chooser.h"
#import "NSBundle+CatalogFoundationResource.h"
#import "UIImage+CatalogFoundationResourceImage.h"

#import "BorderLayout.h"
#import "BorderRegion.h"
#import "VerticalLayout.h"
#import "HorizontalLayout.h"

#define LABEL_FONT_SIZE 14.0f

@interface SyncProgressHudView()

- (void) handleApplyChangesButton:(id)sender;

@end

@implementation SyncProgressHudView

@synthesize totalSyncFiles;
@synthesize downloadedSyncFiles;
@synthesize progressView;
@synthesize progressLabel;
@synthesize applyChangesButton;
@synthesize delegate;

#pragma mark - init/dealloc

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
        
        progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        
        progressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.textAlignment = NSTextAlignmentCenter;
        progressLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        progressLabel.font = [UIFont italicSystemFontOfSize:LABEL_FONT_SIZE];
        progressLabel.text = @"Content Download Progress";
        
        applyChangesButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
        UIImage *reImage = [UIImage contentFoundationResourceImageNamed:@"refresh_white.png"];
        [applyChangesButton setImage:reImage forState:UIControlStateNormal];
        [applyChangesButton addTarget:self action:@selector(handleApplyChangesButton:) forControlEvents:UIControlEventTouchUpInside];
        applyChangesButton.enabled = NO;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [applyChangesButton addGestureRecognizer:longPress];
        
        //applyChangesButton.backgroundColor = [UIColor redColor];
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1.0f, 10.0f)];
        lineView.backgroundColor = [UIColor colorFromRGB:0x666666];
        
        [self addSubview:progressView];
        [self addSubview:progressLabel];
        [self addSubview:applyChangesButton];
        [self addSubview:lineView];
        
        layout = [BorderLayout margin:@"10px 0px 10px 10px" padding:@"0px" 
                                 north:nil
                                 south:nil 
                                  east:[BorderRegion size:@"80px" useBorderLayoutProps:YES
                                                   layout: [HorizontalLayout margin:@"0px"
                                                                          padding:@"10px"
                                                                           valign:@"center"
                                                                           halign:@"right"
                                                                              items:[ViewItem viewItemFor:lineView
                                                                                                    width:@"1px"
                                                                                                   height:@"100%"],
                                                                                    [ViewItem viewItemFor:applyChangesButton
                                                                                                width:@"60px"
                                                                                               height:@"100%"], nil]]
                                  west:nil 
                                center:[BorderRegion layout: [VerticalLayout margin:@"0px"
                                                                            padding:@"0px"
                                                                             valign:@"center"
                                                                             halign:@"left"
                                                                              items:[ViewItem viewItemFor:progressLabel
                                                                                                    width:@"100%"
                                                                                                   height:@"50%"],
                                                              [ViewItem viewItemFor:progressView
                                                                              width:@"100%"
                                                                             height:@"50%"], nil]]
                   ];
    }
    return self;
}

- (void) dealloc {
    
    
    
    delegate = nil;
    
}

#pragma mark - accessors
- (void) setTotalSyncFiles:(NSInteger)aTotalSyncFiles {
    
    totalSyncFiles = aTotalSyncFiles;
    downloadedSyncFiles = 0;
    progressLabel.text = @"Content Download Starting";
    
}

- (void) setDownloadedSyncFiles:(NSInteger)aDownloadedSyncFiles {
    
    downloadedSyncFiles = aDownloadedSyncFiles;
    
    if (totalSyncFiles == 0) {
        progressLabel.text = @"Content Download in Progress...";
    } else {
        progressLabel.text = [NSString stringWithFormat:@"Content Download In Progress %ld of %ld", (long)downloadedSyncFiles, (long)totalSyncFiles];
    }
    
    float progress = (float)downloadedSyncFiles / (float)totalSyncFiles;
    progressView.progress = progress;
    
}

/*
- (void)drawRect:(CGRect)rect
{

}
*/

#pragma mark - layout code
- (void) layoutSubviews {
    [super layoutSubviews];
    
    [layout layoutForView:self];
    
    CGRect frame = self.frame;
    CGRect lineFrame = lineView.frame;
    
    lineView.frame = CGRectMake(lineFrame.origin.x, 0.0f, lineFrame.size.width, frame.size.height);
    
}

- (void) handleApplyChangesButton:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(syncProgressHudView:applyChangesButtonPressed:)]) {
        [delegate syncProgressHudView:self applyChangesButtonPressed:sender];
    }
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateBegan ) {
        if (delegate && [delegate respondsToSelector:@selector(syncProgressHudView:applyChangesButtonLongPressed:)]) {
            [delegate syncProgressHudView:self applyChangesButtonLongPressed:gesture.view];
        }
    }
}

@end

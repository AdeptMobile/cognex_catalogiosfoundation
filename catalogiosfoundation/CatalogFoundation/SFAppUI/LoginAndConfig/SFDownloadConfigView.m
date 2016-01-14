//
//  SFDownloadConfigView.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/6/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SFDownloadConfigView.h"
#import "SFAppConfig.h"
#import "SFDownloadViewConfig.h"
#import "ContentUtils.h"
#import "VerticalLayout.h"
#import "HorizontalLayout.h"
#import "GridLayout.h"

#import "UIImage+Extensions.h"
#import "UIView+ViewLayout.h"

@interface SFDownloadConfigView()

@property (nonatomic, strong) AbstractLayout *toggleLayout;
@property (nonatomic, strong) UIViewWithLayout *toggleView;

- (void)doneButtonPressed:(id)doneButton;

@end

@implementation SFDownloadConfigView

@synthesize individualVideoDeletion;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        SFDownloadViewConfig *config = [[SFAppConfig sharedInstance] getDownloadViewConfig];
        
        self.individualVideoDeletion = NO;

        if (config.bgImageNamed) {
            self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageResource:config.bgImageNamed]];
        } else {
            self.backgroundColor = config.bgColor;
        }
        
        self.toggleView = [[UIViewWithLayout alloc] initWithFrame:CGRectZero];
        self.toggleView.backgroundColor = config.toggleViewBgColor;
        self.toggleView.layer.cornerRadius = 8.0f;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = [UIFont fontWithName:config.toggleViewTitleFont size:config.toggleViewTitleFontSize];
        titleLabel.textColor = config.toggleViewTextColor;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.text = NSLocalizedString(@"Download Content", nil);
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.toggleView addSubview:titleLabel];
        
        UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subTitleLabel.font = [UIFont fontWithName:config.toggleViewFont size:config.toggleViewFontSize];
        subTitleLabel.textColor = config.toggleViewTextColor;
        subTitleLabel.numberOfLines = 0;
        subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        subTitleLabel.textAlignment = NSTextAlignmentLeft;
        subTitleLabel.text = NSLocalizedString(config.subTitleText, nil);
        subTitleLabel.backgroundColor = [UIColor clearColor];
        [self.toggleView addSubview:subTitleLabel];
        
        self.allVideoSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [self.allVideoSwitch setOnTintColor:config.toggleViewToggleTintColor];

        BOOL appConfigured = [ContentUtils isAppConfigured];
        BOOL vidSwitchOn;
        
        if (appConfigured) {
            // Has to be negated as the switch being on means all where as from the
            // sync perspective our flag says whether to suppress the videos or not.
            vidSwitchOn = ![ContentUtils isVideoSyncDisabled];
            
            //only do this after app has been configured.
            [self.allVideoSwitch addTarget:self action:@selector(setAllVideoSwitchState:) forControlEvents:UIControlEventValueChanged];
            
        } else {
            vidSwitchOn = config.enableBigSyncByDefault;
        }

        [self.allVideoSwitch setOn:vidSwitchOn animated:NO];
        if ([[SFAppConfig sharedInstance] isVideoFilteringEnabled]) {
            [self.toggleView addSubview:self.allVideoSwitch];
        }
        
        UILabel *videoTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        videoTitleLabel.backgroundColor = [UIColor clearColor];
        videoTitleLabel.font = [UIFont fontWithName:config.toggleViewTitleFont size:config.toggleViewFontSize];
        videoTitleLabel.textColor = config.toggleViewTextColor;
        videoTitleLabel.textAlignment = NSTextAlignmentLeft;
        videoTitleLabel.text = NSLocalizedString(config.videoHeaderText, nil);
        if ([[SFAppConfig sharedInstance] isVideoFilteringEnabled]) {
            [self.toggleView addSubview:videoTitleLabel];
        }

        UILabel *subVideoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subVideoLabel.font = [UIFont fontWithName:config.toggleViewFont size:config.toggleViewFontSize];
        subVideoLabel.textColor = config.toggleViewTextColor;
        subVideoLabel.numberOfLines = 0;
        subVideoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        subVideoLabel.textAlignment = NSTextAlignmentLeft;
        subVideoLabel.text = NSLocalizedString(config.videoDetailText, nil);
        subVideoLabel.backgroundColor = [UIColor clearColor];
        if ([[SFAppConfig sharedInstance] isVideoFilteringEnabled]) {
            [self.toggleView addSubview:subVideoLabel];
        }
        
        self.allPresentationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [self.allPresentationSwitch setOnTintColor:config.toggleViewToggleTintColor];
        
        BOOL presSwitchOn;
        if (appConfigured) {
            // Has to be negated for the same reason as the video flag above.
            presSwitchOn = ![ContentUtils isPresentationSyncDisabled];
        } else {
            presSwitchOn = config.enableBigSyncByDefault;
        }

        [self.allPresentationSwitch setOn:presSwitchOn animated:NO];
        if ([[SFAppConfig sharedInstance] isPresentationFilteringEnabled]) {
            [self.toggleView addSubview:self.allPresentationSwitch];
        }

        UILabel *presTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        presTitleLabel.backgroundColor = [UIColor clearColor];
        presTitleLabel.font = [UIFont fontWithName:config.toggleViewTitleFont size:config.toggleViewFontSize];
        presTitleLabel.textColor = config.toggleViewTextColor;
        presTitleLabel.textAlignment = NSTextAlignmentLeft;
        presTitleLabel.text = NSLocalizedString(config.presentationHeaderText, nil);
        if ([[SFAppConfig sharedInstance] isPresentationFilteringEnabled]) {
            [self.toggleView addSubview:presTitleLabel];
        }
        
        UILabel *subPresLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        subPresLabel.font = [UIFont fontWithName:config.toggleViewFont size:config.toggleViewFontSize];
        subPresLabel.textColor = config.toggleViewTextColor;
        subPresLabel.numberOfLines = 0;
        subPresLabel.lineBreakMode = NSLineBreakByWordWrapping;
        subPresLabel.textAlignment = NSTextAlignmentLeft;
        subPresLabel.text = NSLocalizedString(config.presentationDetailText, nil);
        subPresLabel.backgroundColor = [UIColor clearColor];
        if ([[SFAppConfig sharedInstance] isPresentationFilteringEnabled]) {
            [self.toggleView addSubview:subPresLabel];
        }
        
        [self addSubview:self.toggleView];
        
        self.doneButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.doneButton setImage:[UIImage imageResource:config.doneButtonImageNamed] forState:UIControlStateNormal];
        [self.doneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.doneButton];
        
        if ([[SFAppConfig sharedInstance] isVideoFilteringEnabled] && [[SFAppConfig sharedInstance] isPresentationFilteringEnabled]) {
            self.toggleLayout = [GridLayout margin:@"18px" padding:@"0px" valign:@"center" halign:@"left" rows:[GridRow height:@"20px"
                                                                                                                         cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"left" items:[ViewItem viewItemFor:titleLabel width:@"100%" height:@"20px"], nil]], nil],
                                 [GridRow height:@"4px"
                                           cells:[GridCell width:@"100%" horizontalLayoutFor:[ViewItem viewItemFor:nil], nil], nil],
                                 [GridRow height:@"65px"
                                           cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"left" items:[ViewItem viewItemFor:subTitleLabel width:@"100%" height:@"100%"], nil]], nil],
                                 [GridRow height:@"20px"
                                           cells:[GridCell width:@"100%" horizontalLayoutFor:[ViewItem viewItemFor:nil], nil], nil],
                                 [GridRow height:@"60px"
                                           cells:[GridCell width:@"80px" useGridLayoutProps:NO
                                                          layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"center" items:[ViewItem viewItemFor:self.allVideoSwitch width:@"50px" height:@"30px"], nil]],
                                  [GridCell width:@"200px" useGridLayoutProps:NO layout:[VerticalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"left" items:
                                                                                         [ViewItem viewItemFor:videoTitleLabel width:@"100%" height:@"16px"],
                                                                                         [ViewItem viewItemFor:subVideoLabel width:@"100%" height:@"36px"], nil]], nil],
                                 [GridRow height:@"70px"
                                           cells:[GridCell width:@"80px" useGridLayoutProps:NO
                                                          layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"center" items:[ViewItem viewItemFor:self.allPresentationSwitch width:@"50px" height:@"30px"], nil]],
                                  [GridCell width:@"200px" useGridLayoutProps:NO layout:[VerticalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"left" items:
                                                                                         [ViewItem viewItemFor:presTitleLabel width:@"100%" height:@"16px"],
                                                                                         [ViewItem viewItemFor:subPresLabel width:@"100%" height:@"46px"], nil]], nil],
                                 nil];
        } else if ([[SFAppConfig sharedInstance] isVideoFilteringEnabled] && ![[SFAppConfig sharedInstance] isPresentationFilteringEnabled]) {
            self.toggleLayout = [GridLayout margin:@"18px" padding:@"0px" valign:@"center" halign:@"left" rows:[GridRow height:@"20px"
                                                                                                                         cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"left" items:[ViewItem viewItemFor:titleLabel width:@"100%" height:@"20px"], nil]], nil],
                                 [GridRow height:@"4px"
                                           cells:[GridCell width:@"100%" horizontalLayoutFor:[ViewItem viewItemFor:nil], nil], nil],
                                 [GridRow height:@"65px"
                                           cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"left" items:[ViewItem viewItemFor:subTitleLabel width:@"100%" height:@"100%"], nil]], nil],
                                 [GridRow height:@"20px"
                                           cells:[GridCell width:@"100%" horizontalLayoutFor:[ViewItem viewItemFor:nil], nil], nil],
                                 [GridRow height:@"60px"
                                           cells:[GridCell width:@"80px" useGridLayoutProps:NO
                                                          layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"center" items:[ViewItem viewItemFor:self.allVideoSwitch width:@"50px" height:@"30px"], nil]],
                                  [GridCell width:@"200px" useGridLayoutProps:NO layout:[VerticalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"left" items:
                                                                                         [ViewItem viewItemFor:videoTitleLabel width:@"100%" height:@"16px"],
                                                                                         [ViewItem viewItemFor:subVideoLabel width:@"100%" height:@"36px"], nil]], nil],
                                 nil];
        } else if (![[SFAppConfig sharedInstance] isVideoFilteringEnabled] && [[SFAppConfig sharedInstance] isPresentationFilteringEnabled]) {
            self.toggleLayout = [GridLayout margin:@"18px" padding:@"0px" valign:@"center" halign:@"left" rows:[GridRow height:@"20px"
                                                                                                                         cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"left" items:[ViewItem viewItemFor:titleLabel width:@"100%" height:@"20px"], nil]], nil],
                                 [GridRow height:@"4px"
                                           cells:[GridCell width:@"100%" horizontalLayoutFor:[ViewItem viewItemFor:nil], nil], nil],
                                 [GridRow height:@"65px"
                                           cells:[GridCell width:@"100%" useGridLayoutProps:NO layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"center" halign:@"left" items:[ViewItem viewItemFor:subTitleLabel width:@"100%" height:@"100%"], nil]], nil],
                                 [GridRow height:@"20px"
                                           cells:[GridCell width:@"100%" horizontalLayoutFor:[ViewItem viewItemFor:nil], nil], nil],
                                 [GridRow height:@"70px"
                                           cells:[GridCell width:@"80px" useGridLayoutProps:NO
                                                          layout:[HorizontalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"center" items:[ViewItem viewItemFor:self.allPresentationSwitch width:@"50px" height:@"30px"], nil]],
                                  [GridCell width:@"200px" useGridLayoutProps:NO layout:[VerticalLayout margin:@"0px" padding:@"0px" valign:@"top" halign:@"left" items:
                                                                                         [ViewItem viewItemFor:presTitleLabel width:@"100%" height:@"16px"],
                                                                                         [ViewItem viewItemFor:subPresLabel width:@"100%" height:@"46px"], nil]], nil],
                                 nil];
        }
        
        NSString *toggleHeight = nil;
        if ([[SFAppConfig sharedInstance] isVideoFilteringEnabled] && [[SFAppConfig sharedInstance] isPresentationFilteringEnabled]) {
            toggleHeight = @"268px";
        } else {
            toggleHeight = @"198px";
        }
        layout = [VerticalLayout margin:@"0px 0px 0px 350px" padding:@"0px" valign:@"top" halign:@"left" items:[ViewItem viewItemFor:nil width:@"100%" height:@"294px"],
                  [ViewItem viewItemFor:self.toggleView width:@"324px" height:toggleHeight],
                  [ViewItem viewItemFor:nil width:@"100%" height:@"12px"],
                  [ViewItem viewItemFor:self.doneButton width:@"96px" height:@"36px"],
                  nil];
        
    }
    return self;
}

#pragma mark - layout code
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [layout layoutForView:self];
    [self.toggleLayout layoutForView:self.toggleView];
    
}


#pragma mark - Button Handlers
- (void) doneButtonPressed:(id)doneButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(doneButtonTapped:)]) {
        [self.delegate doneButtonTapped:doneButton];
    }
}

#pragma mark - Switch State handlers
- (void) setAllVideoSwitchState:(id)sender {

    BOOL state = [sender isOn];

    if(!state) {

        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Video Filtering Enabled"
                                                        message:@"Remove all videos currently on the device to save space?  Press Cancel and videos may be removed individually by pressing and holding the icon and then selecting the delete option."
                                                       delegate:self cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
        [alert addButtonWithTitle:@"OK"];
        [alert show];

    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {     //they clicked Cancel.
        individualVideoDeletion = YES;
    } else {
        individualVideoDeletion = NO;
    }
}

@end

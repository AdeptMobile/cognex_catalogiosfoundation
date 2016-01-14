//
//  ContentInfoInsetToolbarView.h
//  SickApp
//
//  Created by Steve McCoole on 4/9/13.
//  Copyright 2013 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewWithLayout.h"
#import "SyncActionViewController.h"

#import "LeftToolBarInsetView.h"
#import "RightToolbarInsetView.h"
#import "ContentInfoToolbarConfig.h"

@protocol ContentInfoToolbarDelegate <NSObject>

- (void) toolbarButtonTapped:(id)toolbarButton;
- (void) longPressOnToolbarButton:(id)toolbarButton;

// sync related delegate methods
- (void) selectedSyncAction:(SyncActionType)syncAction;

@end

@interface ContentInfoToolbarView : UIViewWithLayout<SyncActionDelegate, RightToolBarDelegate, LeftToolbarDelegate> {
    
}

@property (nonatomic, strong) LeftToolBarInsetView *leftInsetView;

@property (nonatomic, strong) RightToolbarInsetView *rightInsetView;

@property (nonatomic, strong) UIPopoverController *infoPopover;

@property (nonatomic, weak) id<ContentInfoToolbarDelegate> delegate;

- (void) dismissPopover;
- (id) initWithFrame:(CGRect)frame andConfig:(ContentInfoToolbarConfig *)config;
- (void) updateBadgeText: (NSString *) newBadgeText;
- (void) resizeBadge;
- (void) hideBadge;
- (void) showBadge;
- (BOOL) badgeHidden;
- (NSString *) badgeText;

@end

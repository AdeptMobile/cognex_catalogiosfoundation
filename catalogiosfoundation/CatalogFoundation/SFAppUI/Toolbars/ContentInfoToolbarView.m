//
//  ContentInfoInsetToolbarView.m
//  ContentApp
//
//  Created by Steve McCoole on 4/9/13.
//  Copyright 2013 Object Partners Inc. All rights reserved.
//

#import "ContentInfoToolbarView.h"

#import "SFAppConfig.h"
#import "HorizontalLayout.h"
#import "BorderLayout.h"
#import "FillLayout.h"

#import "SyncActionViewController.h"
#import "ContentSyncManager.h"

#import "UIImage+Extensions.h"
#import "UIImage+CatalogFoundationResourceImage.h"

@interface ContentInfoToolbarView()

- (void) handleToolbarButton:(id)selector;
- (void) handleSyncButton:(id)selector;
- (void) handleLongPressOnButton:(UILongPressGestureRecognizer *)gesture;

@end
@implementation ContentInfoToolbarView

@synthesize delegate;
@synthesize infoPopover, leftInsetView, rightInsetView;

#pragma mark -
#pragma mark init/dealloc
- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        ContentInfoToolbarConfig *config = [[SFAppConfig sharedInstance] getContentInfoToolbarConfig];
        
        if (config.centerBgImageNamed) {
            self.backgroundColor = [UIColor colorWithPatternImage:[UIImage contentFoundationResourceImageNamed:config.centerBgImageNamed]];
        } else {
            self.backgroundColor = [UIColor clearColor];
        }
        
        self.leftInsetView = [[LeftToolBarInsetView alloc] initWithFrame:CGRectZero];
        leftInsetView.delegate = self;
        
        self.rightInsetView = [[RightToolbarInsetView alloc] initWithFrame:CGRectZero];
        rightInsetView.delegate = self;
        
        [self addSubview:leftInsetView];
        [self addSubview:rightInsetView];

        NSString *leftWidth = @"84px";
        if (config.homeBtnImageNamed && config.homeBtnImageNamed.length > 0) {
            leftWidth = @"110px";
        }
        
        // Margin needed on the leftInsetView in order to move it away from the edge
        // Can't use the border layout props because we might have the home button
        // or may not.  SMM
        layout = [BorderLayout margin:@"0px"
                              padding:@"6px 6px 6px 6px"
                                north:nil
                                south:nil
                                 east:nil
                                 west:[BorderRegion size:leftWidth useBorderLayoutProps:NO layout:[HorizontalLayout margin:@"0px 0px 0px 6px"
                                                                             padding:nil
                                                                             valign:@"center"
                                                                             halign:@"left"
                                                                             items:[ViewItem viewItemFor:leftInsetView
                                                                                                   width:@"100%" height:@"32px"], nil]]
                                 center:[BorderRegion layout:[HorizontalLayout margin:@"0"
                                                                            padding:nil
                                                                             valign:@"center"
                                                                             halign:@"right"
                                                                              items:[ViewItem viewItemFor:rightInsetView
                                                                                                    width:@"80%" height:@"32px"], nil]]];

    }
    return self;
}

- (id) initWithFrame:(CGRect)frame andConfig:(ContentInfoToolbarConfig *)config {
    // The inset views look up the config on their own.  This is here for backwards
    // compatibility with the old toolbar.
    return [self initWithFrame:frame];
}

- (void)dealloc {
    infoPopover = nil;
}

#pragma mark - 
#pragma mark Public Methods
- (void) dismissPopover {
    if (infoPopover && [infoPopover isPopoverVisible]) {
        [infoPopover dismissPopoverAnimated:YES];
    }
}

#pragma mark -
#pragma mark SyncActionDelegate Methods
- (void) selectedSyncAction:(SyncActionType)syncAction {
    
    if (delegate && [delegate respondsToSelector:@selector(selectedSyncAction:)]) {
        [delegate selectedSyncAction:syncAction];
    }
    
    [infoPopover dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark Layout and Drawing
- (void) layoutSubviews {
    [super layoutSubviews];
    
    [layout layoutForView:self];
    
    //backButton.center = CGPointMake(leftInsetView.frame.size.width / 2, leftInsetView.frame.size.height / 2);
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark -
#pragma mark Private Methods
- (void) handleSyncButton:(id)selector {    
    // Show a popover controller
    UIView *tappedView = ((UIView *) selector);
    SyncActionViewController *syncController = [[SyncActionViewController alloc] init];
    syncController.delegate = self;
    
    if (infoPopover == nil) {
        infoPopover = [[UIPopoverController alloc] initWithContentViewController:syncController];
    } else {
        infoPopover = nil;
        
        infoPopover = [[UIPopoverController alloc] initWithContentViewController:syncController];
    }
        
    CGRect frame = tappedView.frame;
    [infoPopover presentPopoverFromRect:frame inView:tappedView.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) handleToolbarButton:(id)selector {
    if (delegate && [delegate respondsToSelector:@selector(toolbarButtonTapped:)]) {
        [delegate toolbarButtonTapped:selector];
    }
}

- (void) handleLongPressOnButton:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (delegate && [delegate respondsToSelector:@selector(longPressOnToolbarButton:)]) {
            UIButton *pressedButton = (UIButton *)gesture.view;
            [delegate longPressOnToolbarButton:pressedButton];
        }
    }
}

- (void) updateBadgeText: (NSString *) newBadgeText {
    if (self.rightInsetView) {
        [self.rightInsetView updateBadgeText:newBadgeText];
    }
}

- (void) resizeBadge {
    if (self.rightInsetView) {
        [self.rightInsetView resizeBadge];
    }
}

- (void) hideBadge {
    if (self.rightInsetView) {
        [self.rightInsetView hideBadge];
    }
}

- (void) showBadge {
    if (self.rightInsetView) {
        [self.rightInsetView showBadge];
    }
}

- (BOOL) badgeHidden {
    if (self.rightInsetView) {
        return [self.rightInsetView badgeHidden];
    }
    return YES;
}

- (NSString *) badgeText {
    if (self.rightInsetView) {
        return [self.rightInsetView badgeText];
    }
    return nil;
}

@end

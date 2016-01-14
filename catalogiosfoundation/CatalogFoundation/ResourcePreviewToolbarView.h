//
//  ToloPreviewSketchingToolbarView.h
//  ToloApp
//
//  Created by Torey Lomenda on 7/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResourceActionController.h"

@protocol ResourcePreviewToolbarDelegate <NSObject>

- (void) sketchButtonTapped: (id) sketchButton;
- (void) closeButtonTapped: (id) closeButton;
- (void) documentActionSelected: (DocActionType) docActionType;

@end
@interface ResourcePreviewToolbarView : UIToolbar<DocumentActionDelegate> {
    id<ResourcePreviewToolbarDelegate> __weak resourceToolbarDelegate;
    
    UIPopoverController *docActionsPopover;
    
    NSArray *toolbarItems;
}

@property (nonatomic, weak) id<ResourcePreviewToolbarDelegate> resourceToolbarDelegate;
@property (nonatomic, strong) UIPopoverController *docActionsPopover;

@end

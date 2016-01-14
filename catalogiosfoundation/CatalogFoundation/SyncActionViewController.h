//
//  SyncActionViewController.h
//  ToloApp
//
//  Created by Torey Lomenda on 7/12/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SYNC_CONTENT_NOW,
    SYNC_APPLY_CHANGES
} SyncActionType;

@protocol SyncActionDelegate <NSObject>
- (void) selectedSyncAction: (SyncActionType) syncAction;
@end

@interface SyncActionViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    id<SyncActionDelegate> __weak delegate;
    
    UILabel *lastUpdateLabel;
    UIButton *syncButton;
    UIButton *applyButton;
    
    UILabel *itemsToRemoveLabel;
    UILabel *itemsToAddLabel;
    UILabel *itemsToModifyLabel;
    
    UILabel *failedDownloadsLabel;
    UITableView *failedDownloadsTableView;
    
    UIActivityIndicatorView *inProgressIndicatorView;
    UILabel *inProgressIndicatorLabel;
}

@property (nonatomic, weak) id<SyncActionDelegate> delegate;

@end

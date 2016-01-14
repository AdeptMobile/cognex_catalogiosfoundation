//
//  ResourceActionController.h
//  ToloApp
//
//  Created by Torey Lomenda on 9/29/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DOC_ACTION_EMAIL_LINK
} DocActionType;

@protocol DocumentActionDelegate <NSObject>
- (void) selectedAction: (DocActionType) actionType;
@end

@interface ResourceActionController : UIViewController {
    id<DocumentActionDelegate> __weak delegate;
}

@property (nonatomic, weak) id<DocumentActionDelegate> delegate;
@end

//
//  RightToolbarInsetView.h
//  DonaldsonEngineApp
//
//  Created by Chris Pflepsen on 8/17/12.
//
//

#import <UIKit/UIKit.h>
#import "UIViewWithLayout.h"
#import "CustomBadge.h"

@protocol RightToolBarDelegate <NSObject>

-(void)handleSyncButton:(id)sender;
-(void)handleToolbarButton:(id)sender;

@end

@interface RightToolbarInsetView : UIViewWithLayout

@property (nonatomic, assign) id<RightToolBarDelegate> delegate;
@property (nonatomic, strong) CustomBadge *syncProgressBadge;
@property (nonatomic, strong) UIButton *syncButton;

- (void) updateBadgeText: (NSString *) newBadgeText;
- (void) resizeBadge;
- (void) hideBadge;
- (void) showBadge;
- (BOOL) badgeHidden;
- (NSString *) badgeText;

@end

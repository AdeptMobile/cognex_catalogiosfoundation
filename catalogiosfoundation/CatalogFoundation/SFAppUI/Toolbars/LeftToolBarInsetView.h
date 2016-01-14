//
//  LeftToolBarInsetView.h
//  DonaldsonEngineApp
//
//  Created by Chris Pflepsen on 8/17/12.
//
//

#import <UIKit/UIKit.h>
#import "UIViewWithLayout.h"

@protocol LeftToolbarDelegate <NSObject>

-(void)handleToolbarButton:(id)sender;
-(void)handleLongPressOnButton:(id)sender;

@end

@interface LeftToolBarInsetView : UIViewWithLayout

@property (nonatomic, weak) id<LeftToolbarDelegate> delegate;

@end

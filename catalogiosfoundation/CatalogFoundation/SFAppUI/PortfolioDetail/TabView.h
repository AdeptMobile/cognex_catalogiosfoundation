//
//  TabView.h
//  DonaldsonEngineApp
//
//  Created by Chris Pflepsen on 8/21/12.
//
//

#import <UIKit/UIKit.h>

#import "FXLabel.h"

#import "ContentViewBehavior.h"

@interface TabView : UIView

- (id)initWithFrame:(CGRect)frame andResourceItem:(id<ContentViewBehavior>)resourceItem;

-(void)selectTab;
-(void)unselectTab;

@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) FXLabel *resourceLabel;
@property (nonatomic, strong) id<ContentViewBehavior> resourceItem;

@end

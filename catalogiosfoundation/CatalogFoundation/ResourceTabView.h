//
//  ResourceTabView.h
//  CatalogFoundation
//
//  Created by Chris Pflepsen on 8/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResourceTabConfig.h"
#import "FXLabel.h"

@interface ResourceTabView : UIView

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) ResourceTabConfig *viewConfig;
@property (nonatomic, strong) FXLabel *titleLabel;

- (id)initWithFrame:(CGRect)frame config:(ResourceTabConfig *)tabConfig;

@end

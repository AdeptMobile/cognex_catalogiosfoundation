//
//  SFAppLayoutView.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/11/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import "UIViewWithLayout.h"

@protocol SFAppSetupViewDelegate <NSObject>

- (void)downloadSetupButtonPressed:(id)dlButton;
- (void)passwordSetupButtonPressed:(id)pwButton;
- (void)logoutButtonPressed:(id)logoutButton;

@end

@interface SFAppSetupView : UIViewWithLayout

@property (nonatomic, weak) id<SFAppSetupViewDelegate>delegate;

@end

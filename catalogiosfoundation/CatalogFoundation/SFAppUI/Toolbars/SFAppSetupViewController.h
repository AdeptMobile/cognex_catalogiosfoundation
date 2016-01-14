//
//  SFAppSetupViewController.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/11/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFAppSetupView.h"

@protocol SFAppSetupViewControllerDelegate <NSObject>

- (void)setupChangePasswordPressed;
- (void)setupChangeDownloadPressed;
- (void)setupLogoutPressed;

@end

@interface SFAppSetupViewController : UIViewController<SFAppSetupViewDelegate>

@property (nonatomic, weak) id<SFAppSetupViewControllerDelegate>delegate;

@end

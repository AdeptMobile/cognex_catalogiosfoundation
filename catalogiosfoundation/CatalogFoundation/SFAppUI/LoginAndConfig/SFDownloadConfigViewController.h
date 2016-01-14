//
//  SFDownloadConfigViewController.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/6/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFDownloadViewConfig.h"
#import "SFDownloadConfigView.h"

@interface SFDownloadConfigViewController : UIViewController<SFDownloadViewDelegate>

@property (nonatomic, assign) BOOL modal;

- (id)initAsModal;

@end

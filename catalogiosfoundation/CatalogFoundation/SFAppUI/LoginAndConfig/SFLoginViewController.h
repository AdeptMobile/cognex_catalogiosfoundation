//
//  SFLoginViewController.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/4/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ExtUIViewController.h"
#import "SFLoginView.h"

@interface SFLoginViewController : ExtUIViewController<SFLoginViewDelegate, MFMailComposeViewControllerDelegate>

@end

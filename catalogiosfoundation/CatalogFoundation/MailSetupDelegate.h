//
//  MailSetup.h
//  ContentFoundation
//
//  Created by Steven McCoole on 7/30/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "ContentItem.h"

@protocol MailSetupDelegate <NSObject>

- (MFMailComposeViewController *)setupEmailForContentItem:(ContentItem *)contentItem;

@end

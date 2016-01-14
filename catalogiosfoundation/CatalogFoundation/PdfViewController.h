//
//  PdfViewController.h
//  ToloApp
//
//  Created by Torey Lomenda on 7/14/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <FastPdfKit/FastPdfKit.h>

#import "MailSetupDelegate.h"
#import "PdfPreviewToolbarView.h"

@interface PdfViewController : MFDocumentViewController<MFMailComposeViewControllerDelegate,MFDocumentViewControllerDelegate,PdfPreviewToolbarDelegate, UIGestureRecognizerDelegate> {
    NSURL *documentUrl;
    
    PdfPreviewToolbarView *toloToolbar;
    
    UILabel * pageLabel;
	UISlider * pageSlider;
    
    NSObject<MailSetupDelegate> *__weak mailSetupDelegate;
    
    MFDocumentManager *docManager;
}

@property (nonatomic, weak) NSObject<MailSetupDelegate> *mailSetupDelegate;
@property (nonatomic, strong) MFDocumentManager *docManager;

- (id) initWithUrl: (NSURL *) url;
@end

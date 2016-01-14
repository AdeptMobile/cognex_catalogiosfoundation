//
//  OutlineViewController.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/30/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdfContentOutlineViewControllerDelegate.h"

@class DocumentViewController;

@interface PdfContentOutlineViewController : UITableViewController {
    UIPopoverController *outlinePopover;
    
	NSMutableArray *outlineEntries;
	NSMutableArray *openOutlineEntries;
	
	NSObject<PdfContentOutlineViewControllerDelegate> *__weak delegate;
}

@property (nonatomic, strong) NSArray *outlineEntries;
@property (nonatomic, strong) NSArray *openOutlineEntries;
@property (weak) NSObject<PdfContentOutlineViewControllerDelegate> *delegate;
@end

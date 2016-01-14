//
//  BookmarkViewController.h
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/27/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdfBookmarkViewControllerDelegate.h"

#define STATUS_NORMAL 0
#define STATUS_EDITING 1

@class DocumentViewController;

@interface PdfBookmarkViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	NSUInteger status;
	NSMutableArray * bookmarks;
	
	UIToolbar * toolbar;
    UITableView * bookmarksTableView;
	
    //	Delegate to get the current page and tell to show a certain page. It can also be used to
    //	get a list of bookmarks for the current document. 
	NSObject<PdfBookmarkViewControllerDelegate> *__weak delegate;
	
}

@property (nonatomic, strong) NSMutableArray *bookmarks;
@property (nonatomic, weak) NSObject<PdfBookmarkViewControllerDelegate> *delegate;

@end

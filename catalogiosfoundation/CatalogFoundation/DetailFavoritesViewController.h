//
//  DetailFavoritesViewController.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/2/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailFavoritesViewControllerDelegate.h"

#define STATUS_NORMAL 0
#define STATUS_EDITING 1

@interface DetailFavoritesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    NSUInteger status;
    NSMutableArray *detailFavorites;
    
    UIToolbar *toolbar;
    UITableView *detailFavoritesTableView;
    
    NSObject<DetailFavoritesViewControllerDelegate> *__weak delegate;
    
    UIBarButtonItem *addBookmarkBtn;
}

@property (nonatomic, strong) NSMutableArray *detailFavorites;
@property (nonatomic, weak) NSObject<DetailFavoritesViewControllerDelegate> *delegate;
@property (nonatomic, strong) UIBarButtonItem *addBookmarkBtn;

@end

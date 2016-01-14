//
//  DetailSearchViewController.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/11/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailSearchViewControllerDelegate.h"

@interface DetailSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    NSArray *detailSearchResults;
    
    UITableView *detailSearchResultsTableView;
    
    NSObject<DetailSearchViewControllerDelegate> *__weak delegate;
    
    UISearchBar *searchBar;
    UIToolbar *toolbar;
    UIBarButtonItem *searchClearBtn;
}

@property (nonatomic, strong) NSArray *detailSearchResults;
@property (nonatomic, weak) NSObject<DetailSearchViewControllerDelegate> *delegate;
@property (nonatomic, strong) UIBarButtonItem *searchClearBtn;

@end

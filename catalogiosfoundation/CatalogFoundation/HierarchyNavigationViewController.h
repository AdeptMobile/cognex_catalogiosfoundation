//
//  HierarchyNavigationViewController.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HierarchyNavigationViewControllerDelegate.h"

@interface HierarchyNavigationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSArray *controllers;
    
    UITableView *hierarchyNavigationTableView;
    
    NSObject<HierarchyNavigationViewControllerDelegate> *__weak delegate;
    UINavigationController *__weak navController;
    BOOL rootLevelVCAtTop;
}

@property BOOL rootLevelVCAtTop;

@property (nonatomic, strong) NSArray *controllers;
@property (nonatomic, weak) NSObject<HierarchyNavigationViewControllerDelegate> *delegate;
@property (nonatomic, weak) UINavigationController *navController;

@end

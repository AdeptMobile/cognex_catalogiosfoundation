//
//  HierarchyNavigationViewControllerDelegate.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentViewBehavior.h"

@class HierarchyNavigationViewController;

@protocol HierarchyNavigationViewControllerDelegate <NSObject>

- (void) hierarchyNavigationController:(HierarchyNavigationViewController *)hnvc didSelectControllerIndex:(NSInteger)controllerIndex;
- (id<ContentViewBehavior>) contentForNavigationDisplay;

@end

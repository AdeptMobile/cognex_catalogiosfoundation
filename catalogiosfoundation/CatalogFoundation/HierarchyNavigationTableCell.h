//
//  HierarchyNavigationTableCell.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControllerReference.h"

@interface HierarchyNavigationTableCell : UITableViewCell {
    ControllerReference *controller;
    
    UILabel *hierarchyNavigationLabel;
    UIImageView *hierarchyNavigationThumbnail;
}

@property (nonatomic, strong) ControllerReference *controller;

@end

//
//  DetailFavoriteTableCell.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/2/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailReference.h"

@interface DetailFavoriteTableCell : UITableViewCell {
    BOOL isInEditMode;
    DetailReference *favorite;
    
    UILabel *favoriteLabel;
    UITextField *favoriteTextField;
}

@property (nonatomic, assign, getter = isInEditMode) BOOL isInEditMode;
@property (nonatomic, strong) DetailReference *favorite;

@property (nonatomic, readonly) UITextField *favoriteTextField;
@end

//
//  DetailSearchTableCell.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/11/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailReference.h"

@interface DetailSearchTableCell : UITableViewCell {
    DetailReference *searchResult;
    
    UILabel *searchResultLabel;
    UIImageView *searchResultThumbnail;
}

@property (nonatomic, strong) DetailReference *searchResult;

@end

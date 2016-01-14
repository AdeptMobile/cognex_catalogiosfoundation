//
//  BookmarkTableCell.h
//  ToloApp
//
//  Created by Torey Lomenda on 7/26/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bookmark.h"

//@protocol BookmarkTableCellDelegate <NSObject>
//
//- (void) 
//
//@end

@interface BookmarkTableCell : UITableViewCell {
    BOOL isInEditMode;
    Bookmark *bookmark;
    
    UILabel *bookmarkLabel;
    UITextField *bookmarkTextField;
}

@property (nonatomic, assign, getter=isInEditMode) BOOL isInEditMode;
@property (nonatomic, strong) Bookmark *bookmark;

@property (nonatomic, readonly) UITextField *bookmarkTextField;
@end

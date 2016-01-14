//
//  BookmarkTableCell.m
//  ToloApp
//
//  Created by Torey Lomenda on 7/26/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "BookmarkTableCell.h"

#define MARGIN_TOP_BOTTOM 5.0f
#define MARGIN_LEFT_RIGHT 10.0f

@interface BookmarkTableCell()

- (void) updateBookmarkName: (id) sender;

@end
@implementation BookmarkTableCell

@synthesize isInEditMode;
@synthesize bookmark;
@synthesize bookmarkTextField;

#pragma mark - 
#pragma mark init/dealloc Methods
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        isInEditMode = NO;
        
        // Initialization code
        bookmarkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        bookmarkLabel.textAlignment = NSTextAlignmentLeft;
        bookmarkLabel.adjustsFontSizeToFitWidth = YES;
        bookmarkLabel.hidden = YES;
        
        bookmarkTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        bookmarkTextField.borderStyle = UITextBorderStyleRoundedRect;
        bookmarkTextField.keyboardType = UIKeyboardTypeDefault;
        bookmarkTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        bookmarkTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        bookmarkTextField.returnKeyType = UIReturnKeyDone;
        // [bookmarkTextField addTarget:self action:@selector(updateBookmarkName:) forControlEvents:(UIControlEvents) UITextFieldTextDidEndEditingNotification];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(updateBookmarkName:) name:UITextFieldTextDidEndEditingNotification object:bookmarkTextField];
        bookmarkTextField.hidden = YES;
        
        [self.contentView addSubview:bookmarkLabel];
        [self.contentView addSubview:bookmarkTextField];
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:bookmarkTextField];
    
    bookmark = nil;
    
}

#pragma mark -
#pragma mark Accessor Methods
//=========================================================== 
// - setBookmark:
//=========================================================== 
- (void)setBookmark:(Bookmark *)aBookmark {
    if (bookmark != aBookmark) {
        bookmark = aBookmark;
        
        bookmarkLabel.text = aBookmark.name;
        bookmarkTextField.text = aBookmark.name;
    }
}


#pragma mark -
#pragma mark layout subviews
- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentRect = self.contentView.bounds;
    
    bookmarkLabel.frame = CGRectMake(MARGIN_LEFT_RIGHT, MARGIN_TOP_BOTTOM, contentRect.size.width - MARGIN_LEFT_RIGHT*2, contentRect.size.height - MARGIN_TOP_BOTTOM*2);
    bookmarkTextField.frame = CGRectMake(MARGIN_LEFT_RIGHT, MARGIN_TOP_BOTTOM, contentRect.size.width - MARGIN_LEFT_RIGHT*2, contentRect.size.height - MARGIN_TOP_BOTTOM*2);
    
    if (!isInEditMode) {
        bookmarkLabel.hidden = NO;
        bookmarkTextField.hidden = YES;
    } else {
        bookmarkLabel.hidden = YES;
        bookmarkTextField.hidden = NO;
    }
}

#pragma mark -
#pragma mark Private Methods
- (void) updateBookmarkName:(id)sender {
    bookmark.name = bookmarkTextField.text;
    bookmarkLabel.text = bookmarkTextField.text;
}

@end

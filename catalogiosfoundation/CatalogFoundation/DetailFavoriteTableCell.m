//
//  DetailFavoriteTableCell.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/2/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "DetailFavoriteTableCell.h"

#define MARGIN_TOP_BOTTOM 5.0f
#define MARGIN_LEFT_RIGHT 10.0f

@interface DetailFavoriteTableCell()

- (void) updateFavoriteName:(id)sender;

@end

@implementation DetailFavoriteTableCell

@synthesize isInEditMode;
@synthesize favorite;
@synthesize favoriteTextField;

#pragma mark - init/dealloc

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        isInEditMode = NO;
        
        favoriteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        favoriteLabel.textAlignment = NSTextAlignmentLeft;
        favoriteLabel.adjustsFontSizeToFitWidth = YES;
        favoriteLabel.hidden = YES;
        
        favoriteTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        favoriteTextField.borderStyle = UITextBorderStyleRoundedRect;
        favoriteTextField.keyboardType = UIKeyboardTypeDefault;
        favoriteTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        favoriteTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        favoriteTextField.returnKeyType = UIReturnKeyDone;
        //[favoriteTextField addTarget:self action:@selector(updateFavoriteName:) forControlEvents:(UIControlEvents) UITextFieldTextDidEndEditingNotification];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(updateFavoriteName:) name:UITextFieldTextDidEndEditingNotification object:favoriteTextField];
        favoriteTextField.hidden = YES;
        
        [self.contentView addSubview:favoriteLabel];
        [self.contentView addSubview:favoriteTextField];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:favoriteTextField];
    
    favorite = nil;
    
}

#pragma mark - accessor methods
- (void)setFavorite:(DetailReference *)aFavorite {
    if (favorite != aFavorite) {
        favorite = aFavorite;
        
        favoriteLabel.text = aFavorite.name;
        favoriteTextField.text = aFavorite.name;
    }
}

#pragma mark - layout method
- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentRect = self.contentView.bounds;
    
    favoriteLabel.frame = CGRectMake(MARGIN_LEFT_RIGHT, MARGIN_TOP_BOTTOM, contentRect.size.width - MARGIN_LEFT_RIGHT*2, contentRect.size.height - MARGIN_TOP_BOTTOM*2);
    favoriteTextField.frame = CGRectMake(MARGIN_LEFT_RIGHT, MARGIN_TOP_BOTTOM, contentRect.size.width - MARGIN_LEFT_RIGHT*2, contentRect.size.height - MARGIN_TOP_BOTTOM*2);
    
    if (!isInEditMode) {
        favoriteLabel.hidden = NO;
        favoriteTextField.hidden = YES;
    } else {
        favoriteLabel.hidden = YES;
        favoriteTextField.hidden = NO;
    }
}

#pragma mark - private methods
- (void) updateFavoriteName:(id)sender {
    favorite.name = favoriteTextField.text;
    favoriteLabel.text = favoriteTextField.text;
}

@end

//
//  DetailSearchTableCell.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/11/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "DetailSearchTableCell.h"

#define MARGIN_TOP_BOTTOM 5.0f
#define MARGIN_LEFT_RIGHT 10.0f

@implementation DetailSearchTableCell

@synthesize searchResult;

#pragma mark - init/dealloc
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        searchResultLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        searchResultLabel.textAlignment = NSTextAlignmentLeft;
        searchResultLabel.adjustsFontSizeToFitWidth = YES;
        
        searchResultThumbnail = [[UIImageView alloc] initWithFrame:CGRectZero];
        searchResultThumbnail.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.contentView addSubview:searchResultLabel];
        [self.contentView addSubview:searchResultThumbnail];
        
    }
    return self;
}

- (void) dealloc {
    searchResult = nil;
    
}

#pragma mark - UITableViewCell lifecycle
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - accessors
- (void) setSearchResult:(DetailReference *)aSearchResult {
    if (searchResult != aSearchResult) {
        searchResult = aSearchResult;
        
        searchResultLabel.text = aSearchResult.name;
        [searchResultThumbnail setImage:aSearchResult.detailThumbnail];
    }
}

#pragma mark - layout
- (void) layoutSubviews {
    
    [super layoutSubviews];
    
    CGRect r = self.contentView.bounds;
    CGFloat w = r.size.width;
    
    CGRect labelFrame = CGRectZero;
    CGRect imageFrame = CGRectZero;
    
    CGRectDivide(r, &labelFrame, &imageFrame, w * 0.66f, CGRectMinXEdge);
    labelFrame = CGRectInset(labelFrame, MARGIN_LEFT_RIGHT, MARGIN_TOP_BOTTOM);
    imageFrame = CGRectInset(imageFrame, MARGIN_LEFT_RIGHT, MARGIN_TOP_BOTTOM);
    
    searchResultLabel.frame = CGRectIntegral(labelFrame);
    searchResultThumbnail.frame = CGRectIntegral(imageFrame);

}

@end

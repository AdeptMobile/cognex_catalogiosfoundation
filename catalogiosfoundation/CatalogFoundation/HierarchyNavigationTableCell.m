//
//  HierarchyNavigationTableCell.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "HierarchyNavigationTableCell.h"

#define MARGIN_TOP_BOTTOM 5.0f
#define MARGIN_LEFT_RIGHT 10.0f

@implementation HierarchyNavigationTableCell

@synthesize controller;

#pragma mark - init/dealloc
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        hierarchyNavigationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        hierarchyNavigationLabel.textAlignment = NSTextAlignmentLeft;
        hierarchyNavigationLabel.adjustsFontSizeToFitWidth = YES;
        
        hierarchyNavigationThumbnail = [[UIImageView alloc] initWithFrame:CGRectZero];
        hierarchyNavigationThumbnail.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.contentView addSubview:hierarchyNavigationLabel];
        [self.contentView addSubview:hierarchyNavigationThumbnail];
        
    }
    return self;
}

- (void) dealloc {
    controller = nil;
    
}

#pragma mark - UITableViewCell lifecycle
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - accessors
- (void) setController:(ControllerReference *)aController {
    if (controller != aController) {
        controller = aController;
        
        hierarchyNavigationLabel.text = aController.name;
        [hierarchyNavigationThumbnail setImage:aController.controllerThumbnail];
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
    
    hierarchyNavigationLabel.frame = CGRectIntegral(labelFrame);
    hierarchyNavigationThumbnail.frame = CGRectIntegral(imageFrame);
    
}

@end

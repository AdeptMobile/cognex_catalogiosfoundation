//
//  ProductThumbnailConfig.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 2/20/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductThumbnailConfig : NSObject {
    
    UIColor *highlightBackgroundColor;
    UIColor *labelTextColor;
    UIColor *labelBackgroundColor;
    UIColor *noPreviewLabelTextColor;
    UIColor *noPreviewLabelBackgroundColor;
    UIColor *thumbnailImageBackgroundColor;
    UIColor *thumbnailViewBackgroundColor;
    
    BOOL labelMultiLine;
    BOOL isLabelAllCaps;
    
    // New additions - SICK style product thumbnails - SMM 04/10/2012
    
    // What size should be used to scale and crop the thumbnail.  Used to be
    // thumbnailHeight and thumbnailWidth.
    CGSize scaleSize;
    
    // What size should the final thumbnail image be.  Old style had
    // it using up the entire view.
    CGSize imageSize;
    
    // If we are going to generate a reflection of the thumbnail image
    // what size should it be?
    CGSize reflectionSize;
    
    // What size should the label be?  Used to be set depending
    // on the labelMultiLine boolean.
    CGSize labelSize;
    
    // If the background image name is specified it will be used
    // instead of the thumbnailViewBackgroundColor.
    NSString *backgroundImageName;
    
    // Set this if you want a border drawn around the final thumbnail image.
    UIColor *iconBorderColor;

    // Set this if you want the contents of the thumbnail to be inset from 
    // the edges.  Used if you have a background you want to show.
    CGFloat margin;
    
    // If this is YES, the label background color will be used as 
    // an alpha gradient rather than a solid color.
    BOOL labelBackgroundGradient;
    
    //New additions - Donaldson style
    BOOL isLabelAboveImage;
    BOOL roundedCorners;
    UIFont *labelFont;

}

@property (nonatomic, strong) UIColor *highlightBackgroundColor;
@property (nonatomic, strong) UIColor *labelTextColor;
@property (nonatomic, strong) UIColor *labelBackgroundColor;
@property (nonatomic, strong) UIColor *noPreviewLabelTextColor;
@property (nonatomic, strong) UIColor *noPreviewLabelBackgroundColor;
@property (nonatomic, strong) UIColor *thumbnailImageBackgroundColor;
@property (nonatomic, strong) UIColor *thumbnailViewBackgroundColor;

@property (nonatomic, assign) BOOL labelMultiLine;
@property (nonatomic, assign, getter=isLabelAllCaps) BOOL isLabelAllCaps;

// New additions - SICK style product thumbnails - SMM 04/10/2012
@property (nonatomic, assign) CGSize scaleSize;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) CGSize reflectionSize;
@property (nonatomic, assign) CGSize labelSize;
@property (nonatomic, copy) NSString *backgroundImageName;
@property (nonatomic, strong) UIColor *iconBorderColor;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) BOOL labelBackgroundGradient;

// New additions - Donaldson style
@property (nonatomic, assign) BOOL isLabelAboveImage;
@property (nonatomic, assign) BOOL roundedCorners;
@property (nonatomic, strong) UIFont *labelFont;
@property (nonatomic, strong) UIColor *labelShadowColor;
@property (nonatomic, assign) CGSize labelShadowOffset;

@property (nonatomic, assign, getter=isReflectionOn) BOOL isReflectionOn;


@end

//
//  ResourcePreviewConfig.h
//  CatalogFoundation
//
//  Created by Chris Pflepsen on 8/23/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResourcePreviewConfig : NSObject

@property (nonatomic, assign, getter=usesTitleOverlay) BOOL usesTitleOverlay;
@property (nonatomic, strong) UIColor *overlayColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) NSString *overlayImageForColor;

@property (nonatomic, strong) UIColor *previewMainBgColor;
@property (nonatomic, strong) UIColor *previewContentBgColor;
@property (nonatomic, strong) UIColor *previewContentImageBgColor;
@property (nonatomic, strong) UIColor *previewContentPdfBgColor;

@property (nonatomic, strong) UIColor *docStripBorderColor;
@property (nonatomic, strong) UIColor *docStripTabBgColor;
@property (nonatomic, strong) UIColor *docStripTabTextColor;
@property (nonatomic, strong) NSString *docStripBgImageNamed;

@property (nonatomic, strong) UIColor *previewThumbHighlightBgColor;
@property (nonatomic, strong) UIColor *previewThumbBgColor;
@property (nonatomic, strong) UIColor *previewThumbNoPreviewBgColor;
@property (nonatomic, strong) UIColor *previewThumbNoPreviewTextColor;

@property (nonatomic, strong) UIColor *previewThumbLabelBgColor;
@property (nonatomic, strong) UIColor *previewThumbLabelTextColor;
@property (nonatomic, strong) UIColor *previewThumbLabelBorderColor;
@property (nonatomic, assign) float previewThumbLabelFontSize;
@property (nonatomic, assign) NSInteger previewThumbnailLabelMaxLength;


@end

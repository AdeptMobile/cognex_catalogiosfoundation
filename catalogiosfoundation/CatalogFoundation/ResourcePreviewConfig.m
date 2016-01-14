//
//  ResourcePreviewConfig.m
//  CatalogFoundation
//
//  Created by Chris Pflepsen on 8/23/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ResourcePreviewConfig.h"

@implementation ResourcePreviewConfig

@synthesize usesTitleOverlay = _usesTitleOverlay;
@synthesize overlayColor = _overlayColor;
@synthesize titleFont = _titleFont;
@synthesize titleColor = _titleColor;
@synthesize overlayImageForColor = _overlayImageForColor;

@synthesize previewMainBgColor = _previewMainBgColor;
@synthesize previewContentBgColor = _previewContentBgColor;
@synthesize previewContentImageBgColor = _previewContentImageBgColor;
@synthesize previewContentPdfBgColor = _previewContentPdfBgColor;

@synthesize docStripBorderColor = _docStripBorderColor;
@synthesize docStripTabBgColor = _docStripTabBgColor;
@synthesize docStripTabTextColor = _docStripTabTextColor;
@synthesize docStripBgImageNamed = _docStripBgImageNamed;

@synthesize previewThumbHighlightBgColor = _previewThumbHighlightBgColor;
@synthesize previewThumbNoPreviewBgColor = _previewThumbNoPreviewBgColor;
@synthesize previewThumbNoPreviewTextColor = _previewThumbNoPreviewTextColor;

@synthesize previewThumbLabelBorderColor = _previewThumbLabelBorderColor;
@synthesize previewThumbLabelBgColor = _previewThumbLabelBgColor;
@synthesize previewThumbLabelTextColor = _previewThumbLabelTextColor;
@synthesize previewThumbLabelFontSize = _previewThumbLabelFontSize;
@synthesize previewThumbnailLabelMaxLength = _previewThumbnailLabelMaxLength;


-(id)init {
    
    if (self = [super init]) {
        self.usesTitleOverlay = NO;
    }
    return self;
}


@end

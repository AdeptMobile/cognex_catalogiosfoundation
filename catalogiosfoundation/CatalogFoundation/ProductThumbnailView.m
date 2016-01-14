//
//  ContentThumbnailView.m
//  ToloApp
//
//  Created by Torey Lomenda on 6/7/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ProductThumbnailView.h"

#import "UIView+ViewLayout.h"
#import "UIImage+Resize.h"
#import "UIImage+Extensions.h"
#import "UIImage+Alpha.h"
#import "UIImage+CatalogFoundationResourceImage.h"
#import "UIView+ImageRender.h"
#import "UIColor+Chooser.h"
#import "UIScreen+Helpers.h"
#import "NSString+Extensions.h"

#import "ContentUtils.h"

#define LABEL_SPACING 5.0f

#define MARGIN_TOP 100.0f
#define MARGIN_RIGHT 10.0f
#define YOFFSET 26.0f

#define PRODUCTINFO_WIDTH 512.0f
#define PRODUCTINFO_HEIGHT 410.0f

@interface ProductThumbnailView()

- (void) setupThumbnailView;

- (void) onThumbnailTap:(id) selector; 

-(UIImage *) scaleAndCropImage:(UIImage *)image withRect: (CGRect) rect;

@end

@implementation ProductThumbnailView

@synthesize delegate, itemContentPath, thumbnailImage;

#pragma mark -
#pragma mark init/dealloc
- (id) initWithFrame:(CGRect)frame thumbnailConfig:(ProductThumbnailConfig *)aConfig andItemPath: (id<ContentViewBehavior>)itemPath {
    self = [super initWithFrame:frame];
    if (self) {
        config = aConfig;
        
        // Initialization code        
        itemContentPath = itemPath;
        
        // Add the View to highlight when thumbnail is selected
        highlightedView = [[UIView alloc] initWithFrame:CGRectZero];
        highlightedView.backgroundColor = config.highlightBackgroundColor;
        highlightedView.alpha = 0.0;
        
        [self addSubview:highlightedView];
        
        // setup the thumbnail
        [self setupThumbnailView];
        
        // Add a UIControl
        thumbnailControlView = [[UIControl alloc] initWithFrame:CGRectZero];
        [thumbnailControlView sendActionsForControlEvents:UIControlEventTouchUpInside];
        [thumbnailControlView addTarget:self action:@selector(onThumbnailTap:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:thumbnailControlView];
        
        if (config.roundedCorners) {
            self.layer.cornerRadius = 12.0;
            self.clipsToBounds = YES;
        }
        
    }
    return self;
}

- (void)dealloc {
    config = nil;
    
}

#pragma mark -
#pragma mark ExpandFromOverlay Protocol
- (UIImage *) getThumbnail {
    if (thumbnailImage) {
        return thumbnailImage.image;
    }
    
    return nil;
}

- (CGRect) getExpandToRect {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect screen = [UIScreen rectForScreenView:orientation];    
    
    return CGRectMake(screen.size.width - MARGIN_RIGHT - PRODUCTINFO_WIDTH, MARGIN_TOP + YOFFSET, PRODUCTINFO_WIDTH, PRODUCTINFO_HEIGHT-YOFFSET);
}

- (void) expandOverlayDismissed {
    highlightedView.hidden = YES;
}

#pragma mark - 
#pragma mark Layout Subviews
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void) layoutSubviews {
    [super layoutSubviews];
    
    // Thumbnail view background covers all of view.
    thumbnailView.frame = self.bounds;
    // Make sure we don't end up with a fractional boundary
    CGPoint viewCenter = CGPointMake(floorf(thumbnailView.center.x), floorf(thumbnailView.center.y));
    
    // Center the activity indicator for loading thumbnail images.
    thumbnailImageLoadingView.center = viewCenter;
    
    if (config.isLabelAboveImage) {
        CGRect workingFrame = self.bounds;
        if (config.margin > 0.0f) {
            workingFrame = CGRectInset(workingFrame, config.margin, config.margin);
        }
        
        //Image Layout
        CGRect imageFrame = workingFrame;
        
        if (CGSizeEqualToSize(config.imageSize, CGSizeZero)) {
            // Layout the image view (full width and height-y.origin)
            //imageFrame.size.height = workingFrame.size.height - config.labelSize.height;
            imageFrame.origin.y = config.labelSize.height;
            thumbnailImage.frame = imageFrame;
            highlightedView.frame = imageFrame;
        } else {
            // Change the size and center it horizontally in the view.
            imageFrame.size = config.imageSize;
            imageFrame.origin.y = config.labelSize.height;
            thumbnailImage.frame = imageFrame;
            thumbnailImage.center = CGPointMake(viewCenter.x, thumbnailImage.center.y);
            highlightedView.frame = imageFrame;
            highlightedView.center = thumbnailImage.center;
        }
        
        //Label Layout
        CGRect labelFrame = self.bounds;
        
        NSString *titleLabel = nil;
        
        if (config.isLabelAllCaps) {
            titleLabel = [[itemContentPath contentTitle] uppercaseString];
        } else {
            titleLabel = [itemContentPath contentTitle];
        }
        
        
        CGFloat actualFontSize = config.labelFont.pointSize;
        [titleLabel sizeWithFont:config.labelFont minFontSize:1.0f actualFontSize:&actualFontSize forWidth:config.labelSize.width lineBreakMode:NSLineBreakByWordWrapping];
        UIFont *adjustedFont = [UIFont fontWithName:config.labelFont.familyName size:actualFontSize];
        CGSize actualSize = [titleLabel sizeWithFont:adjustedFont forWidth:config.labelSize.width lineBreakMode:NSLineBreakByWordWrapping];
        
        if (actualFontSize < config.labelFont.pointSize) {
            labelFrame.size.width = config.labelSize.width;
            labelFrame.size.height = actualSize.height;
            
            itemLabel.frame = labelFrame;
            itemLabel.center = CGPointMake(viewCenter.x, config.labelSize.height / 2);
        }
        else{
            labelFrame.size.width = config.labelSize.width;
            labelFrame.size.height = config.labelSize.height;
            
            itemLabel.frame = labelFrame;
            itemLabel.center = CGPointMake(viewCenter.x, config.labelSize.height / 2);
        }

        thumbnailControlView.frame = self.bounds;
    }
    else{
        CGRect workingFrame = self.bounds;
        if (config.margin > 0.0f) {
            workingFrame = CGRectInset(workingFrame, config.margin, config.margin);
        }
        CGFloat y = workingFrame.origin.y;
        
        CGRect imageFrame = workingFrame;
        if (CGSizeEqualToSize(config.imageSize, CGSizeZero)) {
            // Layout the image view (full width and height-y.origin)
            imageFrame.size.height = workingFrame.size.height - config.labelSize.height;
            thumbnailImage.frame = imageFrame;
            highlightedView.frame = imageFrame;
        } else {
            // Change the size and center it horizontally in the view.
            imageFrame.size = config.imageSize;
            thumbnailImage.frame = imageFrame;
            thumbnailImage.center = CGPointMake(viewCenter.x, thumbnailImage.center.y);
            highlightedView.frame = imageFrame;
            highlightedView.center = thumbnailImage.center;
        }
        y = y + imageFrame.size.height;
        
        if (thumbnailReflection && !CGSizeEqualToSize(config.reflectionSize, CGSizeZero)) {
            CGRect reflectFrame = workingFrame;
            reflectFrame.origin.y = y;
            reflectFrame.size = config.reflectionSize;
            thumbnailReflection.frame = reflectFrame;
            thumbnailReflection.center = CGPointMake(viewCenter.x, thumbnailReflection.center.y);
        }
        
        CGRect labelFrame = workingFrame;
        // Set the label y origin from the bottom.
        labelFrame.origin.y = workingFrame.size.height - config.labelSize.height;
        labelFrame.size.height = config.labelSize.height;
        if (config.labelSize.width > 0.0f) {
            labelFrame.size.width = config.labelSize.width;
        }
        itemLabel.frame = labelFrame;
        if (config.labelSize.width > 0.0f) {
            itemLabel.center = CGPointMake(viewCenter.x, itemLabel.center.y);
        }
        

        thumbnailControlView.frame = self.bounds;
    }
}

#pragma mark - 
#pragma mark Public Methods
- (UIImage *) loadThumbnailImage {
    NSLog(@"Loading thumbnail file: %@", [itemContentPath contentThumbNail]);
    UIImage *thumbnail = nil;
    
    //HACK! isVideo check - Donaldson needs thumbnails from resource item videos as well - NF 10/19/2012
    BOOL isVideo = [[itemContentPath contentType] isEqualToString:@"movie"];

    // Always check to see if there is a thumbnail explicitly assigned first.  The user may choose to override
    // the icon generated from the video files.  SMM 10/4/2012
    if ([itemContentPath contentThumbNail]) {
        thumbnail = [UIImage imageWithContentsOfFile:[itemContentPath contentThumbNail]];
        if (isVideo) {
            // See if the resource is on the local storage.  If not, assume that it was
            // suppressed from the sync and should be shown as a "ghost" icon.
            NSString *filePath = [itemContentPath contentFilePath];
            BOOL resourceExists = [ContentUtils fileExists:filePath];
            if (resourceExists == NO) {
                thumbnail = [thumbnail imageByApplyingAlpha:0.5f];
            }
        }
    } else if (isVideo) {
        NSString *filePath = [itemContentPath contentFilePath];
        thumbnail = [ContentUtils itemContentPreviewImage:filePath];
        // See if the resource is on the local storage.  If not, assume that it was
        // suppressed from the sync and should be shown as a "ghost" icon.
        BOOL resourceExists = [ContentUtils fileExists:filePath];
        if (resourceExists == NO) {
            thumbnail = [thumbnail imageByApplyingAlpha:0.5f];
        }
    }
    else if ([itemContentPath hasImages]){
        thumbnail = [UIImage imageWithContentsOfFile:[[itemContentPath contentImages] objectAtIndex:0]];
    }
    else {
        thumbnail = [UIImage contentFoundationResourceImageNamed:@"not-found.png"];
    }
    
    return thumbnail;
}

- (void) thumbnailImageLoaded:(UIImage *)image {
    // Stop and remove the indicator
    [thumbnailImageLoadingView stopAnimating];
    
    thumbnailImageLoadingView.alpha = 0.0;
    [self sendSubviewToBack:highlightedView];
    
    if (image) {
        UIImage *thumbnail = [self scaleAndCropImage:image withRect:CGRectMake(0, 0, config.scaleSize.width, config.scaleSize.height)];
        thumbnailImage.contentMode = UIViewContentModeScaleAspectFit;
        thumbnailImage.image = thumbnail;
        if (thumbnailReflection) {
            thumbnailReflection.image = [thumbnailImage reflectedImage:config.reflectionSize.height alpha:1.0f];
        }
    } else {
        UILabel *noPreviewLabel = [[UILabel alloc] initWithFrame:thumbnailImage.bounds];
        noPreviewLabel.lineBreakMode = NSLineBreakByWordWrapping;
        noPreviewLabel.numberOfLines = 0;
        noPreviewLabel.backgroundColor = [UIColor whiteColor];
        noPreviewLabel.textColor = [UIColor blackColor];
        noPreviewLabel.textAlignment = NSTextAlignmentCenter;
        noPreviewLabel.font = [UIFont systemFontOfSize:14];
        noPreviewLabel.text = @"No Preview Available";
        noPreviewLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth; 
        noPreviewLabel.adjustsFontSizeToFitWidth = YES;
        [thumbnailImage addSubview:noPreviewLabel];
        //noPreviewLabel.center = thumbnailImage.center;
    } 
}

#pragma mark -
#pragma mark Private Methods
- (void) setupThumbnailView {
    thumbnailView = [[UIView alloc] initWithFrame:CGRectZero];
    if ([NSString isNotEmpty:config.backgroundImageName]) {
        thumbnailView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageResource:config.backgroundImageName]];
    } else {
        thumbnailView.backgroundColor = config.thumbnailViewBackgroundColor;
    }
    
    thumbnailImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    thumbnailImage.backgroundColor = config.thumbnailImageBackgroundColor;
    
    if (config.iconBorderColor != nil) {
        thumbnailImage.layer.borderWidth = 1.0f;
        thumbnailImage.layer.borderColor = [config.iconBorderColor CGColor];
    }
    
    if (config.isReflectionOn && !CGSizeEqualToSize(config.reflectionSize, CGSizeZero)) {
        thumbnailReflection = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    
    itemLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    if (config.labelMultiLine) {
        itemLabel.lineBreakMode = NSLineBreakByWordWrapping;
        itemLabel.numberOfLines = 0;
    }
    
    if (config.isLabelAllCaps) {
        itemLabel.text = [[itemContentPath contentTitle] uppercaseString];
    } else {
        itemLabel.text = [itemContentPath contentTitle];
    }
    
    //itemLabel.minimumFontSize = 10;
    itemLabel.minimumScaleFactor = 10.0/[UIFont labelFontSize];
    itemLabel.textAlignment = NSTextAlignmentCenter;
    itemLabel.adjustsFontSizeToFitWidth = YES;
    itemLabel.textColor = config.labelTextColor;
    itemLabel.backgroundColor = config.labelBackgroundColor;
    itemLabel.shadowColor = config.labelShadowColor;
    itemLabel.shadowOffset = config.labelShadowOffset;
    
    if ([config.labelFont isKindOfClass:[UIFont class]]) {
        itemLabel.font = config.labelFont;
    }
    else{
        itemLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    
    
    
    if (config.labelBackgroundGradient) {        
        /*
        // Break up the specified label background color so we can
        // adjust the opacity for the gradient.
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        CGFloat alpha;
        UIColor *labelBgColor = config.labelBackgroundColor;
        [labelBgColor getRed:&red green:&green blue:&blue alpha:&alpha];
        
        // The top of the gradient will be the background color at 50% 
        // opacity.
        UIColor *topColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.5f];
         */
        
        UIColor *topColor = [config.labelBackgroundColor colorByChangingAlphaTo:0.3f];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[config.labelBackgroundColor CGColor], nil];
        gradient.frame = itemLabel.bounds;
        [itemLabel.layer insertSublayer:gradient atIndex:0];
        
        // Set the background color property of the label to clear
        // so the gradient can show through.
        itemLabel.backgroundColor = [UIColor clearColor];
    }
    
    [thumbnailView addSubview:thumbnailImage];
    if (thumbnailReflection) {
        [thumbnailView addSubview:thumbnailReflection];
    }
    [thumbnailView addSubview:itemLabel];
    
    [self addSubview:thumbnailView];
    
    // Add an activity indicator to load the images in the background
    thumbnailImageLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [thumbnailImageLoadingView startAnimating];
    
    [self addSubview:thumbnailImageLoadingView];
    
}

-(UIImage *) scaleAndCropImage:(UIImage *)image withRect:(CGRect)rect {
    // Calculate image ratio
    CGFloat dimensionRatio = image.size.height/image.size.width;
    
    UIImage *scaledImage = [image resizedImage:CGSizeMake(rect.size.height/dimensionRatio, rect.size.height) interpolationQuality:kCGInterpolationHigh];
    return scaledImage; // [scaledImage croppedImage:CGRectMake(0, 0, rect.size.width, rect.size.height)];
}

#pragma mark -
#pragma mark UIControl Events
-(void) onThumbnailTap:(id) selector {
    
    // This serves the purpose of highlighting the thumbnail before the details are expanded into view.
    // Could use a NSOperation as well, but might be overkill for this :-)
    [self bringSubviewToFront:highlightedView];
    
    [UIView animateWithDuration:0.1 animations:^ {
        highlightedView.alpha = 0.5;
    }completion:^(BOOL finished) {
        if (delegate && [delegate respondsToSelector:@selector(thumbnailTapped:)]) {
            [delegate thumbnailTapped:self];
        }
        highlightedView.alpha = 0.0f;
        highlightedView.hidden = YES;
    }];
}

@end

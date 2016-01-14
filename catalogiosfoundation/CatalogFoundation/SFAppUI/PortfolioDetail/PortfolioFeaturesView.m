//
//  ProductFeaturesView.m
//  SickApp
//
//  Created by Steven McCoole on 4/24/12.
//  Copyright (c) 2012 Object Partners Inc. All rights reserved.
//

#import "PortfolioFeaturesView.h"

#import "SFAppConfig.h"

#import "UIView+ViewLayout.h"
#import "UIImage+Extensions.h"
#import "AlertUtils.h"
#import "NSString+Extensions.h"

#define TITLE_TAB_LABEL_WIDTH 304.0f
#define TAB_LABEL_WIDTH 184.0f
#define TAB_LABEL_HEIGHT  30.0f
#define FEATURES_SUFFIX @"-features.txt"
#define BENEFITS_SUFFIX @"-benefits.txt"
#define DELIMITER @"|"
#define DEFAULT_LINE_LEN 40
#define DEFAULT_LINES 8

@interface PortfolioFeaturesView() 

- (void) setupTabLabels;
- (void) setupText;
- (NSAttributedString *) attributedStringForResourceText:(id<ContentViewBehavior>)resourceItem;
- (void) showFeaturesTab:(UITapGestureRecognizer *)tapGesture;
- (void) showBenefitsTab:(UITapGestureRecognizer *)tapGesture;

@end

@implementation PortfolioFeaturesView

@synthesize contentProduct;
@synthesize featuresString;
@synthesize benefitsString;
@synthesize showingFeatures;

#pragma mark - init/dealloc
- (id) initWithFrame:(CGRect)frame andContentProduct:(id<ContentViewBehavior>)aContentProduct {
    self = [super initWithFrame:frame];
    if (self) {
        contentProduct = aContentProduct;
        [self setupTabLabels];
        [self setupText];
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -
#pragma mark Layout Subviews code
- (void) layoutSubviews {
    [super layoutSubviews];
    
    // layout the subviews
    CGRect featuresTabFrame = CGRectMake(0, 0, TITLE_TAB_LABEL_WIDTH, TAB_LABEL_HEIGHT);
    CGRect benefitsTabFrame = CGRectMake(self.bounds.size.width - TAB_LABEL_WIDTH, 0, TAB_LABEL_WIDTH, TAB_LABEL_HEIGHT);
    CGRect borderFrame = CGRectMake(0, TAB_LABEL_HEIGHT, self.bounds.size.width, self.bounds.size.height - TAB_LABEL_HEIGHT);
    // DTAttributedTextView is inside borderView.
    CGRect textFrame = CGRectMake(2.0f, 2.0f, borderFrame.size.width - 4.0f, borderFrame.size.height - 4.0f);
    
    featuresLabel.frame = featuresTabFrame;
    benefitsLabel.frame = benefitsTabFrame;
    borderView.frame = borderFrame;
    featuresTextView.frame = textFrame;
    benefitsTextView.frame = textFrame;
    // Have to set the string here, DTAttributedTextView calculates contentSize for scrolling when the attributed
    // string is set.
    featuresTextView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    featuresTextView.attributedString = featuresString;
    benefitsTextView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    benefitsTextView.attributedString = benefitsString;
    
    BasicPortfolioDetailViewConfig *config = [[SFAppConfig sharedInstance] getBasicPortfolioDetailViewConfig];
    
    [borderView applyBorderStyle:config.featuresViewBorderColor withBorderWidth:2.0f withShadow:NO];

    
}

#pragma mark -
#pragma mark Private Methods
- (void) setupTabLabels {
    BasicPortfolioDetailViewConfig *config = [[SFAppConfig sharedInstance] getBasicPortfolioDetailViewConfig];
    
    featuresLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    featuresLabel.textColor = config.featuresViewDetailLabelTextColor;
    featuresLabel.textAlignment = NSTextAlignmentCenter;
    featuresLabel.text = [contentProduct contentTitle];
    featuresLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    featuresLabel.backgroundColor = config.featuresViewDetailLabelBgColor;
    featuresLabel.adjustsFontSizeToFitWidth = YES;
    featuresLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *featuresTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(showFeaturesTab:)];
    featuresTap.numberOfTapsRequired = 1;
    [featuresLabel addGestureRecognizer: featuresTap];
    
    benefitsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    benefitsLabel.textColor = config.featuresViewBenefitLabelTextColor;
    benefitsLabel.textAlignment = NSTextAlignmentCenter;
    benefitsLabel.text = @"Benefits";
    benefitsLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    benefitsLabel.backgroundColor = config.featuresViewBenefitLabelBgColor;
    benefitsLabel.adjustsFontSizeToFitWidth = YES;
    benefitsLabel.userInteractionEnabled = YES;
    
    featuresLabel.hidden = config.isFeaturesLabelHidden;
    benefitsLabel.hidden = config.isBenefitsLabelHidden;
    
    UITapGestureRecognizer *benefitsTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(showBenefitsTab:)];
    benefitsTap.numberOfTapsRequired = 1;
    [benefitsLabel addGestureRecognizer: benefitsTap];
    
    borderView = [[UIView alloc] initWithFrame:CGRectZero];
    [DTAttributedTextContentView setLayerClass:[CATiledLayer class]];
    featuresTextView = [[DTAttributedTextView alloc] initWithFrame:CGRectZero];
    benefitsTextView = [[DTAttributedTextView alloc] initWithFrame:CGRectZero];
    // Hide the benefits view.
    benefitsTextView.alpha = 0.0f;
    showingFeatures = YES;
    [borderView addSubview:benefitsTextView];
    [borderView addSubview:featuresTextView];
    
    [self addSubview:borderView];
    [self addSubview:benefitsLabel];
    [self addSubview:featuresLabel];
}

- (void) setupText {
    if ([contentProduct hasResources]) {
        for (id<ContentViewBehavior>resourceGroup in [contentProduct contentResources]) {
            if ([resourceGroup hasResourceItems]) {
                for (id<ContentViewBehavior>resourceItem in [resourceGroup contentResourceItems]) {
                    if ([[resourceItem contentTitle] hasSuffix:FEATURES_SUFFIX] && [[resourceItem contentType] isEqualToString:CONTENT_TYPE_TEXT]) {
                        self.featuresString = [self attributedStringForResourceText:resourceItem];
                    } else if ([[resourceItem contentTitle] hasSuffix:BENEFITS_SUFFIX] && [[resourceItem contentType] isEqualToString:CONTENT_TYPE_TEXT]) {
                        self.benefitsString = [self attributedStringForResourceText:resourceItem];
                    }
                }
            }
        }
    }
}

- (NSAttributedString *) attributedStringForResourceText:(id<ContentViewBehavior>)resourceItem {
    NSError *error = nil;
    NSString *featuresText = [NSString stringWithContentsOfFile:[resourceItem contentFilePath] encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        error = nil;
        featuresText = [NSString stringWithContentsOfFile:[resourceItem contentFilePath] encoding:NSWindowsCP1250StringEncoding error:&error];
    }
    
    if (!error) {
        NSMutableString *htmlString = [NSMutableString stringWithCapacity:(DEFAULT_LINES * DEFAULT_LINE_LEN)];
        
        if ([featuresText isHTMLOrXMLMarkup]) {
            [htmlString appendString:featuresText];
        } else {
            NSArray *lines = [featuresText componentsSeparatedByString:DELIMITER];
        
            if (lines && [lines count] > 0) {
                [htmlString appendString:@"<ul>"];
                for (NSString *aFeature in lines) {
                    [htmlString appendFormat:@"<li style=\"font-family:'Helvetica';font-size:20px;\">%@</li>", aFeature];
                }
                [htmlString appendString:@"</ul>"];
            }
        }
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTMLData:[htmlString dataUsingEncoding:NSUTF8StringEncoding]
                                                                         documentAttributes:NULL];
        return attributedString;
    } else {
        NSString *message = [NSString stringWithFormat:@"error reading resource text file %@, error: %@", [resourceItem contentFilePath], [error localizedDescription]];
        NSLog(@"%@", message);
        [AlertUtils showModalAlertMessage:message withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
    return nil;
}

- (void) showFeaturesTab:(UITapGestureRecognizer *)tapGesture {
    if (showingFeatures == NO) {
        [UIView animateWithDuration:0.2
                         animations:^{ 
                             featuresTextView.alpha = 1.0;
                             benefitsTextView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished){ showingFeatures = YES; }];
    }
}

- (void) showBenefitsTab:(UITapGestureRecognizer *)tapGesture {
    if (showingFeatures == YES) {
        [UIView animateWithDuration:0.2
                         animations:^{ 
                             featuresTextView.alpha = 0.0;
                             benefitsTextView.alpha = 1.0f;
                         }
                         completion:^(BOOL finished){ showingFeatures = NO; }];
    }
}
@end

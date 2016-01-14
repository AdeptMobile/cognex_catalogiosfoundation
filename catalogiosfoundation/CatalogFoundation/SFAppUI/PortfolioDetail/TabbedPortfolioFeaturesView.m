//
//  ProductFeaturesView.m
//  SickApp
//
//  Created by Steven McCoole on 4/24/12.
//  Copyright (c) 2012 Object Partners Inc. All rights reserved.
//

#import "TabbedPortfolioFeaturesView.h"
#import "SFAppConfig.h"
#import "UIView+ViewLayout.h"
#import "UIImage+Extensions.h"
#import "NSString+Extensions.h"
#import "AlertUtils.h"
#import "TabbedPortfolioDetailViewConfig.h"
#import "TabView.h"
#import "UIImage+CatalogFoundationResourceImage.h"

#define DELIMITER @"|"
#define DEFAULT_LINE_LEN 40
#define DEFAULT_LINES 8

@interface TabbedPortfolioFeaturesView()

@property (nonatomic, strong) NSMutableArray *tabArray;

- (void) setupTabLabels;
- (void) setupText;
- (NSAttributedString *) attributedStringForResourceText:(id<ContentViewBehavior>)resourceItem;

-(void) updateDisplayText:(id)sender;

@end

@implementation TabbedPortfolioFeaturesView

@synthesize contentProduct;
@synthesize textView;
@synthesize tabArray;

#pragma mark - init/dealloc
- (id) initWithFrame:(CGRect)frame andContentProduct:(id<ContentViewBehavior>)aContentProduct {
    self = [super initWithFrame:frame];
    if (self) {
        contentProduct = aContentProduct;
        self.tabArray = [[NSMutableArray alloc] initWithCapacity:0];
        [self setupText];
        [self setupTabLabels];
    }
    return self;
}

#pragma mark -
#pragma mark Private Methods
- (void) setupTabLabels {
    
    int labelCount = 0;
    int labelOffest = 139;
    
    TabbedPortfolioDetailViewConfig *config = [[SFAppConfig sharedInstance] getTabbedPortfolioDetailViewConfig];
    
    if ([contentProduct hasResources]) {
        for (id<ContentViewBehavior>resourceGroup in [contentProduct contentResources]) {
            
            if ([resourceGroup contentTitle] && [[resourceGroup contentTitle] caseInsensitiveCompare:config.includedResourceGroup] == NSOrderedSame &&
                [resourceGroup hasResourceItems]) {
                
                int tabWidth = labelOffest;
                
                for (id<ContentViewBehavior> resourceItem in [resourceGroup contentResourceItems]) {
                    
                    // All but the first tab have a small gap in them for visual effect.
                    int spacing = (labelCount > 0) ? 6 : 0;
                    
                    //Offset the y by 1 so that the tabs and backgroundImageView look like one view
                    TabView *nextTab = [[TabView alloc] initWithFrame:CGRectMake((labelCount * labelOffest) + (labelCount *spacing), 1, tabWidth, 30) andResourceItem:resourceItem];
                    nextTab.tag = labelCount;
                    
                    UITapGestureRecognizer *featuresTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(updateDisplayText:)];
                    featuresTap.numberOfTapsRequired = 1;
                    [nextTab addGestureRecognizer: featuresTap];
                    
                    [self addSubview:nextTab];
                    [tabArray addObject:nextTab];
                    labelCount++;
                }
                [self setTabActive:0];
            }
            //There are no tabs so remove the view
        }
    }

}

- (void) setupText {
    TabbedPortfolioDetailViewConfig *config = [[SFAppConfig sharedInstance] getTabbedPortfolioDetailViewConfig];
    
    if (config.featuresViewBgImageNamed) {
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 578, 318)];
        backgroundImageView.image = [UIImage contentFoundationResourceImageNamed:config.featuresViewBgImageNamed];
    
        [self addSubview:backgroundImageView];
    } else {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, 578, 318)];
        backgroundView.backgroundColor = config.featuresViewBgColor;
        [backgroundView applyBorderStyle:config.featuresViewBorderColor withBorderWidth:2.0f withShadow:NO];
    }
    
    [DTAttributedTextContentView setLayerClass:[CATiledLayer class]];
    self.textView = [[DTAttributedTextView alloc] initWithFrame:CGRectMake(0, 30, 578, 318)];
    self.textView.attributedTextContentView.edgeInsets = UIEdgeInsetsMake(32, 36, 32, 36);
    self.textView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:textView];

}

- (NSAttributedString *) attributedStringForResourceText:(id<ContentViewBehavior>)resourceItem {
    
    TabbedPortfolioDetailViewConfig *config = [[SFAppConfig sharedInstance] getTabbedPortfolioDetailViewConfig];
    
    NSError *error = nil;
    NSString *featuresText = [NSString stringWithContentsOfFile:[resourceItem contentFilePath] encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        error = nil;
        featuresText = [NSString stringWithContentsOfFile:[resourceItem contentFilePath] encoding:NSWindowsCP1250StringEncoding error:&error];
    }
    
    NSMutableString *htmlString = [NSMutableString stringWithCapacity:(DEFAULT_LINES * DEFAULT_LINE_LEN)];
    
    if (!error) {
        if ([featuresText isHTMLOrXMLMarkup]) {
            [htmlString appendString:featuresText];
        } else {
            NSArray *lines = [featuresText componentsSeparatedByString:DELIMITER];

            if (lines && [lines count] > 0) {
                [htmlString appendString:@"<ul>"];
                for (NSString *aFeature in lines) {
                    [htmlString appendFormat:@"<li style=\"font-family:'%@';font-size:%.fpx;\">%@</li>", config.featuresViewResourceTextFont, config.featuresViewResourceTextFontSize, aFeature];
                }
                [htmlString appendString:@"</ul>"];
            }
        }
        
        UIColor *featureTextColor = config.featuresViewTextColor == nil ? [UIColor blackColor] : config.featuresViewTextColor;
        
        NSDictionary *stringOpts = [NSDictionary dictionaryWithObjectsAndKeys:featureTextColor, @"DTDefaultTextColor", config.featuresViewResourceTextFont, @"DTDefaultFontName", [NSNumber numberWithFloat:config.featuresViewResourceTextFontSize], @"DTDefaultFontSize", nil];
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithHTMLData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:stringOpts documentAttributes:NULL];

        return attributedString;
    } else {
        NSString *message = [NSString stringWithFormat:@"error reading resource text file %@, error: %@", [resourceItem contentFilePath], [error localizedDescription]];
        NSLog(@"%@", message);
        [AlertUtils showModalAlertMessage:message withTitle:[[SFAppConfig sharedInstance] getAppAlertTitle]];
    }
    return nil;
}


-(void) updateDisplayText:(UIGestureRecognizer *)sender{
    [self setTabActive:sender.view.tag];
}

-(void)setTabActive:(NSInteger)tag{
    for (TabView *nextTabView in tabArray) {
        if (nextTabView.tag == tag) {
            [nextTabView selectTab];
            self.textView.attributedString = [self attributedStringForResourceText:nextTabView.resourceItem];
            [self.textView setContentOffset:CGPointMake(0, 0) animated:NO];
        }
        else{
            [nextTabView unselectTab];
            
        }
    }
}

@end

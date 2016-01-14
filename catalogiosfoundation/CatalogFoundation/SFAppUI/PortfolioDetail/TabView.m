//
//  TabView.m
//  DonaldsonEngineApp
//
//  Created by Chris Pflepsen on 8/21/12.
//
//

#import "TabView.h"
#import "UIImage+Extensions.h"
#import "SFAppConfig.h"
#import "TabbedPortfolioDetailViewConfig.h"
#import "ContentViewBehavior.h"
#import "UIImage+CatalogFoundationResourceImage.h"

@implementation TabView

@synthesize backgroundImage, resourceLabel;
@synthesize resourceItem = _resourceItem;

- (id)initWithFrame:(CGRect)frame andResourceItem:(id<ContentViewBehavior>)resourceItem
{
    self = [super initWithFrame:frame];
    if (self) {
        TabbedPortfolioDetailViewConfig *config = [[SFAppConfig sharedInstance] getTabbedPortfolioDetailViewConfig];
        
        // Initialization code
        
        self.resourceItem = resourceItem;
        
        CGRect originRect = frame;
        originRect.origin = CGPointMake(0, 0);
        
        if (config.featuresViewInactiveTabLabelImageNamed) {
            self.backgroundImage = [[UIImageView alloc] initWithFrame:originRect];
            backgroundImage.image = [UIImage contentFoundationResourceImageNamed:config.featuresViewInactiveTabLabelImageNamed];
        } else {
            self.backgroundColor = config.featuresViewInactiveTabLabelBgColor;
        }
        
        self.resourceLabel = [[FXLabel alloc] initWithFrame:originRect];
        self.resourceLabel.text = [[resourceItem contentTitle] uppercaseString];
        self.resourceLabel.textAlignment = config.featuresviewTabLabelHorizontalAlignment;
        self.resourceLabel.contentMode = config.featuresViewTabLabelVerticalAlignment;
        self.resourceLabel.backgroundColor = [UIColor clearColor];
        self.resourceLabel.textColor = config.featuresViewInactiveTabLabelTextColor;
        self.resourceLabel.font = [UIFont fontWithName:config.featuresViewTabLabelFont size:config.featuresViewTabLabelFontSize];
        self.resourceLabel.shadowOffset = CGSizeMake(1, 1);
        self.resourceLabel.shadowColor = config.featuresViewInactiveTabLabelShadowColor;
        self.resourceLabel.adjustsFontSizeToFitWidth = YES;

        if (self.backgroundImage) {
            [self addSubview:self.backgroundImage];
        }
        [self addSubview:self.resourceLabel];
        
    }
    return self;
}

-(void)selectTab {
    TabbedPortfolioDetailViewConfig *config = [[SFAppConfig sharedInstance] getTabbedPortfolioDetailViewConfig];
    
    resourceLabel.textColor = config.featuresViewActiveTabLabelTextColor;
    resourceLabel.shadowOffset = CGSizeMake(0, 0);
    resourceLabel.shadowColor = config.featuresViewActiveTabLabelShadowColor;
    if (config.featuresViewActiveTabLabelImageNamed && self.backgroundImage) {
        self.backgroundImage.image = [UIImage contentFoundationResourceImageNamed:config.featuresViewActiveTabLabelImageNamed];
    } else {
        self.backgroundColor = config.featuresViewActiveTabLabelBgColor;
    }
}

-(void)unselectTab{
    TabbedPortfolioDetailViewConfig *config = [[SFAppConfig sharedInstance] getTabbedPortfolioDetailViewConfig];
    
    resourceLabel.textColor = config.featuresViewInactiveTabLabelTextColor;
    resourceLabel.shadowOffset = CGSizeMake(1, 1);
    resourceLabel.shadowColor = config.featuresViewInactiveTabLabelShadowColor;
    if (config.featuresViewInactiveTabLabelImageNamed && self.backgroundImage) {
        self.backgroundImage.image = [UIImage contentFoundationResourceImageNamed:config.featuresViewInactiveTabLabelImageNamed];
    } else {
        self.backgroundColor = config.featuresViewInactiveTabLabelBgColor;
    }
}

@end

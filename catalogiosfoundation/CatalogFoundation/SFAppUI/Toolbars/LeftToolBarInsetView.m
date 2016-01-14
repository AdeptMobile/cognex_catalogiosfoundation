//
//  LeftToolBarInsetView.m
//  DonaldsonEngineApp
//
//  Created by Chris Pflepsen on 8/17/12.
//
//

#import "LeftToolBarInsetView.h"
#import "SFAppConfig.h"
#import "UIImage+Extensions.h"
#import "UIImage+CatalogFoundationResourceImage.h"

#import "BorderLayout.h"
#import "FillLayOut.h"
#import "HorizontalLayout.h"

@interface LeftToolBarInsetView ()

-(void)handleToolbarButton:(id)sender;
-(void)handleLongPressOnButton:(id)sender;

@end

@implementation LeftToolBarInsetView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        ContentInfoToolbarConfig *config = [[SFAppConfig sharedInstance] getContentInfoToolbarConfig];
        
        if (config.leftInsetBgImageNamed) {
            self.backgroundColor = [UIColor colorWithPatternImage:[UIImage contentFoundationResourceImageNamed:config.leftInsetBgImageNamed]];
        } else {
            self.backgroundColor = [UIColor clearColor];
        }
        
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectZero];
        if (config.backBtnImageNamed) {
            [backButton setImage:[UIImage contentFoundationResourceImageNamed:config.backBtnImageNamed] forState:UIControlStateNormal];
        }
        [backButton addTarget:self action:@selector(handleToolbarButton:) forControlEvents:UIControlEventTouchUpInside];
        backButton.tag = 5;
        
        UILongPressGestureRecognizer *longPressOnBack = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressOnButton:)];
        [backButton addGestureRecognizer:longPressOnBack];
        
        [self addSubview:backButton];
                
        // If a home button is defined show it.
        if (config.homeBtnImageNamed) {
            UIButton *homeButton = [[UIButton alloc] initWithFrame:CGRectZero];
            [homeButton setImage:[UIImage contentFoundationResourceImageNamed:config.homeBtnImageNamed] forState:UIControlStateNormal];
            [homeButton addTarget:self action:@selector(handleToolbarButton:) forControlEvents:UIControlEventTouchUpInside];
            homeButton.tag = 6;
            [self addSubview:homeButton];
            layout = [HorizontalLayout margin:@"0px"
                                      padding:@"0px 6px 0px 6px"
                                       valign:@"center"
                                       halign:@"center"
                                        items:[ViewItem viewItemFor:backButton width:@"44px" height:@"44px"],
                      [ViewItem viewItemFor:homeButton width:@"44px" height:@"44px"], nil];
        } else {
            layout = [HorizontalLayout margin:@"0px"
                                      padding:@"0px"
                                       valign:@"center"
                                       halign:@"center"
                                        items:[ViewItem viewItemFor:backButton width:@"44px" height:@"44px"], nil];
        }

    }
    return self;
}

#pragma mark -
#pragma mark Layout and Drawing
- (void) layoutSubviews {
    [super layoutSubviews];
    
    [layout layoutForView:self];
    
}

#pragma mark -
#pragma mark Button Actions

-(void)handleToolbarButton:(id)sender{
    [delegate handleToolbarButton:sender];
}

-(void)handleLongPressOnButton:(id)sender{
    [delegate handleLongPressOnButton:sender];
}


@end

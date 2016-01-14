//
//  RightToolbarInsetView.m
//  DonaldsonEngineApp
//
//  Created by Chris Pflepsen on 8/17/12.
//
//

#import "RightToolbarInsetView.h"
#import "SFAppConfig.h"
#import "UIImage+CatalogFoundationResourceImage.h"
#import "UIImage+Extensions.h"

#import "BorderLayout.h"
#import "HorizontalLayout.h"

@interface RightToolbarInsetView () {

}

-(void)handleToolbarButton:(id)sender;
-(void)handleSyncButton:(id)sender;

@end

@implementation RightToolbarInsetView

@synthesize delegate;
@synthesize syncProgressBadge;
@synthesize syncButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        ContentInfoToolbarConfig *config = [[SFAppConfig sharedInstance] getContentInfoToolbarConfig];
        
        if (config.rightInsetBgImageNamed) {
            self.backgroundColor = [UIColor colorWithPatternImage:[UIImage contentFoundationResourceImageNamed:config.rightInsetBgImageNamed]];
        }
        
        UIButton *webLinkButton = [[UIButton alloc] initWithFrame:CGRectZero];
        if (config.webBtnImageNamed) {
            [webLinkButton setImage:[UIImage contentFoundationResourceImageNamed:config.webBtnImageNamed] forState:UIControlStateNormal];
        }
        [webLinkButton addTarget:self action:@selector(handleToolbarButton:) forControlEvents:UIControlEventTouchUpInside];
        webLinkButton.tag = 4;
        
        UIButton *prodFavsButton = [[UIButton alloc] initWithFrame:CGRectZero];
        if (config.bookmarkBtnImageNamed) {
            [prodFavsButton setImage:[UIImage contentFoundationResourceImageNamed:config.bookmarkBtnImageNamed] forState:UIControlStateNormal];
        }
        [prodFavsButton addTarget:self action:@selector(handleToolbarButton:) forControlEvents:UIControlEventTouchUpInside];
        prodFavsButton.tag = 3;
        
        UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectZero];
        if (config.searchBtnImageNamed) {
            [searchButton setImage:[UIImage contentFoundationResourceImageNamed:config.searchBtnImageNamed] forState:UIControlStateNormal];
        }
        [searchButton addTarget:self action:@selector(handleToolbarButton:) forControlEvents:UIControlEventTouchUpInside];
        searchButton.tag = 2;
        
        UIButton *sketchButton = [[UIButton alloc] initWithFrame:CGRectZero];
        if (config.sketchBtnImageNamed) {
            [sketchButton setImage:[UIImage contentFoundationResourceImageNamed:config.sketchBtnImageNamed] forState:UIControlStateNormal];
        }
        [sketchButton addTarget:self action:@selector(handleToolbarButton:) forControlEvents:UIControlEventTouchUpInside];
        sketchButton.tag = 1;
        
        self.syncButton = [[UIButton alloc] initWithFrame:CGRectZero];
        if (config.refreshBtnImageNamed) {
            [self.syncButton setImage:[UIImage contentFoundationResourceImageNamed:config.refreshBtnImageNamed] forState:UIControlStateNormal];
        }
        [self.syncButton addTarget:self action:@selector(handleSyncButton:) forControlEvents:UIControlEventTouchUpInside];
        self.syncButton.tag = 0;
        
        self.syncProgressBadge = [CustomBadge customBadgeWithString:@"0"];
        self.syncProgressBadge.hidden = YES;
        
        UIButton *setupButton = nil;
        // Only do the setup button if we have the image defined and we are
        // doing auth for the JSON files.
        if (config.setupBtnImageNamed && ([[SFAppConfig sharedInstance] isAuthRequiredForJSON] || [[SFAppConfig sharedInstance] isDownloadFilteringEnabled])) {
            setupButton = [[UIButton alloc] initWithFrame:CGRectZero];
            if (config.setupBtnImageNamed) {
                [setupButton setImage:[UIImage contentFoundationResourceImageNamed:config.setupBtnImageNamed] forState:UIControlStateNormal];
            }
            [setupButton addTarget:self action:@selector(handleToolbarButton:) forControlEvents:UIControlEventTouchUpInside];
            setupButton.tag = 7;
        }
        
        [self addSubview:webLinkButton];
        [self addSubview:prodFavsButton];
        [self addSubview:searchButton];
        [self addSubview:sketchButton];
        [self addSubview:self.syncButton];
        [self addSubview:self.syncProgressBadge];
        
        HorizontalLayout *westLayout = nil;
        if (setupButton) {
            [self addSubview:setupButton];
            westLayout = [HorizontalLayout margin:@"0"
                             padding:nil
                              valign:@"center"
                              halign:@"left"
                               items:[ViewItem viewItemFor:webLinkButton width:@"44px" height:@"44px"],
             [ViewItem viewItemFor:prodFavsButton width:@"44px" height:@"44px"],
             [ViewItem viewItemFor:sketchButton width:@"44px" height:@"44px"],
             [ViewItem viewItemFor:self.syncButton width:@"44px" height:@"44px"],
             [ViewItem viewItemFor:setupButton width:@"44px" height:@"44px"], nil];
            
        } else {
            westLayout = [HorizontalLayout margin:@"0"
                             padding:nil
                              valign:@"center"
                              halign:@"left"
            items:[ViewItem viewItemFor:webLinkButton width:@"44px" height:@"44px"],
             [ViewItem viewItemFor:prodFavsButton width:@"44px" height:@"44px"],
             [ViewItem viewItemFor:sketchButton width:@"44px" height:@"44px"],
             [ViewItem viewItemFor:self.syncButton width:@"44px" height:@"44px"],nil];
        }
        
        layout = [BorderLayout margin:@"0px"
                              padding:@"0px 6px 0px 6px"
                                north:nil
                                south:nil
                                 east:nil
                                 west:[BorderRegion layout:westLayout]
                               center:[BorderRegion layout:[HorizontalLayout margin:@"0"
                                                                            padding:nil
                                                                             valign:@"center"
                                                                             halign:@"right"
                                                                              items:[ViewItem viewItemFor:searchButton width:@"44px" height:@"44px"], nil]]];

        
    }
    return self;
}

#pragma mark -
#pragma mark Layout and Drawing
- (void) layoutSubviews {
    [super layoutSubviews];
    
    [layout layoutForView:self];
    
    [self resizeBadge];
    
}

#pragma mark -
#pragma mark Button Actions
-(void)handleSyncButton:(id)sender{
    [delegate handleSyncButton:sender];
}

-(void)handleToolbarButton:(id)sender{
    [delegate handleToolbarButton:sender];
}

- (void) updateBadgeText: (NSString *) newBadgeText {
    [syncProgressBadge autoBadgeSizeWithString:newBadgeText];
    
    [self resizeBadge];
}

- (void) resizeBadge {
    // Re-position the badge
    CGRect badgeFrame = self.syncProgressBadge.frame;
    
    CGRect syncButtonFrame = self.syncButton.frame;
    badgeFrame.origin = CGPointMake(syncButtonFrame.origin.x + syncButtonFrame.size.width - 15 , 0);
    self.syncProgressBadge.frame = badgeFrame;
}

- (void) hideBadge {
    self.syncProgressBadge.hidden = YES;
}

- (void) showBadge {
    self.syncProgressBadge.hidden = NO;
    [self bringSubviewToFront:self.syncProgressBadge];
}

- (BOOL) badgeHidden {
    return self.syncProgressBadge.hidden;
}

- (NSString *) badgeText {
    return [self.syncProgressBadge badgeText];
}

@end

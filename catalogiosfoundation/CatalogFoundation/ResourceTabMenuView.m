//
//  ResourceTabMenuView.m
//  CatalogFoundation
//
//  Created by Chris Pflepsen on 8/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

//
//  ContentResourcesMenuView.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/17/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ResourceTabMenuView.h"

#import "ResourceTabMenuConfig.h"
#import "ResourceTabConfig.h"
#import "ResourceTabView.h"

#import "ContentUtils.h"

#import "UIView+ViewLayout.h"

#define LABEL_WIDTH 210.0f
#define LABEL_HEIGHT 34.0f

#define BUTTON_SPACING 5.0f

@interface ResourceTabMenuView()

- (void) setupResourceTabs;
- (void) setupTab:(UIView *)tapView config:(ResourceTabConfig *)tabConfig;

-(void) handleButtonTapped: (id) sender;

-(ResourceTabView *) tabForTag:(NSInteger) tag;

@end

@implementation ResourceTabMenuView
@synthesize delegate;
@synthesize currentlySelectedTab;

@synthesize viewConfig;

#pragma mark -
#pragma mark init/dealloc Methods
- (id)initWithFrame:(CGRect)frame andConfig:(ResourceTabMenuConfig *)menuConfig {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        viewConfig = menuConfig;
        currentlySelectedTab = 0;
        
        // Initialize the dictionary
        resourcesAvailableDict = [NSMutableDictionary dictionaryWithCapacity:0];
        // already retained for us by initWithCapacity
        resourceMenuButtons = [[NSMutableArray alloc] initWithCapacity:0];
        
        //Setup the buttons
        [self setupResourceTabs];
    }
    return self;
}

- (void) dealloc {
    resourceMenuButtons = nil;
    
    resourcesAvailableDict = nil;
    
    
}

#pragma mark -
#pragma mark Accessor Methods

#pragma mark -
#pragma mark Public Methods
- (void) updateMenuSelection {
    
    ResourceTabView *tappedBtn = [self tabForTag:currentlySelectedTab];
    
    [self selectTab:tappedBtn.tag];
    
    if (delegate) {
        NSArray *resourcePathList = (NSArray *) [resourcesAvailableDict objectForKey:[NSString stringWithFormat:@"%li", (long)tappedBtn.tag]];
        [delegate menuItemSelected:tappedBtn resourcesAvailableList:resourcePathList];
    }

}

#pragma mark -
#pragma mark Private Methods
- (void) setupResourceTabs {
    CGFloat cx = 0;
    ResourceTabView *tab = nil;
    
    if (viewConfig && viewConfig.tabConfigList && [viewConfig.tabConfigList count] > 0) {
        int tabCount = 0;
        for (ResourceTabConfig *buttonConfig in viewConfig.tabConfigList) {
            int spacing = 0;
            if (buttonConfig.tabSpacing > 0) {
                spacing = (tabCount > 0) ? buttonConfig.tabSpacing : 0;
            }
            tab = [[ResourceTabView alloc] initWithFrame:CGRectMake(cx + spacing, 0, buttonConfig.tabSize.width, buttonConfig.tabSize.height) config:buttonConfig];
            tab.userInteractionEnabled = YES;
            
            [self setupTab:tab config:buttonConfig];
            [self addSubview:tab];
            
            tab = nil;
            
            cx += (buttonConfig.tabSize.width + spacing);
            tabCount++;
        }
    }
}

- (void) setupTab:(UIView *)tapView config:(ResourceTabConfig *)tabConfig {
    
    if (tabConfig.buttonTag != NO_BUTTON_TAG) {
        tapView.tag = tabConfig.buttonTag;
    } else {
        tapView.tag = [resourceMenuButtons count]; //Before adding to array
    }
    
    [resourceMenuButtons addObject:tapView];
    

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(handleButtonTapped:)];
    tap.numberOfTapsRequired = 1;
    [tapView addGestureRecognizer:tap];

    
    // Detetmine if the button is to be enabled (TODO: does it have resources)
    NSArray *resourcesAvailableList = [[tabConfig contentItem] contentResourceItems];
    
    if (resourcesAvailableList && [resourcesAvailableList count] > 0) {
        
        // Add count to dictionary
        [resourcesAvailableDict setObject:resourcesAvailableList forKey:[NSString stringWithFormat:@"%li", (long)tapView.tag]];
        
    }
    
    if ([[tabConfig contentItem] hasIndustryProducts]) {
        [resourcesAvailableDict setObject:[[tabConfig contentItem] contentIndustryProducts] forKey:[NSString stringWithFormat:@"%li", (long)tapView.tag]];
    }
}

- (void) handleButtonTapped:(id)sender {
    
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    
    
    // Make sure all buttons are unselected
    BOOL allowMenuSelection = YES;
    
    UIView *tappedBtn = (UIView *) tap.view;
    currentlySelectedTab = tappedBtn.tag;
    
    if (delegate && [delegate respondsToSelector:@selector(allowMenuItemSelection:)]) {
        allowMenuSelection = [delegate allowMenuItemSelection:tappedBtn.tag];
    }
    
    if (allowMenuSelection) {
        //tappedBtn.selected = YES;
        
        [self selectTab:tappedBtn.tag];
        
        if (delegate) {
            NSArray *resourcePathList = (NSArray *) [resourcesAvailableDict objectForKey:[NSString stringWithFormat:@"%li", (long)tappedBtn.tag]];
            [delegate menuItemSelected:tappedBtn resourcesAvailableList:resourcePathList];
        }
    }
}

-(void)selectTab:(NSInteger) tag{
    for (ResourceTabView *menuTab in resourceMenuButtons) {
        if (menuTab.tag == tag) {
            [menuTab.backgroundImageView setImage:menuTab.viewConfig.selectedStateImage];
            menuTab.titleLabel.textColor = menuTab.viewConfig.titleSelectedFontColor;
            menuTab.titleLabel.shadowColor = [UIColor clearColor];
            menuTab.titleLabel.shadowOffset = CGSizeMake(0, 0);
        }
        else{
            [menuTab.backgroundImageView setImage:menuTab.viewConfig.normalStateImage];
            menuTab.titleLabel.textColor = menuTab.viewConfig.titleFontColor;
            menuTab.titleLabel.shadowColor = menuTab.viewConfig.titleShadowColor;
            menuTab.titleLabel.shadowOffset = menuTab.viewConfig.titleShadowSize;
        }
    }
}

-(ResourceTabView *)tabForTag:(NSInteger)tag{
    
    ResourceTabView *tabView = nil;
    
    for (ResourceTabView *menuTab in resourceMenuButtons) {
        if (menuTab.tag == tag) {
            tabView = menuTab;
        }
    }
    return tabView;
}

@end


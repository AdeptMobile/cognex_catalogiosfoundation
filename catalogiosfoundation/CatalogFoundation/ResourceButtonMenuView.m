//
//  ContentResourcesMenuView.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/17/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ResourceButtonMenuView.h"

#import "ResourceButtonMenuConfig.h"
#import "ResourceButtonConfig.h"

#import "ContentUtils.h"

#import "UIView+ViewLayout.h"

#define LABEL_WIDTH 210.0f
#define LABEL_HEIGHT 34.0f

#define BUTTON_SPACING 5.0f

@interface ResourceButtonMenuView()
        
- (void) setupResourceButtons;
- (void) setupButton:(UIButton *)btn config: (ResourceButtonConfig *) buttonConfig;

- (void) handleButtonTapped: (id) sender;

@end

@implementation ResourceButtonMenuView
@synthesize delegate;

@synthesize viewConfig;

#pragma mark - 
#pragma mark init/dealloc Methods
- (id)initWithFrame:(CGRect)frame andConfig:(ResourceButtonMenuConfig *)menuConfig {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        viewConfig = menuConfig;
        
        // Initialize the dictionary
        resourcesAvailableDict = [NSMutableDictionary dictionaryWithCapacity:0];
        // already retained for us by initWithCapacity
        resourceMenuButtons = [[NSMutableArray alloc] initWithCapacity:0];
        
        // Setup the Resources Label
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, LABEL_WIDTH, LABEL_HEIGHT)];
        titleLabel.textColor = viewConfig.titleTextColor;
        titleLabel.backgroundColor = viewConfig.titleBackgroundColor;
        titleLabel.font = [UIFont systemFontOfSize:16.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = viewConfig.title;
        
        [self addSubview:titleLabel];
        
        [titleLabel applyBorderStyle:viewConfig.titleBorderColor withBorderWidth:2.0f withShadow:NO];
        
        //Setup the buttons
        [self setupResourceButtons];
    }
    return self;
}

- (void) dealloc {
    resourceMenuButtons = nil;
    
    resourcesAvailableDict = nil;
    
    
}


#pragma mark -
#pragma mark Custom Drawing Code
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark -
#pragma mark Layout Code
- (void) layoutSubviews {
    [super layoutSubviews];
    
    // Your code here
}

#pragma mark -
#pragma mark Accessor Methods

#pragma mark - 
#pragma mark Public Methods
- (void) defaultMenuSelection {
    BOOL doDefaultSelection = YES;
    
    // De-select all first
    for (UIButton *menuBtn in resourceMenuButtons) {
        if (menuBtn.selected) {
            doDefaultSelection = NO;
            break;
        };
    }
    
    // Select the first enabled button
    if (doDefaultSelection) {
        for (UIButton *menuBtn in resourceMenuButtons) {
            if (menuBtn.enabled) {
                menuBtn.selected = YES;
                
                if (delegate) {
                    NSArray *resourcePathList = (NSArray *) [resourcesAvailableDict objectForKey:[NSString stringWithFormat:@"%li", (long)menuBtn.tag]];
                    [delegate menuItemSelected:menuBtn resourcesAvailableList:resourcePathList];
                }
                
                break;
            }
        }
    }
}

- (void) menuSelection:(NSInteger) tag {
    UIButton *selectedBtn = nil;
    
    for (UIButton *menuBtn in resourceMenuButtons) {
        if (menuBtn.tag == tag) {
            selectedBtn = menuBtn;
            break;
        }
    }
    
    // Select the first enabled button
    if (selectedBtn) {
        if (selectedBtn.enabled) {
            for (UIButton *menuBtn in resourceMenuButtons) {
                if (menuBtn.selected) {
                    menuBtn.selected = NO;
                    break;
                }
            }
            
            selectedBtn.selected = YES;
            
            if (delegate) {
                NSArray *resourcePathList = (NSArray *) [resourcesAvailableDict objectForKey:[NSString stringWithFormat:@"%li", (long)selectedBtn.tag]];
                [delegate menuItemSelected:selectedBtn resourcesAvailableList:resourcePathList];
            }
        }
    }
}

#pragma mark -
#pragma mark Private Methods
- (void) setupResourceButtons {
    CGFloat cy = LABEL_HEIGHT + (BUTTON_SPACING * 2.0f);
    UIButton *button = nil;
    
    if (viewConfig && viewConfig.buttonConfigList && [viewConfig.buttonConfigList count] > 0) {
        for (ResourceButtonConfig *buttonConfig in viewConfig.buttonConfigList) {
            button = [[UIButton alloc] initWithFrame:CGRectMake(0, cy, LABEL_WIDTH+ 6.0f, LABEL_HEIGHT)];
            [button setTitle:buttonConfig.buttonTitle forState:UIControlStateNormal];
            
            [self setupButton:button config:buttonConfig];
            [self addSubview:button];
            
            button = nil;
            
            cy += LABEL_HEIGHT + BUTTON_SPACING;
        }
    }
}

- (void) setupButton:(UIButton *)btn config:(ResourceButtonConfig *)buttonConfig {
    
    if (buttonConfig.buttonTag != NO_BUTTON_TAG) {
        btn.tag = buttonConfig.buttonTag;
    } else {
        btn.tag = [resourceMenuButtons count]; //Before adding to array
    }
    
    [resourceMenuButtons addObject:btn];
    
    [btn setBackgroundImage:buttonConfig.normalStateImage forState:UIControlStateNormal];
    [btn setBackgroundImage:buttonConfig.selectedStateImage forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(handleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    btn.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    
    // Detetmine if the button is to be enabled (TODO: does it have resources)
    NSArray *resourcesAvailableList = [[buttonConfig resourceGroup] contentResourceItems];
    
    if (resourcesAvailableList && [resourcesAvailableList count] > 0) {
        [btn setTitleColor:buttonConfig.enableButtonColor forState:UIControlStateNormal];
        
        // Add count to dictionary
        [resourcesAvailableDict setObject:resourcesAvailableList forKey:[NSString stringWithFormat:@"%li", (long)btn.tag]];
        
    } else {   
        btn.enabled = NO;
        [btn setTitleColor:buttonConfig.disableButtonColor forState:UIControlStateNormal];
    }
}

- (void) handleButtonTapped:(id)sender {
    
    // Make sure all buttons are unselected
    BOOL allowMenuSelection = YES;
    
    UIButton *tappedBtn = (UIButton *) sender;
    
    if (delegate && [delegate respondsToSelector:@selector(allowMenuItemSelection:)]) {
        allowMenuSelection = [delegate allowMenuItemSelection:tappedBtn.tag];
    }
    
    if (allowMenuSelection) {
        tappedBtn.selected = YES;
        
        for (UIButton *button in resourceMenuButtons) {
            if (button != tappedBtn) {
                button.selected = NO;
            }
        }
        
        if (delegate) {
            NSArray *resourcePathList = (NSArray *) [resourcesAvailableDict objectForKey:[NSString stringWithFormat:@"%li", (long)tappedBtn.tag]];
            [delegate menuItemSelected:tappedBtn resourcesAvailableList:resourcePathList];
        }
    }
}

@end

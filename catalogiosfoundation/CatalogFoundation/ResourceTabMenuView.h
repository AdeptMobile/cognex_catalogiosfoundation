//
//  ResourceTabMenuView.h
//  CatalogFoundation
//
//  Created by Chris Pflepsen on 8/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResourceTabMenuConfig.h"

@protocol ResourceTabMenuViewDelegate <NSObject>

- (BOOL) allowMenuItemSelection: (NSInteger) menuButtonIndex;
- (void) menuItemSelected: (id) menuButton resourcesAvailableList: (NSArray *) resourcePathList;

@end

@interface ResourceTabMenuView : UIView {
    id <ResourceTabMenuViewDelegate> __weak delegate;
    
    ResourceTabMenuConfig *viewConfig;
    
    NSMutableDictionary *resourcesAvailableDict;

    NSMutableArray *resourceMenuButtons;
}

@property NSInteger currentlySelectedTab;

@property (nonatomic, weak) id <ResourceTabMenuViewDelegate> delegate;
@property (readonly, strong) ResourceTabMenuConfig *viewConfig;

-(id) initWithFrame:(CGRect)frame andConfig: (ResourceTabMenuConfig *) menuConfig;

- (void) updateMenuSelection;
- (void) selectTab:(NSInteger) tag;
@end

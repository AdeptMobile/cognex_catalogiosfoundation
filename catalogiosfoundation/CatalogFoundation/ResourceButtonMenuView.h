//
//  ContentResourcesMenuView.h
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/17/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ResourceButtonMenuConfig;

@protocol ResourceButtonMenuDelegate <NSObject>

- (BOOL) allowMenuItemSelection: (NSInteger) menuButtonIndex;
- (void) menuItemSelected: (id) menuButton resourcesAvailableList: (NSArray *) resourcePathList;

@end

@interface ResourceButtonMenuView : UIView {
    id <ResourceButtonMenuDelegate> __weak delegate;
    
    ResourceButtonMenuConfig *viewConfig;
    
    NSMutableDictionary *resourcesAvailableDict;
    
    UILabel *titleLabel;
    NSMutableArray *resourceMenuButtons;
}

@property (nonatomic, weak) id <ResourceButtonMenuDelegate> delegate;
@property (readonly, strong) ResourceButtonMenuConfig *viewConfig;

-(id) initWithFrame:(CGRect)frame andConfig: (ResourceButtonMenuConfig *) menuConfig;

- (void) defaultMenuSelection;
- (void) menuSelection:(NSInteger) tag;

@end

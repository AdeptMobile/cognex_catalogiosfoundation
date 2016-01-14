//
//  ResourceButtonConfig.h
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/17/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ContentViewBehavior.h"

#define NO_BUTTON_TAG -1

@interface ResourceButtonConfig : NSObject {
    NSInteger buttonTag;
    
    id<ContentViewBehavior> resourceGroup;
    
    NSString *buttonTitle;
    UIImage *normalStateImage;
    UIImage *selectedStateImage;
    
    UIColor *enableButtonColor;
    UIColor *disableButtonColor;
}

@property (nonatomic, assign) NSInteger buttonTag;

@property (nonatomic, strong) id<ContentViewBehavior> resourceGroup;
@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic, strong) UIImage *normalStateImage;
@property (nonatomic, strong) UIImage *selectedStateImage;

@property (nonatomic, strong) UIColor *enableButtonColor;
@property (nonatomic, strong) UIColor *disableButtonColor;

- (id) initWith: (id<ContentViewBehavior>) aResourceGroup;
- (id) initWith: (id<ContentViewBehavior>) aResourceGroup enabledColor: (UIColor *) enabledColor disabledColor: (UIColor *) aDisabledColor;
- (id) initWith: (id<ContentViewBehavior>) aResourceGroup enabledColor: (UIColor *) enabledColor disabledColor: (UIColor *) aDisabledColor 
                    normalStateImage: (UIImage *) normalImg selectedStateImage: (UIImage *) selectedImg;

@end

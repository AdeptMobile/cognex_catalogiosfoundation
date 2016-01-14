//
//  ResourceTabConfig.h
//  CatalogFoundation
//
//  Created by Chris Pflepsen on 8/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ContentViewBehavior.h"

#define NO_BUTTON_TAG -1

@interface ResourceTabConfig : NSObject{

}

@property (nonatomic, assign) NSInteger buttonTag;

@property (nonatomic, strong) id<ContentViewBehavior> contentItem;
@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic, strong) UIImage *normalStateImage;
@property (nonatomic, strong) UIImage *selectedStateImage;

@property (nonatomic, strong) UIColor *enableButtonColor;
@property (nonatomic, strong) UIColor *disableButtonColor;

@property CGSize tabSize;
@property CGFloat tabSpacing;
@property CGSize titleShadowSize;

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleShadowColor;
@property (nonatomic, strong) UIColor *titleFontColor;
@property (nonatomic, strong) UIColor *titleSelectedFontColor;

@property (nonatomic, assign) UIViewContentMode verticalAlignment;
@property (nonatomic, assign) NSTextAlignment horizontalAlignment;

- (id) initWith: (id<ContentViewBehavior>)aContentItem normalStateImage:(UIImage *)normalImg selectedStateImage:(UIImage *)selectedImg titleFont:(UIFont *)font titleShadowColor:(UIColor *)shadowColor tabSize:(CGSize)size tabSpacing:(CGFloat)spacing titleShadowSize:(CGSize)shadowSize titleColor:(UIColor *)titleColor;

@end

//
//  ProductPhotoViewConfig.h
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/6/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductPhotoViewConfig : NSObject {
    UIColor *borderColor;
    UIColor *tabReturnTextColor;
    UIColor *tabProductTextColor;
    
    BOOL doShowTabs;
}

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *tabReturnTextColor;
@property (nonatomic, strong) UIColor *tabProductTextColor;
@property (nonatomic, assign, getter=isDoShowTabs) BOOL doShowTabs;

@end

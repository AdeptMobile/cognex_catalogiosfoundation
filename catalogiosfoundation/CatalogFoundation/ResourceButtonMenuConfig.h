//
//  ResourceButtonMenuConfig.h
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/17/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResourceButtonMenuConfig : NSObject {
    NSString *title;
    UIColor *titleTextColor;
    UIColor *titleBackgroundColor;
    UIColor *titleBorderColor;
    BOOL titleApplyBorder;
    
    NSMutableArray *buttonConfigList;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *titleTextColor;
@property (nonatomic, strong) UIColor *titleBackgroundColor;
@property (nonatomic, strong) UIColor *titleBorderColor;

@property (nonatomic, strong) NSMutableArray *buttonConfigList;

@end

//
//  SFChangePasswordConfig.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/16/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFChangePasswordConfig : NSObject

@property (nonatomic, assign) BOOL landscapeOnly;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, copy) NSString *bgImageNamed;
@property (nonatomic, copy) NSString *labelFontName;
@property (nonatomic, strong) UIColor *labelTextColor;
@property (nonatomic, strong) UIColor *fieldBgColor;
@property (nonatomic, strong) UIColor *fieldTextColor;
@property (nonatomic, copy) NSString *fieldFontName;
@property (nonatomic, copy) NSString *doneButtonImageNamed;
@property (nonatomic, copy) NSString *cancelButtonImageNamed;

@end

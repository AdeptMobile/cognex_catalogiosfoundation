//
//  SFRequestLoginConfig.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/6/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFRequestLoginConfig : NSObject

@property (nonatomic, assign) BOOL landscapeOnly;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, copy) NSString *bgImageNamed;
@property (nonatomic, copy) NSString *textFont;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *selectViewBgColor;
@property (nonatomic, copy) NSString *doneButtonImageNamed;
@property (nonatomic, copy) NSString *cancelButtonImageNamed;
@property (nonatomic, strong) UIColor *pickerViewBgColor;

@property (nonatomic, strong) NSArray *regions;
@property (nonatomic, copy) NSString *requestSubjectFormatString;
@property (nonatomic, strong) NSArray *requestAddresses;
@property (nonatomic, strong) NSArray *requestBodies;

@end

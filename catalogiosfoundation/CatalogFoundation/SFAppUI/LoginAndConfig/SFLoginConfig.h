//
//  SFLoginConfig.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/5/14.
//  Copyright (c) 2014 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFLoginConfig : NSObject

@property (nonatomic, assign) BOOL landscapeOnly;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, copy) NSString *bgImageNamed;
@property (nonatomic, strong) UIColor *textFieldBgColor;
@property (nonatomic, copy) NSString *textFieldFont;
@property (nonatomic, strong) NSNumber *textFieldFontSize;
@property (nonatomic, strong) UIColor *textFieldTextColor;
@property (nonatomic, strong) UIColor *textFieldRequestTextColor;
@property (nonatomic, copy) NSString *loginButtonBgImage;
@property (nonatomic, copy) NSString *requestLoginButtonImage;
@property (nonatomic, copy) NSString *helpEmailAddress;
@property (nonatomic, copy) NSString *helpEmailSubject;
@property (nonatomic, copy) NSString *helpEmailBody;
@property (nonatomic, copy) NSString *helpAlertText;
@property (nonatomic, strong) UIColor *helpTextColor;

@end

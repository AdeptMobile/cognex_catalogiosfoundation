//
//  CompanyInfoHtmlViewConfig.h
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/4/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompanyInfoHtmlViewConfig : NSObject {
    NSString *logoLeft;
    NSString *logoRight;
    
    NSString *leftLogoLink;
    NSString *rightLogoLink;
    
    UIColor *bgColor;
    UIColor *textColor;
}

@property (nonatomic, strong) NSString *logoLeft;
@property (nonatomic, strong) NSString *logoRight;
@property (nonatomic, strong) NSString *leftLogoLink;
@property (nonatomic, strong) NSString *rightLogoLink;

@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *textColor;

@end

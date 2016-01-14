//
//  ContentInfoToolbarConfig.h
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/4/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContentInfoToolbarConfig : NSObject {

}

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *homeBtnImageNamed;
@property (nonatomic, copy) NSString *backBtnImageNamed;
@property (nonatomic, copy) NSString *webBtnImageNamed;
@property (nonatomic, copy) NSString *bookmarkBtnImageNamed;
@property (nonatomic, copy) NSString *searchBtnImageNamed;
@property (nonatomic, copy) NSString *sketchBtnImageNamed;
@property (nonatomic, copy) NSString *refreshBtnImageNamed;
@property (nonatomic, copy) NSString *setupBtnImageNamed;
@property (nonatomic, copy) NSString *centerBgImageNamed;
@property (nonatomic, copy) NSString *leftInsetBgImageNamed;
@property (nonatomic, copy) NSString *rightInsetBgImageNamed;

@property (nonatomic, copy) NSString *webBtnLink;

@end

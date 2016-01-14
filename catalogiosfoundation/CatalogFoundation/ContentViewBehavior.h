//
//  ContentViewBehavior.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 3/21/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContentViewBehavior <NSObject>
- (NSString *) contentId;
- (NSString *) contentThumbNail;
- (NSString *) contentTitle;
- (NSArray *) contentImages;
- (NSArray *) contentTags;
- (NSString *) contentFilePath;
- (NSString *) contentType;
- (NSNumber *) contentStartPage;
- (NSURL *) contentLink;
- (NSString *) contentInfoText;

- (NSArray *) contentCategories;
- (NSArray *) contentProducts;
- (NSArray *) contentResources;
- (NSArray *) contentResourceItems;
- (NSArray *) contentIndustries;
- (NSArray *) contentIndustryProducts;
- (NSArray *) contentGalleries;

- (BOOL) hasImages;
- (BOOL) hasTags;
- (BOOL) hasCategories;
- (BOOL) hasProducts;
- (BOOL) hasIndustries;
- (BOOL) hasIndustryProducts;
- (BOOL) hasResources;
- (BOOL) hasResourceItems;
- (BOOL) hasGalleries;

@end

//
//  ContentView.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 3/27/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentViewBehavior.h"

@interface ContentView : NSObject<ContentViewBehavior> {
    NSString *cid;
    NSString *thumbNail;
    NSString *title;
    NSArray *images;
    NSArray *tags;
    NSString *contentPath;
    NSString *type;
    NSNumber *startPage;
    NSString *remotePath;
    NSString *infoText;
    NSArray *categories;
    NSArray *products;
    NSArray *industries;
    NSArray *industryProducts;
    NSArray *resources;
    NSArray *resourceItems;
    NSArray *galleries;
}

@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *thumbNail;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, copy) NSString *contentPath;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSNumber *startPage;
@property (nonatomic, copy) NSString *remotePath;
@property (nonatomic, copy) NSString *infoText;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSArray *industries;
@property (nonatomic, strong) NSArray *industryProducts;
@property (nonatomic, strong) NSArray *resources;
@property (nonatomic, strong) NSArray *resourceItems;
@property (nonatomic, strong) NSArray *galleries;

@end

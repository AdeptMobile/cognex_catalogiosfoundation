//
//  NSDictionary+ContentViewBehavior.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/1/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentViewBehavior.h"

@interface NSDictionary (ContentViewBehavior)

+ (NSDictionary *) dictionaryFromContentViewBehavior:(id<ContentViewBehavior>)contentBehaviorViewObject;

@end

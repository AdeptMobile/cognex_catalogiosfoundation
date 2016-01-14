//
//  NSDictionary+ContentViewBehavior.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 6/1/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "NSDictionary+ContentViewBehavior.h"

@implementation NSDictionary (ContentViewBehavior)

+ (NSDictionary *) dictionaryFromContentViewBehavior:(id<ContentViewBehavior>)contentBehaviorViewObject {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[contentBehaviorViewObject contentLink] forKey:@"contentLink"];
    [dict setValue:[contentBehaviorViewObject contentFilePath] forKey:@"contentFilePath"];
    [dict setValue:[contentBehaviorViewObject contentStartPage] forKey:@"contentStartPage"];
    [dict setValue:[contentBehaviorViewObject contentTitle] forKey:@"contentTitle"];
    [dict setValue:[contentBehaviorViewObject contentId] forKey:@"contentId"];
    [dict setValue:[contentBehaviorViewObject contentType] forKey:@"contentType"];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

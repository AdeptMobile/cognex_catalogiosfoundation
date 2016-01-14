//
//  NSBundle+CatalogFoundationResource.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/10/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (CatalogFoundationResource)

+ (NSBundle *) contentFoundationResourceBundle;
+ (NSString *) contentFoundationResourceBundlePathForResource:(NSString *)resourceName;

@end

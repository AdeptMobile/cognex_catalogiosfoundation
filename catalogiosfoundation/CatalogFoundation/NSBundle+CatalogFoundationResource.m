//
//  NSBundle+CatalogFoundationResource.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/10/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "NSBundle+CatalogFoundationResource.h"

#define DEFAULT_PREFIX @"sf-default"

@implementation NSBundle (CatalogFoundationResource)

+ (NSBundle *) contentFoundationResourceBundle {
    static dispatch_once_t onceToken;
    static NSBundle *cfResourceBundle = nil;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CatalogFoundationResources" ofType:@"bundle"];
        
        if (bundlePath) {
            cfResourceBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"CatalogFoundationResources" withExtension:@"bundle"]];
            NSLog(@"bundle resource path: %@", [cfResourceBundle resourcePath]);
        }
    });
    return cfResourceBundle;
}

+ (NSString *) contentFoundationResourceBundlePathForResource:(NSString *)resourceName {
    NSBundle *contentFoundationBundle = [NSBundle contentFoundationResourceBundle];
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    // Find resource logic:
    //  1.  Look in main bundle by resourceName
    //  2.  If contentFoundation bundle exists, look by resourceName then by sf-default-resourceName
    //  3.  Look for resource with prefix sf-default-resourceName in main bundle
    NSString* path = [[mainBundle bundlePath] stringByAppendingPathComponent:resourceName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }
    
    if (contentFoundationBundle) {
        path = [[contentFoundationBundle bundlePath] stringByAppendingPathComponent:resourceName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            path = [[contentFoundationBundle bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", DEFAULT_PREFIX, resourceName]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                return path;
            }

        } else {
            return path;
        }
    }
    
    // By default
    path = [[mainBundle bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", DEFAULT_PREFIX, resourceName]];
    return path;
}

@end

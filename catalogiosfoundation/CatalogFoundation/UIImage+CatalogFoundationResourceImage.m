//
//  UIImage+CatalogFoundationResourceImage.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/10/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "UIImage+CatalogFoundationResourceImage.h"
#import "NSBundle+CatalogFoundationResource.h"

@implementation UIImage (CatalogFoundationResourceImage)

+ (UIImage *) contentFoundationResourceImageNamed:(NSString *)name {
    NSString *path = [NSBundle contentFoundationResourceBundlePathForResource:name];
    
    UIImage *bundleImage = [UIImage imageWithContentsOfFile:path];
    return bundleImage;
}
@end

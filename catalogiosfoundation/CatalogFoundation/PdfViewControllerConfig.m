//
//  PdfViewControllerConfig.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/13/13.
//  Copyright (c) 2013 Object Partners Inc. All rights reserved.
//

#import "PdfViewControllerConfig.h"

@implementation PdfViewControllerConfig

@synthesize autoFadeToolbar = _autoFadeToolbar;

-(id)init {
    
    if (self = [super init]) {
        self.autoFadeToolbar = NO;
    }
    return self;
}

@end

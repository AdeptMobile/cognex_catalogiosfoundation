//
//  ContentLookup.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 3/26/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ContentLookup.h"

@interface ContentLookup ()

@end

@implementation ContentLookup

@synthesize impl;

+ (ContentLookup *) sharedInstance {
    static ContentLookup *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


@end

//
//  ContentView.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 3/27/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ContentView.h"

#define RELEASE_AND_NIL(X)  X = nil;

@implementation ContentView

@synthesize cid;
@synthesize thumbNail;
@synthesize title;
@synthesize images;
@synthesize tags;
@synthesize contentPath;
@synthesize type;
@synthesize startPage;
@synthesize remotePath;
@synthesize infoText;
@synthesize categories;
@synthesize products;
@synthesize industries;
@synthesize industryProducts;
@synthesize resources;
@synthesize resourceItems;
@synthesize galleries;

- (void) dealloc {
    RELEASE_AND_NIL(cid);
    RELEASE_AND_NIL(thumbNail);
    RELEASE_AND_NIL(title);
    RELEASE_AND_NIL(images);
    RELEASE_AND_NIL(tags);
    RELEASE_AND_NIL(contentPath);
    RELEASE_AND_NIL(type);
    RELEASE_AND_NIL(startPage);
    RELEASE_AND_NIL(remotePath);
    RELEASE_AND_NIL(infoText);
    RELEASE_AND_NIL(categories);
    RELEASE_AND_NIL(products);
    RELEASE_AND_NIL(industries);
    RELEASE_AND_NIL(industryProducts);
    RELEASE_AND_NIL(resources);
    RELEASE_AND_NIL(resourceItems);
    RELEASE_AND_NIL(galleries);
}

- (NSString *)contentId {
    return [self cid];
}

- (NSString *)contentThumbNail {
    return [self thumbNail];
}

- (NSString *)contentTitle {
    return [self title];
}

- (NSArray *)contentImages {
    return [self images];
}

- (NSArray *)contentTags {
    return [self tags];
}

- (NSString *)contentFilePath {
    return [self contentPath];
}

- (NSString *)contentType {
    return [self type];
}

- (NSNumber *)contentStartPage {
    // Really only valid for resource items
    return [self startPage];
}

- (NSURL *)contentLink {
    if ([self remotePath]) {
        return [NSURL URLWithString:[self remotePath]];
    }
    return nil;
}

- (NSString *)contentInfoText {
    return [self infoText];
}

- (NSArray *)contentCategories {
    return [self categories];
}

- (NSArray *)contentProducts {
    return [self products];
}

- (NSArray *)contentIndustries {
    return [self industries];
}

- (NSArray *)contentIndustryProducts {
    return [self industryProducts];
}

- (NSArray *)contentResources {
    return [self resources];
}

- (NSArray *)contentResourceItems {
    return [self resourceItems];
}

- (NSArray *)contentGalleries {
    return [self galleries];
}

- (BOOL) hasTags {
    if ([self tags] && [[self tags] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) hasImages {
    if ([self images] && [[self images] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) hasCategories {
    if ([self categories] && [[self categories] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) hasProducts {
    if ([self products] && [[self products] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) hasIndustries {
    if ([self industries] && [[self industries] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) hasIndustryProducts {
    if ([self industryProducts] && [[self industryProducts] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) hasResources {
    if ([self resources] && [[self resources] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) hasResourceItems {
    if ([self resourceItems] && [[self resourceItems] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) hasGalleries {
    if ([self galleries] && [[self galleries] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

@end

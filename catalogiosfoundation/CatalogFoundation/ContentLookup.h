//
//  ContentLookup.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 3/26/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentLookupBase.h"

@interface ContentLookup : NSObject {
    ContentLookupBase<ContentLookupBehavior>* impl;
}

@property (nonatomic, strong) ContentLookupBase<ContentLookupBehavior>* impl;

+ (ContentLookup *) sharedInstance;

@end

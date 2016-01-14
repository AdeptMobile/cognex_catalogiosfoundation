//
//  Bookmark.h
//  ToloApp
//
//  Created by Torey Lomenda on 7/26/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Bookmark : NSObject {
    NSString *name;
    NSNumber *pageNumber;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *pageNumber;

- (NSString *) toString;
@end

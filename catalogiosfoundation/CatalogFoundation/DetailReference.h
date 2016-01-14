//
//  ProductReference.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/2/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailReference : NSObject {
    NSString *name;
    NSString *detailId;
    NSString *detailType;
    UIImage *detailThumbnail;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *detailId;
@property (nonatomic, strong) NSString *detailType;
@property (nonatomic, strong) UIImage *detailThumbnail;

- (NSString *) toString;

@end

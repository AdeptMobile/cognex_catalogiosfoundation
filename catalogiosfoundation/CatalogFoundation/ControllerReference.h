//
//  ControllerReference.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ControllerReference : NSObject {
    NSString *name;
    NSInteger controllerIndex;
    NSString *controllerThumbnailPath;
    UIImage *controllerThumbnail;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger controllerIndex;
@property (nonatomic, strong) NSString *controllerThumbnailPath;
@property (nonatomic, strong) UIImage *controllerThumbnail;

- (NSString *) toString;

@end

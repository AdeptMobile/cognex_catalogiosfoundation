//
//  DetailSearchViewControllerDelegate.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/11/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentViewBehavior.h"

@class DetailSearchViewController;

@protocol DetailSearchViewControllerDelegate <NSObject>

@optional
- (void) searchViewController:(DetailSearchViewController *)psvc didRequestIndustry:(NSString *)industryId;
- (void) searchViewController:(DetailSearchViewController *)psvc didRequestGallery:(NSString *)galleryId;

@required
- (void) searchViewController:(DetailSearchViewController *)psvc didRequestProduct:(NSString *)productId;

@end

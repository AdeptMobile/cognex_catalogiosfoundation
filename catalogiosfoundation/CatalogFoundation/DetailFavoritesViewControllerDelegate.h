//
//  DetailFavoritesViewControllerDelegate.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/2/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentViewBehavior.h"

@class DetailFavoritesViewController;

@protocol DetailFavoritesViewControllerDelegate <NSObject>

@optional
- (id<ContentViewBehavior>)detailForFavorites;
- (void) favoritesViewController:(DetailFavoritesViewController *)pfvc didRequestIndustry:(NSString *)industryId;
- (void) favoritesViewController:(DetailFavoritesViewController *)pfvc didRequestGallery:(NSString *)galleryId;

@required
- (void) favoritesViewController:(DetailFavoritesViewController *)pfvc didRequestProduct:(NSString *)productId;
- (BOOL) canAddFavorite;
@end

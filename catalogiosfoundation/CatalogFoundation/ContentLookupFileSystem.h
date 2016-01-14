//
//  ContentLookupFileSystem.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 3/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ContentLookupBase.h"
#import "ContentViewBehavior.h"

@interface ContentLookupFileSystem : ContentLookupBase<ContentLookupBehavior> {

    NSDictionary *resourcePreviewLabelProperties;
    NSDictionary *resourcePreviewLinksProperties;
    
}

- (void) setup;
- (void) refresh;
- (NSArray *) mainCategoryPaths;
- (NSArray *) mainInfoPanels;
- (NSArray *) mainSpinnerPanels;
- (id<ContentViewBehavior>) mainCategoryPath:(NSString *)categoryName;

- (id<ContentViewBehavior>) lookupProduct:(NSString *)productId;
- (id<ContentViewBehavior>) mainCategoryForProduct:(NSString *)productId;
- (NSArray *) searchProducts:(NSString *)searchString;

- (id<ContentViewBehavior>) lookupIndustry:(NSString *)industryId;
- (id<ContentViewBehavior>) mainCategoryForIndustry:(NSString *)industryId;
- (NSArray *) searchIndustries:(NSString *)searchString;

- (id<ContentViewBehavior>) lookupGallery:(NSString *)galleryId;
- (id<ContentViewBehavior>) mainCategoryForGallery:(NSString *)galleryId;
- (NSArray *) searchGalleries:(NSString *)searchString;

- (id<ContentViewBehavior>) topLevelCatalog;
- (NSArray *) searchProductsAndIndustriesAndGalleries:(NSString *)searchString;

@end

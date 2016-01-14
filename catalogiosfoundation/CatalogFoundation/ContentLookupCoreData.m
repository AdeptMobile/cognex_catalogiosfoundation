//
//  ContentLookupCoreData.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 3/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ContentLookupCoreData.h"

#import "SFAppConfig.h"

#import "CJSONDeserializer.h"
#import "Catalog.h"
#import "SFCategory.h"
#import "Product.h"
#import "Industry.h"
#import "Gallery.h"
#import "DataManager.h"

#import "NSArray+Helpers.h"

#define CONTENT_STRUCTURE_FILENAME @"content-structure.json"

@interface ContentLookupCoreData()

- (NSString *) contentStructureJsonFromContentFolder;
- (NSString *) fileContentsFromContentFolder: (NSString *)fileName;
- (void) readContentStructureJson;
- (Product *) productFromId: (NSString *)productId;

@end

@implementation ContentLookupCoreData

- (void) setup {
    [self readContentStructureJson];
}

- (void) refresh {
    // Reset the Core Data store.
    [[DataManager sharedInstance] reset];
    [self readContentStructureJson];
}

- (id<ContentViewBehavior>) topLevelCatalog {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[Catalog entityInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]]];
    NSError *error;
    NSArray *fetchResults = [[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (fetchResults && [fetchResults count] > 0) {
        Catalog *catalog = [[[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error] objectAtIndex:0];
        return catalog;
    }
    
    return nil;
}

- (NSArray *) mainCategoryPaths {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[Catalog entityInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]]];
    NSError *error;
    NSArray *fetchResults = [[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (fetchResults && [fetchResults count] > 0) {
        Catalog *catalog = [[[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error] objectAtIndex:0];
        NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortNameDescriptor, nil];
        return [catalog.categories sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    return nil;
}

- (NSArray *) mainInfoPanels {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[Catalog entityInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]]];
    NSError *error;
    NSArray *fetchResults = [[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (fetchResults && [fetchResults count] > 0) {
        Catalog *catalog = [[[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error] objectAtIndex:0];
        NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortNameDescriptor, nil];
        return [catalog.infoPanels sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    return nil;
}

- (NSArray *) mainSpinnerPanels {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[Catalog entityInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]]];
    NSError *error;
    NSArray *fetchResults = [[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (fetchResults && [fetchResults count] > 0) {
        Catalog *catalog = [[[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error] objectAtIndex:0];
        NSMutableSet *spinners = [NSMutableSet setWithSet:catalog.categories];
        [spinners addObjectsFromArray:[catalog.infoPanels allObjects]];
        NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortNameDescriptor, nil];
        return [spinners sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    return nil;
}

- (id<ContentViewBehavior>) mainCategoryPath:(NSString *)categoryName {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[SFCategory entityInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title == %@", categoryName]];
    NSError *error;
    SFCategory *category = [[[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error] objectAtIndex:0];
    if (category) {
        return category;
    } else {
        return nil;
    }
}

#pragma mark - Private Methods
- (NSString *) contentStructureJsonFromContentFolder {
    return [self fileContentsFromContentFolder:CONTENT_STRUCTURE_FILENAME];
    
}

- (NSString *) fileContentsFromContentFolder: (NSString *)fileName {
    
    
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    NSString *baseContentPath = [[SFAppConfig sharedInstance] getLocalContentDocPath];
    NSString *contentMetaDataPath = [[cacheDirectory stringByAppendingPathComponent:baseContentPath] stringByAppendingPathComponent:fileName];
    
    NSString *contents = [NSString stringWithContentsOfFile:contentMetaDataPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"%@", [error description]);
    }
    return contents;
}

- (void) readContentStructureJson {
    NSError *jsonError = nil;
    NSString *jsonMetaData = [self contentStructureJsonFromContentFolder];
    
    // Get the content structure
    if (jsonMetaData) {
        NSDictionary *jsonData = (NSDictionary *) [[CJSONDeserializer deserializer] 
                                                   deserializeAsDictionary:[jsonMetaData dataUsingEncoding:NSUTF8StringEncoding] error:&jsonError];
        NSDictionary *catalogJson = (NSDictionary *)[jsonData objectForKey:@"catalog"];
        NSArray *mainCategories = (NSArray *)[catalogJson objectForKey:@"categories"];
        //NSLog(@"catalog dictionary: %@", [catalogJson debugDescription]);
        NSLog(@"I have %lu main categories", (unsigned long)[mainCategories count]);
        
        
        Catalog *catalog = [Catalog catalogWithJsonData:catalogJson];
        NSLog(@"catalog title: %@", catalog.title);
        NSLog(@"catalog object has %lu main categories", (unsigned long)[catalog.categories count]);
        for (SFCategory *category in catalog.categories) {
            NSLog(@"Category title: %@", category.title);
        }
        
        //NSLog(@"Some place to put a breakpoint....");
    } 
}

- (id<ContentViewBehavior>) mainCategoryForProduct:(NSString *)productId {
    Product *product = [self productFromId:productId];
    if (product) {
        SFCategory *cat = product.category;
        while (cat.parentCategory != nil) {
            cat = cat.parentCategory;
        }
        return cat;
    } else {
        return nil;
    }
}

- (id<ContentViewBehavior>) mainCategoryForIndustry:(NSString *)industryId {
    Industry *industry = [self industryFromId:industryId];
    if (industry) {
        SFCategory *cat = industry.category;
        while (cat.parentCategory != nil) {
            cat = cat.parentCategory;
        }
        return cat;
    } else {
        return nil;
    }
}

- (id<ContentViewBehavior>) mainCategoryForGallery:(NSString *)galleryId {
    Gallery *gallery = [self galleryFromId:galleryId];
    if (gallery) {
        SFCategory *cat = gallery.category;
        while (cat.parentCategory != nil) {
            cat = cat.parentCategory;
        }
        return cat;
    } else {
        return nil;
    }
}

- (id<ContentViewBehavior>) lookupProduct:(NSString *)productId {
    return [self productFromId:productId];
}

- (Product *) productFromId:(NSString *)productId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[Product entityInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"productId == %@", productId]];
    NSError *error;
    NSArray *resultsList = [[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if ([NSArray isNotEmpty:resultsList]) {
        Product *product = [resultsList objectAtIndex:0];
        
        if (product) {
            return product;
        }
    }
    
    return nil;
}

- (NSArray *) searchProducts:(NSString *)searchString {
    NSArray *results = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setEntity:[Product entityInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]]];
    NSPredicate *titleSearch = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchString];
    NSPredicate *tagSearch = [NSPredicate predicateWithFormat:@"ANY tags.tag contains[cd] %@", searchString];
    NSArray *predicates = [NSArray arrayWithObjects:titleSearch, tagSearch, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    [fetchRequest setPredicate:compoundPredicate];
    NSError *error;
    results = [[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Search returned %lu products", (results == nil) ? 0 : [results count]);
    return results;
}

- (id<ContentViewBehavior>) lookupIndustry:(NSString *)industryId {
    return [self industryFromId:industryId];
}

- (Industry *) industryFromId:(NSString *)industryId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[Industry entityInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"industryId == %@", industryId]];
    NSError *error;
    NSArray *resultsList = [[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if ([NSArray isNotEmpty:resultsList]) {
        Industry *industry = [resultsList objectAtIndex:0];
        
        if (industry) {
            return industry;
        }
    }
    
    return nil;
}

- (NSArray *) searchIndustries:(NSString *)searchString {
    NSArray *results = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setEntity:[Industry entityInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]]];
    NSPredicate *titleSearch = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchString];
    NSPredicate *tagSearch = [NSPredicate predicateWithFormat:@"ANY tags.tag contains[cd] %@", searchString];
    NSArray *predicates = [NSArray arrayWithObjects:titleSearch, tagSearch, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    [fetchRequest setPredicate:compoundPredicate];
    NSError *error;
    results = [[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Search returned %lu industries", (results == nil) ? 0 : [results count]);
    return results;
}

- (id<ContentViewBehavior>) lookupGallery:(NSString *)galleryId {
    return [self galleryFromId:galleryId];
}

- (Gallery *) galleryFromId:(NSString *)galleryId {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[Gallery entityInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"galleryId == %@", galleryId]];
    NSError *error;
    NSArray *resultsList = [[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if ([NSArray isNotEmpty:resultsList]) {
        Gallery *gallery = [resultsList objectAtIndex:0];
        
        if (gallery) {
            return gallery;
        }
    }
    
    return nil;
}

- (NSArray *) searchGalleries:(NSString *)searchString {
    NSArray *results = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setEntity:[Gallery entityInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]]];
    NSPredicate *titleSearch = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchString];
    NSPredicate *tagSearch = [NSPredicate predicateWithFormat:@"ANY tags.tag contains[cd] %@", searchString];
    NSArray *predicates = [NSArray arrayWithObjects:titleSearch, tagSearch, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    [fetchRequest setPredicate:compoundPredicate];
    NSError *error;
    results = [[[DataManager sharedInstance] mainObjectContext] executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Search returned %lu industries", (results == nil) ? 0 : [results count]);
    return results;
}

- (NSArray *) searchProductsAndIndustriesAndGalleries:(NSString *)searchString {
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:0];
    [results addObjectsFromArray:[self searchProducts:searchString]];
    [results addObjectsFromArray:[self searchIndustries:searchString]];
    [results addObjectsFromArray:[self searchGalleries:searchString]];
    return [NSArray arrayWithArray:results];
}

@end

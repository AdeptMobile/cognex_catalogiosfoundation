#import "SFCategory.h"
#import "Image.h"
#import "Tag.h"
#import "Product.h"
#import "Industry.h"
#import "Gallery.h"
#import "DataManager.h"
#import "ContentUtils.h"

#import "NSFileManager+Utilities.h"

@implementation SFCategory

+ (id)categoryWithJsonData:(NSDictionary *)jsonData {
    if (jsonData) {
        SFCategory *category = [SFCategory insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
        category.categoryId = (NSString *)[jsonData objectForKey:@"categoryId"];
        category.title = (NSString *)[jsonData objectForKey:@"title"];
        category.thumbNail = (NSString *) [jsonData objectForKey:@"thumbNail"];
        
        NSNumber *jsonDisplayOrder = (NSNumber *)[jsonData objectForKey:@"displayOrder"];
        if (jsonDisplayOrder == nil) {
            category.displayOrder = [NSDecimalNumber zero];
        } else {
            category.displayOrder = [NSDecimalNumber decimalNumberWithDecimal:[jsonDisplayOrder decimalValue]];
        }
        
        NSArray *images = (NSArray *) [jsonData objectForKey:@"images"];
        if (images != nil && [images count] > 0) {
            for (NSString *imagePath in images) {
                Image *image = [Image insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
                image.imagePath = imagePath;
                [category addImagesObject:image];
            }
        }
        NSArray *tags = (NSArray *) [jsonData objectForKey:@"tags"];
        if (tags != nil && [tags count] > 0) {
            for (NSString *tagValue in tags) {
                Tag *tag = [Tag insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
                tag.tag = tagValue;
                [category addTagsObject:tag];
            }
        }
        NSArray *categories = (NSArray *) [jsonData objectForKey:@"categories"];
        if (categories != nil && [categories count] > 0) {
            for (NSDictionary *categoryJson in categories) {
                SFCategory *subcategory = [SFCategory categoryWithJsonData:categoryJson];
                [category addCategoriesObject:subcategory];
            }
        }
        NSArray *products = (NSArray *) [jsonData objectForKey:@"products"];
        if (products != nil && [products count] > 0) {
            for (NSDictionary *productJson in products) {
                Product *product = [Product productWithJsonData:productJson];
                [category addProductsObject:product];
            }
        }
        NSArray *industries = (NSArray *) [jsonData objectForKey:@"industries"];
        if (industries != nil && [industries count] > 0) {
            for (NSDictionary *industryJson in industries) {
                Industry *industry = [Industry industryWithJsonData:industryJson];
                [category addIndustriesObject:industry];
            }
        }
        NSArray *galleries = (NSArray *) [jsonData objectForKey:@"galleries"];
        if (galleries != nil && [galleries count] > 0) {
            for (NSDictionary *galleryJson in galleries) {
                Gallery *gallery = [Gallery galleryWithJsonData:galleryJson];
                [category addGalleriesObject:gallery];
            }
        }
        return category;
    } else {
        return nil;
    }
}

- (NSString *)contentId {
    return [self categoryId];
}

- (NSString *)contentThumbNail {
    if ([self thumbNail]) {
        return [NSCacheFolder() stringByAppendingPathComponent:[self thumbNail]];
    } else {
        return nil;
    }
}

- (NSString *)contentTitle {
    return self.title; // Moved to Core Data.  This will be deprecated (used for file system support)[ContentUtils labelForPath:[self title]];
}

- (NSArray *)contentImages {
    if ([self images]) {
        NSString *documentsPath = NSCacheFolder();
        NSMutableArray *imageStrs = [NSMutableArray arrayWithCapacity:[[self images] count]];
        for (Image *i in [self images]) {
            NSLog(@"Found image path: %@", [i imagePath]);
            [imageStrs addObject:[documentsPath stringByAppendingPathComponent:[i imagePath]]];
        }
        return [NSArray arrayWithArray:imageStrs];
    } else {
        return nil;
    }
}

- (NSArray *)contentTags {
    if ([self tags]) {
        NSMutableArray *tagStrs = [NSMutableArray arrayWithCapacity:[[self tags] count]];
        for (Tag *t in [self tags]) {
            [tagStrs addObject:[t tag]];
        }
        return [NSArray arrayWithArray:tagStrs];
    } else {
        return nil;
    }
}

- (NSString *)contentFilePath {
    // Core data category has no path in the filesystem
    return nil;
}

- (NSString *)contentType {
    return CONTENT_TYPE_CATEGORY;
}

- (NSNumber *)contentStartPage {
    // Really only valid for resource items
    return nil;
}

- (NSURL *)contentLink {
    // categories are on the device
    return nil;
}

- (NSString *)contentInfoText {
    return nil;
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

- (NSArray *)contentCategories {
    if ([self hasCategories]) {
        NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortNameDescriptor, nil];
        return [[self categories] sortedArrayUsingDescriptors:sortDescriptors];
    } else {
        return nil;
    }
}

- (NSArray *)contentProducts {
    if ([self hasProducts]) {
        NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortNameDescriptor, nil];
        return [[self products] sortedArrayUsingDescriptors:sortDescriptors];
    } else {
        return nil;
    }
}

- (NSArray *)contentIndustries {
    if ([self hasIndustries]) {
        NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortNameDescriptor, nil];
        return [[self industries] sortedArrayUsingDescriptors:sortDescriptors];
    } else {
        return nil;
    }
}

- (NSArray *)contentIndustryProducts {
    return nil;
}

- (NSArray *)contentResources {
    return nil;
}

- (NSArray *)contentResourceItems {
    return nil;
}

- (NSArray *)contentGalleries {
    if ([self hasGalleries]) {
        NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortNameDescriptor, nil];
        return [[self galleries] sortedArrayUsingDescriptors:sortDescriptors];
    } else {
        return nil;
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
    return NO;
}

- (BOOL) hasResources {
    return NO;
}

- (BOOL) hasResourceItems {
    return NO;
}

- (BOOL) hasGalleries {
    if ([self galleries] && [[self galleries] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

@end

#import "Gallery.h"
#import "Tag.h"
#import "ResourceItem.h"
#import "DataManager.h"
#import "ContentUtils.h"

#import "NSFileManager+Utilities.h"

@implementation Gallery

+ (Gallery *)galleryWithJsonData:(NSDictionary *)jsonData {
    if (jsonData) {
        Gallery *gallery = [Gallery insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
        gallery.galleryId = (NSString *) [jsonData objectForKey:@"galleryId"];
        gallery.title = (NSString *) [jsonData objectForKey:@"title"];
        gallery.thumbNail = (NSString *) [jsonData objectForKey:@"thumbNail"];
        gallery.infoText = (NSString *)[jsonData objectForKey:@"infoText"];
        
        NSNumber *jsonDisplayOrder = (NSNumber *)[jsonData objectForKey:@"displayOrder"];
        if (jsonDisplayOrder == nil) {
            gallery.displayOrder = [NSDecimalNumber zero];
        } else {
            gallery.displayOrder = [NSDecimalNumber decimalNumberWithDecimal:[jsonDisplayOrder decimalValue]];
        }
        NSArray *tags = (NSArray *) [jsonData objectForKey:@"tags"];
        if (tags != nil && [tags count] > 0) {
            for (NSString *tagValue in tags) {
                Tag *tag = [Tag insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
                tag.tag = tagValue;
                [gallery addTagsObject:tag];
            }
        }
        NSArray *resourceItems = (NSArray *) [jsonData objectForKey:@"resourceItems"];
        if (resourceItems != nil && [resourceItems count] > 0) {
            for (NSDictionary *resourceItemJson in resourceItems) {
                ResourceItem *resourceItem = [ResourceItem resourceItemWithJsonData:resourceItemJson];
                [gallery addResourceItemsObject:resourceItem];
            }
        }
        return gallery;
    } else {
        return nil;
    }
}

- (NSString *)contentId {
    return [self galleryId];
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
    return nil;
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
    // Core data product has no path in the filesystem
    return nil;
}

- (NSString *)contentType {
    return CONTENT_TYPE_GALLERY;
}

- (NSNumber *)contentStartPage {
    // Really only valid for resource items
    return nil;
}

- (NSURL *)contentLink {
    // products are on the device
    return nil;
}

- (NSString *)contentInfoText {
    return [self infoText];
}

- (BOOL) hasTags {
    if ([self tags] && [[self tags] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) hasImages {
    return NO;
}

- (NSArray *)contentCategories {
    return nil;
}

- (NSArray *)contentProducts {
    return nil;
}

- (NSArray *)contentIndustries {
    return nil;
}

- (NSArray *)contentIndustryProducts {
    return nil;
}

- (NSArray *)contentResources {
    return nil;
}

- (NSArray *)contentGalleries {
    return nil;
}

- (NSArray *)contentResourceItems {
    if ([self hasResourceItems]) {
        NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortNameDescriptor, nil];
        return [[self resourceItems] sortedArrayUsingDescriptors:sortDescriptors];
    } else {
        return nil;
    }
}

- (BOOL) hasCategories {
    return NO;
}

- (BOOL) hasProducts {
    return NO;
}

- (BOOL) hasIndustries {
    return NO;
}

- (BOOL) hasIndustryProducts {
    return NO;
}

- (BOOL) hasResources {
    return NO;
}

- (BOOL) hasResourceItems {
    if ([self resourceItems] && [[self resourceItems] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) hasGalleries {
    return NO;
}

@end

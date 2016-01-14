#import "Catalog.h"
#import "Image.h"
#import "Tag.h"
#import "SFCategory.h"
#import "DataManager.h"
#import "ContentUtils.h"
#import "InfoPanel.h"

#import "NSFileManager+Utilities.h"

@implementation Catalog

+ (Catalog *) catalogWithJsonData:(NSDictionary *)jsonData {
    if (jsonData) {
        // Make from the dictionary
        Catalog *catalog = [Catalog insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
        catalog.catalogId = (NSString *) [jsonData objectForKey:@"catalogId"];
        catalog.title = (NSString *) [jsonData objectForKey:@"title"];
        catalog.thumbNail = (NSString *) [jsonData objectForKey:@"thumbNail"];
        NSArray *images = (NSArray *) [jsonData objectForKey:@"images"];
        if (images != nil && [images count] > 0) {
            for (NSString *imagePath in images) {
                Image *image = [Image insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
                image.imagePath = imagePath;
                [catalog addImagesObject:image];
            }
        }
        NSArray *tags = (NSArray *) [jsonData objectForKey:@"tags"];
        if (tags != nil && [tags count] > 0) {
            for (NSString *tagValue in tags) {
                Tag *tag = [Tag insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
                tag.tag = tagValue;
                [catalog addTagsObject:tag];
            }
        }
        NSArray *categories = (NSArray *) [jsonData objectForKey:@"categories"];
        if (categories != nil && [categories count] > 0) {
            for (NSDictionary *categoryJson in categories) {
                SFCategory *category = [SFCategory categoryWithJsonData:categoryJson];
                [catalog addCategoriesObject:category];
            }
        }
        NSArray *infoPanels = (NSArray *) [jsonData objectForKey:@"infoPanels"];
        if (infoPanels != nil && [infoPanels count] > 0) {
            for (NSDictionary *infoPanelJson in infoPanels) {
                InfoPanel *infoPanel = [InfoPanel infoPanelWithJsonData:infoPanelJson];
                [catalog addInfoPanelsObject:infoPanel];
            }
        }
        return catalog;
    } else {
        return nil;
    }
}

- (NSString *)contentId {
    return [self catalogId];
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
    // Core data catalog has no path in the filesystem
    return nil;
}

- (NSString *)contentType {
    return CONTENT_TYPE_CATALOG;
}

- (NSNumber *)contentStartPage {
    // Really only valid for resource items
    return nil;
}

- (NSURL *)contentLink {
    // catalogs are on the device 
    return nil;
}

- (NSString *)contentInfoText {
    return nil;
}

- (BOOL) hasImages {
    if ([self images] && [[self images] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) hasTags {
    if ([self tags] && [[self tags] count] > 0) {
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

- (NSArray *)contentResourceItems {
    return nil;
}

- (BOOL) hasCategories {
    if ([self categories] && [[self categories] count] > 0) {
        return YES;
    } else {
        return NO;
    }
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
    return NO;
}

- (NSArray *)contentGalleries {
    return nil;
}

- (BOOL) hasGalleries {
    return NO;
}

@end

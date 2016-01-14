#import "Industry.h"
#import "Tag.h"
#import "Image.h"
#import "Resource.h"
#import "IndustryProduct.h"

#import "DataManager.h"
#import "ContentUtils.h"
#import "ContentConstants.h"

#import "NSFileManager+Utilities.h"

@implementation Industry

+ (Industry *)industryWithJsonData:(NSDictionary *)jsonData {
    if (jsonData) {
        Industry *industry = [Industry insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
        industry.industryId = (NSString *) [jsonData objectForKey:@"industryId"];
        industry.title = (NSString *) [jsonData objectForKey:@"title"];
        industry.thumbNail = (NSString *) [jsonData objectForKey:@"thumbNail"];
        industry.infoText = (NSString *)[jsonData objectForKey:@"infoText"];
        
        NSNumber *jsonDisplayOrder = (NSNumber *)[jsonData objectForKey:@"displayOrder"];
        if (jsonDisplayOrder == nil) {
            industry.displayOrder = [NSDecimalNumber zero];
        } else {
            industry.displayOrder = [NSDecimalNumber decimalNumberWithDecimal:[jsonDisplayOrder decimalValue]];
        }
        
        NSArray *images = (NSArray *) [jsonData objectForKey:@"images"];
        if (images != nil && [images count] > 0) {
            for (NSString *imagePath in images) {
                Image *image = [Image insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
                image.imagePath = imagePath;
                [industry addImagesObject:image];
            }
        }
        NSArray *tags = (NSArray *) [jsonData objectForKey:@"tags"];
        if (tags != nil && [tags count] > 0) {
            for (NSString *tagValue in tags) {
                Tag *tag = [Tag insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
                tag.tag = tagValue;
                [industry addTagsObject:tag];
            }
        }
        NSArray *resources = (NSArray *) [jsonData objectForKey:@"resources"];
        if (resources != nil && [resources count] > 0) {
            for (NSDictionary *resourceJson in resources) {
                Resource *resource = [Resource resourceWithJsonData:resourceJson];
                [industry addResourcesObject:resource];
            }
        }
        NSArray *industryProducts = (NSArray *) [jsonData objectForKey:@"industryProducts"];
        if (industryProducts != nil && [industryProducts count] > 0) {
            for (NSDictionary *industryProductJson in industryProducts) {
                IndustryProduct *industryProduct = [IndustryProduct industryProductWithJsonData:industryProductJson];
                [industry addIndustryProductsObject:industryProduct];
            }
        }
        return industry;
    } else {
        return nil;
    }
}

- (NSString *)contentId {
    return [self industryId];
}

- (NSString *)contentThumbNail {
    if ([self thumbNail]) {
        return [NSCacheFolder() stringByAppendingPathComponent:[self thumbNail]];
    } else {
        return nil;
    }
}

- (NSString *)contentTitle {
    return self.title;
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
    // Core data product has no path in the filesystem
    return nil;
}

- (NSString *)contentType {
    return CONTENT_TYPE_INDUSTRY;
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
    if ([self images] && [[self images] count] > 0) {
        return YES;
    } else {
        return NO;
    }
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
    if ([self hasIndustryProducts]) {
        return [[self industryProducts] allObjects];
    } else {
        return nil;
    }
}

- (NSArray *)contentResources {
    if ([self hasResources]) {
        NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortNameDescriptor, nil];
        return [[self resources] sortedArrayUsingDescriptors:sortDescriptors];
    } else {
        return nil;
    }
}

- (NSArray *)contentResourceItems {
    return nil;
}

- (NSArray *)contentGalleries {
    return nil;
}

- (BOOL) hasGalleries {
    return NO;
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
    if ([self industryProducts] && [[self industryProducts] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) hasResources {
    if ([self resources] && [[self resources] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) hasResourceItems {
    return NO;
}


@end

#import "Resource.h"
#import "ResourceItem.h"
#import "DataManager.h"
#import "ContentUtils.h"

@implementation Resource

+ (Resource *)resourceWithJsonData:(NSDictionary *)jsonData {
    if (jsonData) {
        Resource *resource = [Resource insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
        resource.resourceId = (NSString *) [jsonData objectForKey:@"resourceId"];
        resource.title = (NSString *) [jsonData objectForKey:@"title"];
        
        NSNumber *jsonDisplayOrder = (NSNumber *)[jsonData objectForKey:@"displayOrder"];
        if (jsonDisplayOrder == nil) {
            resource.displayOrder = [NSDecimalNumber zero];
        } else {
            resource.displayOrder = [NSDecimalNumber decimalNumberWithDecimal:[jsonDisplayOrder decimalValue]];
        }  
        
        NSArray *resourceItems = (NSArray *) [jsonData objectForKey:@"resourceItems"];
        if (resourceItems != nil && [resourceItems count] > 0) {
            for (NSDictionary *resourceItemJson in resourceItems) {
                ResourceItem *resourceItem = [ResourceItem resourceItemWithJsonData:resourceItemJson];
                [resource addResourceItemsObject:resourceItem];
            }
        }
        return resource;
    } else {
        return nil;
    }
}

- (NSString *)contentId {
    return [self resourceId];
}

- (NSString *)contentThumbNail {
    return nil;
}

- (NSString *)contentTitle {
    return self.title; // Moved to Core Data.  This will be deprecated (used for file system support)[ContentUtils labelForPath:[self title]];
}

- (NSArray *)contentImages {
    return nil;
}

- (NSArray *)contentTags {
    return nil;
}

- (NSString *)contentFilePath {
    // Core data resource has no path in the filesystem
    return nil;
}

- (NSString *)contentType {
    return CONTENT_TYPE_RESOURCE;
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
    // Resource groups don't have tags
    return NO;
}

- (BOOL) hasImages {
    // Resource groups don't have images
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

- (NSArray *)contentResourceItems {
    if ([self hasResourceItems]) {
        NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortNameDescriptor, nil];
        return [[self resourceItems] sortedArrayUsingDescriptors:sortDescriptors];
    } else {
        return nil;
    }
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

@end

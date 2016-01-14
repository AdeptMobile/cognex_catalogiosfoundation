#import "ResourceItem.h"
#import "DataManager.h"
#import "ContentUtils.h"

#import "NSFileManager+Utilities.h"

@implementation ResourceItem

+ (ResourceItem *) resourceItemWithJsonData:(NSDictionary *)jsonData {
    if (jsonData) {
        ResourceItem *resourceItem = [ResourceItem insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
        resourceItem.resourceItemId = (NSString *)[jsonData objectForKey:@"resourceItemId"];
        resourceItem.contentPath = (NSString *)[jsonData objectForKey:@"contentPath"];
        resourceItem.resourceType = (NSString *)[jsonData objectForKey:@"resourceType"];
        resourceItem.title = (NSString *)[jsonData objectForKey:@"title"];
        resourceItem.thumbNail = (NSString *)[jsonData objectForKey:@"thumbNail"];
        resourceItem.infoText = (NSString *)[jsonData objectForKey:@"infoText"];
        
        NSNumber *jsonStartPage = (NSNumber *)[jsonData objectForKey:@"startPage"];
        if (jsonStartPage == nil) {
            resourceItem.startPage = [NSDecimalNumber zero];
        } else {
            resourceItem.startPage = [NSDecimalNumber decimalNumberWithDecimal:[jsonStartPage decimalValue]];
        }       
        
        resourceItem.remotePath = (NSString *)[jsonData objectForKey:@"remotePath"];
        
        NSNumber *jsonDisplayOrder = (NSNumber *)[jsonData objectForKey:@"displayOrder"];        
        if (jsonDisplayOrder == nil) {
            resourceItem.displayOrder = [NSDecimalNumber zero];
        } else {
            resourceItem.displayOrder = [NSDecimalNumber decimalNumberWithDecimal:[jsonDisplayOrder decimalValue]];
        }       
        

        return resourceItem;
    } else {
        return nil;
    }
}

- (NSString *)contentId {
    return [self resourceItemId];
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
    return nil;
}

- (NSString *)contentFilePath {
    if ([self contentPath]) {
        return [NSCacheFolder() stringByAppendingPathComponent:[self contentPath]];
    } else {
        return nil;
    }
}

- (NSString *)contentType {
    return [self resourceType];
}

- (NSNumber *)contentStartPage {
    return [self startPage];
}

- (NSURL *)contentLink {
    if ([self remotePath]) {
        return [NSURL URLWithString:[self remotePath]];
    }
    return nil;
}

- (NSString *)contentInfoText {
    return [self infoText];
}

- (BOOL) hasTags {
    // Resource Items don't have tags
    return NO;
}

- (BOOL) hasImages {
    // Resource Items don't have images.  They can *be* images though....
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
    return NO;
}

- (BOOL) hasResources {
    return NO;
}

- (BOOL) hasResourceItems {
    return NO;
}

@end

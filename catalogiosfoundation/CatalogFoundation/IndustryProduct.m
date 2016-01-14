#import "IndustryProduct.h"
#import "DataManager.h"
#import "ContentUtils.h"

#import "NSFileManager+Utilities.h"

@implementation IndustryProduct

+ (IndustryProduct *)industryProductWithJsonData:(NSDictionary *)jsonData {
    if (jsonData) {
        IndustryProduct *industryProduct = [IndustryProduct insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
        industryProduct.title = (NSString *) [jsonData objectForKey:@"title"];
        industryProduct.thumbNail = (NSString *) [jsonData objectForKey:@"thumbNail"];
        industryProduct.productId = (NSString *)[jsonData objectForKey:@"productId"];
        return industryProduct;
    } else {
        return nil;
    }
}

- (NSString *)contentId {
    return [self productId];
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
    return nil;
}

- (NSArray *)contentTags {
    return nil;
}

- (NSString *)contentFilePath {
    // Core data product has no path in the filesystem
    return nil;
}

- (NSString *)contentType {
    return CONTENT_TYPE_INDUSTRY_PRODUCT;
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
    return nil;
}

- (NSArray *)contentGalleries {
    return nil;
}

- (BOOL) hasGalleries {
    return NO;
}

- (BOOL) hasTags {
        return NO;
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

- (NSArray *)contentResourceItems {
    return nil;
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

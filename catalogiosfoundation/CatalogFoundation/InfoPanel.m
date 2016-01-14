#import "InfoPanel.h"
#import "DataManager.h"
#import "Image.h"
#import "ContentUtils.h"
#import "ContentConstants.h"
#import "NSFileManager+Utilities.h"

@implementation InfoPanel

+ (InfoPanel *) infoPanelWithJsonData:(NSDictionary *)jsonData {
    if (jsonData) {
        // Make from the dictionary
        InfoPanel *panel = [InfoPanel insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
        panel.panelId = (NSString *) [jsonData objectForKey:@"panelId"];
        panel.title = (NSString *) [jsonData objectForKey:@"title"];
        panel.contentPath = (NSString *) [jsonData objectForKey:@"contentPath"];
        
        NSNumber *jsonDisplayOrder = (NSNumber *)[jsonData objectForKey:@"displayOrder"];
        if (jsonDisplayOrder == nil) {
            panel.displayOrder = [NSDecimalNumber zero];
        } else {
            panel.displayOrder = [NSDecimalNumber decimalNumberWithDecimal:[jsonDisplayOrder decimalValue]];
        }  
        
        NSArray *images = (NSArray *) [jsonData objectForKey:@"images"];
        if (images != nil && [images count] > 0) {
            for (NSString *imagePath in images) {
                Image *image = [Image insertInManagedObjectContext:[[DataManager sharedInstance] mainObjectContext]];
                image.imagePath = imagePath;
                [panel addImagesObject:image];
            }
        }
        return panel;
    } else {
        return nil;
    }
}

#pragma mark - ContentViewBehavior 
- (NSString *) contentId {
    return nil;
}

- (NSString *) contentThumbNail {
    return nil;
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
    return CONTENT_TYPE_HTML;
}

- (NSNumber *) contentStartPage {
    return nil;
}

- (NSURL *)contentLink {
    return nil;
}

- (NSString *)contentInfoText {
    return nil;
}

- (NSArray *)contentCategories { 
    return nil;
}

- (NSArray *) contentProducts {
    return nil;
}

- (NSArray *)contentIndustries {
    return nil;
}

- (NSArray *)contentIndustryProducts {
    return nil;
}

- (NSArray *) contentResources {
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

- (BOOL) hasImages {
    if ([self images] && [[self images] count] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL) hasTags {
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

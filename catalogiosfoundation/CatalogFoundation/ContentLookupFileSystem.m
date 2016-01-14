//
//  ContentLookupFileSystem.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 3/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ContentLookupFileSystem.h"

#import "SFAppConfig.h"

#import "ContentUtils.h"
#import "PropertyUtils.h"
#import "ContentView.h"

#import "NSString+CamelCaseUtils.h"

@interface ContentLookupFileSystem()

- (void) loadResourceLabels;
- (void) loadResourceLinks;
- (ContentView *) contentViewFromItemDir: (NSString *)itemDir;
- (NSArray *) dirContentPathsAt: (NSString *) startPath withFileMgr:(NSFileManager *)fileMgr;
- (NSString *) itemThumbnailImagePath:(NSString *)itemPath;
- (NSArray *) itemPaths:(NSString *) categoryPath;
- (NSArray *) resourceItemsAtPath: (NSString *) resourceItemsPath;
- (NSArray *) contentViewsFromResourceDir: (NSString *)resourceDir;
- (NSURL *) itemContentDocURL:(NSString *)itemContentItemPath;
- (NSString *) lookupPreviewLabelFor:(NSString *)resourceFilename;
- (NSString *) lookupPreviewLinkFor:(NSString *)resourceFilename;

@end

@implementation ContentLookupFileSystem

- (id) init {
    self = [super init];
    if (self != nil) {
        // do initialization if needed
    }
    return self;
}

- (void) dealloc {
    resourcePreviewLabelProperties = nil;
    
    resourcePreviewLinksProperties = nil;
}

- (void) setup {
    // Load the properties for resource preview labels.  Synchronize?
    [self loadResourceLabels];
    [self loadResourceLinks];
}

- (void) refresh {
    [self loadResourceLabels];
    [self loadResourceLinks];
}

- (NSString *) lookupPreviewLabelFor:(NSString *)resourceFilename {
    NSString *label = [resourcePreviewLabelProperties objectForKey:resourceFilename];
    return label;
}

- (NSString *) lookupPreviewLinkFor:(NSString *)resourceFilename {
    NSString *label = [resourcePreviewLinksProperties objectForKey:resourceFilename];
    return label;
}

- (NSArray *) mainCategoryPaths {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        NSString *baseContentPath = [[SFAppConfig sharedInstance] getLocalContentDocPath];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSString *contentPath = [cacheDirectory stringByAppendingPathComponent:baseContentPath];
        
        // Pick out the main/top level paths
        NSArray *foundPaths = [self dirContentPathsAt:contentPath withFileMgr:fileMgr];
        
        NSMutableArray *pathViews = [NSMutableArray arrayWithCapacity:[foundPaths count]];
        for (NSString *aPath in foundPaths) {
            [pathViews addObject:[self contentViewFromItemDir:aPath]];
        }
        return [NSArray arrayWithArray:pathViews];;
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }

}

- (NSArray *) mainInfoPanels {
    return nil;
}

- (NSArray *) mainSpinnerPanels {
    return [self mainCategoryPaths];
}

- (id<ContentViewBehavior>) topLevelCatalog {
    return nil;
}

- (id<ContentViewBehavior>) mainCategoryPath:(NSString *)catName {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        NSString *baseContentPath = [[SFAppConfig sharedInstance] getLocalContentDocPath];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSString *contentPath = [cacheDirectory stringByAppendingPathComponent:baseContentPath];
        
        // Pick out the main/top level paths
        NSArray *foundPaths = [self dirContentPathsAt:contentPath withFileMgr:fileMgr];
        
        if ([foundPaths count] > 0) {
            for (NSString *path in foundPaths) {
                if ([[path lastPathComponent] isEqualToString:catName]) {
                    return [self contentViewFromItemDir:path];
                }
            }
        }
        
        return nil;
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
}

#pragma mark - Private Methods

- (void) loadResourceLabels {
    // Load the properties for resource preview labels
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        NSString *baseContentResourcesPath = [[SFAppConfig sharedInstance] getLocalContentResourcePath];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSString *resourceLabelsPath = [cacheDirectory stringByAppendingPathComponent:baseContentResourcesPath];
        
        resourceLabelsPath = [resourceLabelsPath stringByAppendingPathComponent:@"resourcelabels.csv"];
        
        // Release any previous instance
        if (resourcePreviewLabelProperties) {
            resourcePreviewLabelProperties = nil;
        }
        
        resourcePreviewLabelProperties = [PropertyUtils loadJavaProperties:resourceLabelsPath];
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
    
}

- (void) loadResourceLinks {
    // Load the properties for resource preview labels
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        NSString *baseContentResourcesPath = [[SFAppConfig sharedInstance] getLocalContentResourcePath];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        NSString *resourceLinksPath = [cacheDirectory stringByAppendingPathComponent:baseContentResourcesPath];
        
        resourceLinksPath = [resourceLinksPath stringByAppendingPathComponent:@"resourcelinks.csv"];
        
        // Release any previous instance
        if (resourcePreviewLinksProperties) {
            resourcePreviewLinksProperties = nil;
        }
        
        resourcePreviewLinksProperties = [PropertyUtils loadJavaProperties:resourceLinksPath];
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
    
}

- (NSArray *) dirContentPathsAt: (NSString *) startPath withFileMgr:(NSFileManager *)fileMgr {
    // Pick out the main/top level paths
    NSError *error;
    NSArray *foundPaths = [fileMgr contentsOfDirectoryAtPath:startPath error:&error];
    
    if (foundPaths) {
        NSMutableArray *contentDirPaths = [NSMutableArray arrayWithCapacity:0];
        
        // Build directories only
        for (NSString *path in foundPaths) {
            BOOL isDir;
            BOOL pathExists = [fileMgr fileExistsAtPath:[startPath stringByAppendingPathComponent:path] isDirectory:&isDir];
            NSString *contentFullPath = [startPath stringByAppendingPathComponent:path];
            
            if (pathExists && isDir && ![[SFAppConfig sharedInstance] doIgnoreLocalPath:path]) {
                [contentDirPaths addObject:contentFullPath];
            }
        }
        
        // Make sure the paths are sorted
        [contentDirPaths sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString *) obj1 compare:(NSString *) obj2];
        }];
        return contentDirPaths;
    }
    
    return foundPaths;
    
}

- (NSString *) itemThumbnailImagePath:(NSString *)itemPath {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        
        // Use the image that has a "-thumb" or "-preview" indicator in the path
        NSError *error;
        NSArray *foundPaths = [fileMgr contentsOfDirectoryAtPath:itemPath error:&error];
        
        if (foundPaths) {
            // Build directories only
            for (NSString *path in foundPaths) {
                if ([ContentUtils isThumbnailOrPreview:path]) {
                    return [itemPath stringByAppendingPathComponent:path];
                }
            }
        }
        
        return nil;
    } 
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
}

- (NSArray *) itemDetailImagePaths:(NSString *)itemPath {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        
        NSError *error;
        NSArray *foundPaths = [fileMgr contentsOfDirectoryAtPath:itemPath error:&error];
        
        if (foundPaths) {
            // Build directories only
            NSMutableArray *imagePaths = [NSMutableArray array];
            for (NSString *path in foundPaths) {
                if (([[path pathExtension] isEqualToString:@"png"] 
                     || [[path pathExtension] isEqualToString:@"PNG"] 
                     || [[path pathExtension] isEqualToString:@"jpg"] 
                     || [[path pathExtension] isEqualToString:@"JPG"] 
                     || [[path pathExtension] isEqualToString:@"gif"] 
                     || [[path pathExtension] isEqualToString:@"GIF"]) 
                    && ![ContentUtils isThumbnailOrPreview:path]) {
                    [imagePaths addObject:[itemPath stringByAppendingPathComponent:path]];
                }
            }
            return [NSArray arrayWithArray:imagePaths];
        }
        return nil;
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
}

- (NSString *) contentTypeFromItemDir: (NSString *)itemDir {
    // Check to see if there is a parent directory named Resources.  If we find one
    // we are a resource group.
    if ([[itemDir pathComponents] indexOfObject:@"Resources"] != NSNotFound) {
        return [NSString stringWithString:CONTENT_TYPE_RESOURCE];
    }
    
    // See if there is a Resources directory under us.  If so, we are a product.
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        BOOL isDir = NO;
        BOOL exists = [fileMgr fileExistsAtPath:[itemDir stringByAppendingPathComponent:@"Resources"] isDirectory:&isDir];
        if (exists && isDir) {
            return [NSString stringWithString:CONTENT_TYPE_PRODUCT];
        }
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
    
    // Otherwise we are a category.
    return [NSString stringWithString:CONTENT_TYPE_CATEGORY];
}

- (NSArray *) itemPaths:(NSString *) categoryPath {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        NSArray *foundPaths = [self dirContentPathsAt:categoryPath withFileMgr:fileMgr];
        
        return foundPaths;
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
    
}

- (NSArray *) resourceItemsAtPath: (NSString *) resourceItemsPath {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        NSString *resourceTypePath = resourceItemsPath;
        NSMutableArray *resourcePaths = [NSMutableArray arrayWithCapacity:0];
        
        NSError *error;
        NSArray *foundPaths = [fileMgr contentsOfDirectoryAtPath:resourceTypePath error:&error];
        
        if (foundPaths) {        
            // Build directories and file paths (I do not care about content at this point, just the paths
            for (NSString *path in foundPaths) {
                NSString *contentFullPath = [resourceTypePath stringByAppendingPathComponent:path];
                
                if ([path rangeOfString:@"."].location != 0) {
                    [resourcePaths addObject:contentFullPath];
                }
            }
            
            // Make sure the paths are sorted
            [resourcePaths sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [(NSString *) obj1 compare:(NSString *) obj2];
            }];
            
        }
        
        return resourcePaths;
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
}

- (NSString *) thumbNailForResourceItem: (NSString *)itemPath {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        if ([ContentUtils isSymbolicLink:itemPath withFileMgr:fileMgr]) {
            NSString *symLinkPath = [ContentUtils filePathForSymbolicLink:itemPath withFileMgr:fileMgr];
            
            if (![itemPath isEqualToString:symLinkPath] && [fileMgr fileExistsAtPath:symLinkPath]) {
                return [self thumbNailForResourceItem:symLinkPath];
            } 
            
            return nil;
        }
        
        BOOL isDir;
        BOOL pathExists = [fileMgr fileExistsAtPath:itemPath isDirectory:&isDir];
        
        if (pathExists && isDir) {
            NSError *error;
            NSArray *foundPaths = [fileMgr contentsOfDirectoryAtPath:itemPath error:&error];
            
            if (foundPaths) {
                // Use the image that has a "-preview" indicator in the path
                for (NSString *path in foundPaths) {
                    if ([ContentUtils isThumbnailOrPreview:path]) {
                        return [itemPath stringByAppendingPathComponent:path];
                    }
                }
            }
            
        }            
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
    return nil;
}

- (NSURL *) itemContentDocURL:(NSString *)itemContentItemPath {
    
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        if ([ContentUtils isSymbolicLink:itemContentItemPath withFileMgr:fileMgr]) {
            NSString *symLinkPath = [ContentUtils filePathForSymbolicLink:itemContentItemPath withFileMgr:fileMgr];
            if (![itemContentItemPath isEqualToString:symLinkPath] && [fileMgr fileExistsAtPath:symLinkPath]) {
                return [self itemContentDocURL:symLinkPath];
            }
            
            return nil;
        }
        
        BOOL isDir;
        BOOL pathExists = [fileMgr fileExistsAtPath:itemContentItemPath isDirectory:&isDir];
        
        if (pathExists) {
            if (isDir) {
                NSError *error;
                NSArray *foundPaths = [fileMgr contentsOfDirectoryAtPath:itemContentItemPath error:&error];
                
                if (foundPaths) {
                    // Use the first file that has a suffix and is not a preview image
                    for (NSString *path in foundPaths) {
                        if ([path rangeOfString:@"."].location != 0 
                            && ![ContentUtils isThumbnailOrPreview:path]) {
                            NSString *filePath = [itemContentItemPath stringByAppendingPathComponent:path];
                            if ([ContentUtils isSymbolicLink:filePath withFileMgr:fileMgr]) {
                                NSString *symLinkPath = [ContentUtils filePathForSymbolicLink:filePath withFileMgr:fileMgr];
                                if (![filePath isEqualToString:symLinkPath] && [fileMgr fileExistsAtPath:symLinkPath]) {
                                    return [self itemContentDocURL:symLinkPath];
                                }
                                
                                return nil;
                            } else {
                                return [[NSURL alloc] initFileURLWithPath:filePath];
                            }
                        }
                    }
                }
            } else {
                return [[NSURL alloc] initFileURLWithPath:itemContentItemPath];
            }
        } 
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
    
    // Path does not exist, no valid file exists for the path
    return nil;
}

/*
 * This version is intended to work with category, product and resources
 * directories.  The resource items layout will need to be handled 
 * differently.
 */
- (ContentView *) contentViewFromItemDir: (NSString *)itemDir {
    ContentView *cview = [[ContentView alloc] init];
    // No id's in the file system layout
    cview.cid = nil;
    cview.thumbNail = [self itemThumbnailImagePath:itemDir];
    cview.title = [ContentUtils labelForPath:itemDir];
    cview.images = [self itemDetailImagePaths:itemDir];
    // No tags in the file system layout
    cview.tags = nil;
    // The file system location is its content path
    cview.contentPath = itemDir;
    cview.type = [self contentTypeFromItemDir:itemDir];
    // Only makes sense for an actual resource item like a PDF.
    cview.startPage = nil;
    // Only makes sense for an actual resource item that we might access remotely.
    cview.remotePath = nil;
    
    // Handle creation of resource item views differently.
    if ([cview.type isEqualToString:CONTENT_TYPE_RESOURCE]) {
        cview.resourceItems = [self contentViewsFromResourceDir:itemDir];
    } else {
        NSArray *subPaths = nil;
        if ([cview.type isEqualToString:CONTENT_TYPE_PRODUCT]) {
            subPaths = [self itemPaths:[itemDir stringByAppendingPathComponent:@"Resources"]];
        } else {
            subPaths = [self itemPaths:itemDir];
        }
        
        if (subPaths && [subPaths count] > 0) {
            NSMutableArray *subcategories = [NSMutableArray arrayWithCapacity:[subPaths count]];
            NSMutableArray *products = [NSMutableArray arrayWithCapacity:[subPaths count]];
            NSMutableArray *resources = [NSMutableArray arrayWithCapacity:[subPaths count]];
            
            for (NSString *path in subPaths) {
                ContentView *subView = [self contentViewFromItemDir:path];
                if ([subView.type isEqualToString:CONTENT_TYPE_CATEGORY] ) {
                    [subcategories addObject:subView];
                } else if ([subView.type isEqualToString:CONTENT_TYPE_PRODUCT]) {
                    [products addObject:subView];
                } else if ([subView.type isEqualToString:CONTENT_TYPE_RESOURCE]) {
                    [resources addObject:subView];
                } 
            }
            
            cview.categories = [NSArray arrayWithArray:subcategories];
            cview.products = [NSArray arrayWithArray:products];
            cview.resources = [NSArray arrayWithArray:resources];
            
        }
    }

    return cview;
}

- (NSString *) contentTypeFromResourceItem: (NSString *) resourceItemPath {
    if ([ContentUtils isMovieFile:resourceItemPath]) {
        return CONTENT_TYPE_MOVIE;
    } else if ([ContentUtils isImageFile:resourceItemPath]) {
        return CONTENT_TYPE_IMAGE;
    } else if ([ContentUtils isPDFFile:resourceItemPath]) {
        return CONTENT_TYPE_PDF;
    } else if ([ContentUtils isCADFile:resourceItemPath]) {
        return CONTENT_TYPE_CAD;
    } else {
        return CONTENT_TYPE_UNKNOWN;
    }
}

- (NSArray *) contentViewsFromResourceDir: (NSString *)resourceDir {
    NSArray *resourceItemPaths = [self resourceItemsAtPath:resourceDir];
    if (resourceItemPaths && [resourceItemPaths count] > 0) {
        NSMutableArray *resourceItemViews = [NSMutableArray arrayWithCapacity:[resourceItemPaths count]];
        for (NSString *resourceItem in resourceItemPaths) {
            NSURL *actualUrl = [self itemContentDocURL:resourceItem];
            NSString *labelPresent = [self lookupPreviewLabelFor:[actualUrl lastPathComponent]];
            NSString *linkPresent = [self lookupPreviewLinkFor:[actualUrl lastPathComponent]];
            BOOL isRemote = (linkPresent) ? YES : NO;
            
            ContentView *cview = [[ContentView alloc] init];
            // No id's in the file system layout
            cview.cid = nil;
            cview.title = labelPresent;
            cview.images = nil;
            // No tags in the file system layout
            cview.tags = nil;
            // Filesystem doesn't have a way to specify a start page
            cview.startPage = nil;
            
            // if the thumbnail is nil, we will try to generate a preview
            // in the main app
            cview.thumbNail = [self thumbNailForResourceItem:resourceItem];
            
            if (isRemote) {
                cview.remotePath = linkPresent;
                cview.type = CONTENT_TYPE_REMOTE;
            } else {
                cview.contentPath = [actualUrl path];
                cview.type = [self contentTypeFromResourceItem:[actualUrl path]];
            }
            
            [resourceItemViews addObject:cview];
        }
        return [NSArray arrayWithArray:resourceItemViews];
    } else {
        return nil;
    }
}

- (id<ContentViewBehavior>) lookupProduct:(NSString *)productId {
    // Not going to happen. SMM
    return nil;
}

- (id<ContentViewBehavior>) mainCategoryForProduct:(NSString *)productId {
    // Not going to happen.  SMM
    return nil;
}

- (NSArray *) searchProducts:(NSString *)searchString {
    // Not going to happen. SMM
    return nil;
}

- (id<ContentViewBehavior>) lookupIndustry:(NSString *)industryId {
    // Not going to happen. SMM
    return nil;
}

- (id<ContentViewBehavior>) mainCategoryForIndustry:(NSString *)industryId {
    // Not going to happen. SMM
    return nil;
}

- (NSArray *) searchIndustries:(NSString *)searchString {
    // Not going to happen. SMM
    return nil;
}

- (id<ContentViewBehavior>) lookupGallery:(NSString *)galleryId {
    // Not going to happen. SMM
    return nil;
}

- (id<ContentViewBehavior>) mainCategoryForGallery:(NSString *)galleryId {
    // Not going to happen. SMM
    return nil;
}

- (NSArray *) searchGalleries:(NSString *)searchString {
    // Not going to happen. SMM
    return nil;
}

- (NSArray *) searchProductsAndIndustriesAndGalleries:(NSString *)searchString {
    // This isn't happening either.  SMM
    return nil;
}

@end

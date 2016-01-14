//
//  ContentUtils.m
//  ToloApp
//
//  Created by Torey Lomenda on 6/7/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

//#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "ContentUtils.h"

#import "SFAppConfig.h"

#import "UnpackContentOperation.h"

#import "NSString+CamelCaseUtils.h"
#import "UIImage+Resize.h"
#import "UIImage+Extensions.h"
#import "UIImage+CatalogFoundationResourceImage.h"
#import "PDKeychainBindingsController.h"

#import "CJSONDeserializer.h"

#import <math.h>

// SMM Temporary
#import "Catalog.h"
#import "SFCategory.h"

NSString *const KEYCHAIN_USER_KEY = @"com.objectpartners.salesfolio.SFUserNameKey";
NSString *const KEYCHAIN_PW_KEY = @"com.objectpartners.salesfolio.SFPasswordKey";
NSString *const SETTINGS_CONFIGURED = @"sf.app.settings.SFConfigured";
NSString *const SETTINGS_DISABLE_VIDEO_SYNC = @"sf.app.settings.contentSyncDisableVideo";
NSString *const SETTINGS_DISABLE_PRESENTATION_SYNC = @"sf.app.settings.contentSyncDisablePresentation";


@implementation ContentUtils

#pragma mark - Configured Checks
+ (BOOL) isAppConfigured {
    NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
    BOOL appConfigured = [appDefaults boolForKey:SETTINGS_CONFIGURED];
    return appConfigured;
}

+ (void) setAppConfigured:(BOOL)configured {
    NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
    [appDefaults setBool:configured forKey:SETTINGS_CONFIGURED];
    [appDefaults synchronize];
}

#pragma mark - Username and Password Handling
+ (NSString *) getUsernameFromKeychain {
    PDKeychainBindings *keyBindings = [PDKeychainBindings sharedKeychainBindings];
    NSString *username = (NSString *)[keyBindings objectForKey:KEYCHAIN_USER_KEY];
    return username;
}

+ (void) setUsernameInKeychain:(NSString *)username {
    PDKeychainBindings *keyBindings = [PDKeychainBindings sharedKeychainBindings];
    [keyBindings setObject:username forKey:KEYCHAIN_USER_KEY];
}
+ (void) removeUsernameInKeychain {
    PDKeychainBindings *keyBindings = [PDKeychainBindings sharedKeychainBindings];
    
    [keyBindings removeObjectForKey:KEYCHAIN_USER_KEY];
}

+ (NSString *) getPasswordFromKeychain {
    PDKeychainBindings *keyBindings = [PDKeychainBindings sharedKeychainBindings];
    NSString *password = (NSString *)[keyBindings objectForKey:KEYCHAIN_PW_KEY];
    return password;
}

+ (void) setPasswordInKeychain:(NSString *)password {
    PDKeychainBindings *keyBindings = [PDKeychainBindings sharedKeychainBindings];
    [keyBindings setObject:password forKey:KEYCHAIN_PW_KEY];
}
+ (void) removePasswordInKeychain {
    PDKeychainBindings *keyBindings = [PDKeychainBindings sharedKeychainBindings];
    
    [keyBindings removeObjectForKey:KEYCHAIN_PW_KEY];
}

#pragma mark - User configuration settings for sync
+ (BOOL) isVideoSyncDisabled {
    NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
    BOOL disabled = [appDefaults boolForKey:SETTINGS_DISABLE_VIDEO_SYNC];
    return disabled;
}

+ (void) setVideoSyncDisabled:(BOOL)disableVideoSync {
    NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
    [appDefaults setBool:disableVideoSync forKey:SETTINGS_DISABLE_VIDEO_SYNC];
    [appDefaults synchronize];
}

+ (BOOL) isPresentationSyncDisabled {
    NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
    BOOL disabled = [appDefaults boolForKey:SETTINGS_DISABLE_PRESENTATION_SYNC];
    return disabled;
}

+ (void) setPresentationSyncDisabled:(BOOL)disablePresentationSync {
    NSUserDefaults *appDefaults = [NSUserDefaults standardUserDefaults];
    [appDefaults setBool:disablePresentationSync forKey:SETTINGS_DISABLE_PRESENTATION_SYNC];
    [appDefaults synchronize];
}

#pragma mark -
#pragma mark Setup Methods
+ (BOOL) fileExists:(NSString *)filePath {
    NSFileManager *fileMgr;
    BOOL fileExists = NO;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        fileExists = [fileMgr fileExistsAtPath:filePath];
    }
    @finally {
        fileMgr = nil;
    }
    return fileExists;
}

+ (void) removeFile:(NSString *)filePath {
    NSFileManager *fileMgr;
    BOOL isDir = NO;
    NSError *error = nil;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        if ([fileMgr fileExistsAtPath:filePath isDirectory:&isDir]) {
            if (![fileMgr removeItemAtPath:filePath error:&error]) {
                NSLog(@"Error removing file:  %@", [error description]);
            }
        }
    }
    @finally {
        fileMgr = nil;
    }
}

#pragma mark -
#pragma mark Category Paths
+ (NSArray *) subCategoryPaths:(NSString *) mainContentPath {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        NSArray *foundPaths = [ContentUtils dirContentPathsAt:mainContentPath withFileMgr:fileMgr];
        
        return foundPaths;
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
}

#pragma mark - 
#pragma mark Product Item Related Methods
+ (BOOL) isProductItemPath: (NSString *) contentPath {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        BOOL isDir = NO;
        BOOL exists = [fileMgr fileExistsAtPath:[contentPath stringByAppendingPathComponent:@"Resources"] isDirectory:&isDir];
        if (exists && isDir) {
            return YES;
        } else {
            return NO;
        }
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
}

+ (NSArray *) resourceItemsAtPath: (NSString *) resourceItemsPath {
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

+ (NSArray *) itemPaths:(NSString *) categoryPath {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        NSArray *foundPaths = [ContentUtils dirContentPathsAt:categoryPath withFileMgr:fileMgr];
        
        return foundPaths;
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
    
}

+ (UIImage *) itemThumbnailImage:(NSString *)itemPath {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
    
        // Use the image that has a "-thumb" indicator in the path
        NSError *error;
        NSArray *foundPaths = [fileMgr contentsOfDirectoryAtPath:itemPath error:&error];
        
        if (foundPaths) {
            // Build directories only
            for (NSString *path in foundPaths) {
                if ([ContentUtils isThumbnailOrPreview:path]) {
                    return  [UIImage imageWithContentsOfFile:[itemPath stringByAppendingPathComponent:path]];
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

+ (UIImage *) itemDetailImage:(NSString *)itemPath {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
    
        // Find the first png or jpg file and use that as the thumbnail
        NSError *error;
        NSArray *foundPaths = [fileMgr contentsOfDirectoryAtPath:itemPath error:&error];
        
        if (foundPaths) {
            // Build directories only
            for (NSString *path in foundPaths) {
                if (([[path pathExtension] isEqualToString:@"png"] 
                    || [[path pathExtension] isEqualToString:@"PNG"] 
                    || [[path pathExtension] isEqualToString:@"jpg"] 
                    || [[path pathExtension] isEqualToString:@"JPG"] 
                    || [[path pathExtension] isEqualToString:@"gif"] 
                    || [[path pathExtension] isEqualToString:@"GIF"]) 
                    && ![ContentUtils isThumbnailOrPreview:path]) {
                    return  [UIImage imageWithContentsOfFile:[itemPath stringByAppendingPathComponent:path]];
                }
            }
        }
        
        // If none was found fallback to the thumnail image ??
        return [ContentUtils itemThumbnailImage:itemPath];
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
}

+ (NSString *) itemThumbnailImagePath:(NSString *)itemPath {
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

+ (NSString *) itemDetailImagePath:(NSString *)itemPath {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        
        // Find the first png or jpg file and use that as the thumbnail
        NSError *error;
        NSArray *foundPaths = [fileMgr contentsOfDirectoryAtPath:itemPath error:&error];
        
        if (foundPaths) {
            // Build directories only
            for (NSString *path in foundPaths) {
                if (([[path pathExtension] isEqualToString:@"png"] 
                     || [[path pathExtension] isEqualToString:@"PNG"] 
                     || [[path pathExtension] isEqualToString:@"jpg"] 
                     || [[path pathExtension] isEqualToString:@"JPG"] 
                     || [[path pathExtension] isEqualToString:@"gif"] 
                     || [[path pathExtension] isEqualToString:@"GIF"]) 
                    && ![ContentUtils isThumbnailOrPreview:path]) {
                    return  [itemPath stringByAppendingPathComponent:path];
                }
            }
        }
        
        // If none was found fallback to the thumnail image ??
        return [ContentUtils itemThumbnailImagePath:itemPath];
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
}

+ (UIImage *) itemContentPreviewImage:(NSString *)itemContentItemPath {
    
    BOOL itemExists = [self fileExists:itemContentItemPath];
    
    if ([[itemContentItemPath pathExtension] isEqualToString:@"png"] 
        || [[itemContentItemPath pathExtension] isEqualToString:@"PNG"] 
        || [[itemContentItemPath pathExtension] isEqualToString:@"jpg"] 
        || [[itemContentItemPath pathExtension] isEqualToString:@"JPG"]
        || [[itemContentItemPath pathExtension] isEqualToString:@"gif"] 
        || [[itemContentItemPath pathExtension] isEqualToString:@"GIF"]) {
            return  [UIImage imageWithContentsOfFile:itemContentItemPath];
    }
    
    // Generate PDF image of first page
    if ([[itemContentItemPath pathExtension] isEqualToString:@"pdf"] 
        || [[itemContentItemPath pathExtension] isEqualToString:@"PDF"]) {
        return [ContentUtils imageFromPdf:itemContentItemPath];;
    }
    
    if ([ContentUtils isMovieFile:itemContentItemPath]) {
        if (itemExists) {
            return [ContentUtils imageFromMovie:itemContentItemPath];
        } else {
            return [UIImage imageResource:@"sf-default-moviePreview.png"];
        }
    }
    
    if ([[itemContentItemPath pathExtension] isEqualToString:@"stl"] 
        || [[itemContentItemPath pathExtension] isEqualToString:@"STL"] 
        || [[itemContentItemPath pathExtension] isEqualToString:@"easm"] 
        || [[itemContentItemPath pathExtension] isEqualToString:@"EASM"]
        || [[itemContentItemPath pathExtension] isEqualToString:@"eprt"] 
        || [[itemContentItemPath pathExtension] isEqualToString:@"EPRT"]) {
        return  [UIImage imageResource:@"sf-default-cadPreview.png"];
    }

    return nil;
}

+ (BOOL) canOpenInApp:(NSURL *)docUrl {
    // Should be able to open all docs except CAD files
    if (![[docUrl pathExtension] isEqualToString:@"stl"] 
        && ![[docUrl pathExtension] isEqualToString:@"STL"]
        && ![[docUrl pathExtension] isEqualToString:@"easm"] 
        && ![[docUrl pathExtension] isEqualToString:@"EASM"]
        && ![[docUrl pathExtension] isEqualToString:@"eprt"] 
        && ![[docUrl pathExtension] isEqualToString:@"EPRT"]) {
        return YES;
    }
    
    if (![[docUrl pathExtension] isEqualToString:@"stl"]
        && ![[docUrl pathExtension] isEqualToString:@"STL"]
        && ![[docUrl pathExtension] isEqualToString:@"easm"]
        && ![[docUrl pathExtension] isEqualToString:@"EASM"]
        && ![[docUrl pathExtension] isEqualToString:@"eprt"]
        && ![[docUrl pathExtension] isEqualToString:@"EPRT"]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL) isMovieFile:(NSString *)filePath {
    if ([[filePath pathExtension] isEqualToString:@"mov"] 
        || [[filePath pathExtension] isEqualToString:@"MOV"] 
        || [[filePath pathExtension] isEqualToString:@"mp4"] 
        || [[filePath pathExtension] isEqualToString:@"MP4"]
        || [[filePath pathExtension] isEqualToString:@"mpv"] 
        || [[filePath pathExtension] isEqualToString:@"MPV"]
        || [[filePath pathExtension] isEqualToString:@"3gp"] 
        || [[filePath pathExtension] isEqualToString:@"3GP"]
        || [[filePath pathExtension] isEqualToString:@"m4v"]
        || [[filePath pathExtension] isEqualToString:@"M4V"]) {
        return  YES;
    }

    return NO;
}

+ (BOOL) isImageFile:(NSString *)filePath {
    if (filePath) {
        if ([[filePath pathExtension] isEqualToString:@"png"] 
            || [[filePath pathExtension] isEqualToString:@"PNG"] 
            || [[filePath pathExtension] isEqualToString:@"jpg"] 
            || [[filePath pathExtension] isEqualToString:@"JPG"]
            || [[filePath pathExtension] isEqualToString:@"gif"] 
            || [[filePath pathExtension] isEqualToString:@"GIF"]) {
            return  YES;
        }
        
        // Is there a preview
        NSFileManager *fileMgr;
        @try {
            fileMgr = [[NSFileManager alloc] init];
            if ([ContentUtils isSymbolicLink:filePath withFileMgr:fileMgr]) {
                NSString *symLinkPath = [ContentUtils filePathForSymbolicLink:filePath withFileMgr:fileMgr];
                
                if (![filePath isEqualToString:symLinkPath] && [fileMgr fileExistsAtPath:symLinkPath]) {
                    return [ContentUtils isImageFile:symLinkPath];
                }
                
                return NO;
            }
            
            NSError *error;
            NSArray *foundPaths = [fileMgr contentsOfDirectoryAtPath:filePath error:&error];
            
            if (foundPaths) {
                // Use the image that has a "-preview" indicator in the path
                for (NSString *path in foundPaths) {
                    if ([ContentUtils isThumbnailOrPreview:path]) {
                        return  YES;
                    }
                }
            }    
        }
        @finally {
            fileMgr = nil;
            fileMgr = nil;
        }
    }
    return NO;
}

+ (BOOL) isPDFFile:(NSString *)filePath {
    if ([[filePath pathExtension] isEqualToString:@"pdf"] 
        || [[filePath pathExtension] isEqualToString:@"PDF"]) {
        return  YES;
    }
    
    return NO;
}

+ (BOOL) isCADFile:(NSString *)filePath {
    if ([[filePath pathExtension] isEqualToString:@"stl"] 
        || [[filePath pathExtension] isEqualToString:@"STL"]
        || [[filePath pathExtension] isEqualToString:@"step"] 
        || [[filePath pathExtension] isEqualToString:@"STEP"]
        || [[filePath pathExtension] isEqualToString:@"cad"] 
        || [[filePath pathExtension] isEqualToString:@"CAD"]
        || [[filePath pathExtension] isEqualToString:@"jt"] 
        || [[filePath pathExtension] isEqualToString:@"JT"]
        || [[filePath pathExtension] isEqualToString:@"cgr"] 
        || [[filePath pathExtension] isEqualToString:@"CGR"]
        || [[filePath pathExtension] isEqualToString:@"igs"] 
        || [[filePath pathExtension] isEqualToString:@"IGS"]
        || [[filePath pathExtension] isEqualToString:@"prt"] 
        || [[filePath pathExtension] isEqualToString:@"PRT"]
        || [[filePath pathExtension] isEqualToString:@"easm"] 
        || [[filePath pathExtension] isEqualToString:@"EASM"]
        || [[filePath pathExtension] isEqualToString:@"eprt"] 
        || [[filePath pathExtension] isEqualToString:@"EPRT"]) {
        return  YES;
    }
    
    return NO;
}

+ (BOOL) isPresentationFile:(NSString *)filePath {
    if ([[filePath pathExtension] isEqualToString:@"key"]
        || [[filePath pathExtension] isEqualToString:@"KEY"]
        || [[filePath pathExtension] isEqualToString:@"doc"]
        || [[filePath pathExtension] isEqualToString:@"DOC"]
        || [[filePath pathExtension] isEqualToString:@"docx"]
        || [[filePath pathExtension] isEqualToString:@"DOCX"]
        || [[filePath pathExtension] isEqualToString:@"xls"]
        || [[filePath pathExtension] isEqualToString:@"XLS"]
        || [[filePath pathExtension] isEqualToString:@"xlsx"]
        || [[filePath pathExtension] isEqualToString:@"XLSX"]
        || [[filePath pathExtension] isEqualToString:@"ppt"]
        || [[filePath pathExtension] isEqualToString:@"PPT"]
        || [[filePath pathExtension] isEqualToString:@"pptx"]
        || [[filePath pathExtension] isEqualToString:@"PPTX"]) {
        return  YES;
    }
    
    return NO;
    
}

#pragma mark -
#pragma mark File Path Helpers
+ (BOOL) isThumbnailOrPreview:(NSString *)path {
    return [path rangeOfString:@"-preview"].location != NSNotFound 
        || [path rangeOfString:@"_preview"].location != NSNotFound
        || [path rangeOfString:@"-thumb"].location != NSNotFound
        || [path rangeOfString:@"_thumb"].location != NSNotFound;
}

+ (BOOL) isSymbolicLink:(NSString *)path withFileMgr:(NSFileManager *)fileMgr {
    NSDictionary *attributes = [fileMgr attributesOfItemAtPath:path error:nil];
    return [attributes objectForKey:@"NSFileType"] == NSFileTypeSymbolicLink || [path rangeOfString:@"symlink"].location != NSNotFound;
}

+ (NSString *) filePathForSymbolicLink:(NSString *)fullPathSymLink withFileMgr: (NSFileManager *) fileMgr {
    // Determine any relative path components.  For each one 
    if (fullPathSymLink) {
        NSString *linkPath = nil;
        NSArray *pathComponents = [fullPathSymLink pathComponents];
        NSDictionary *attributes = [fileMgr attributesOfItemAtPath:fullPathSymLink error:nil];
        
        if (attributes && [attributes objectForKey:@"NSFileType"] == NSFileTypeSymbolicLink) {
            linkPath = [fileMgr destinationOfSymbolicLinkAtPath:fullPathSymLink error:nil];
        } else if ([fullPathSymLink rangeOfString:@"symlink"].location != NSNotFound) {
            linkPath = [NSString stringWithContentsOfFile:fullPathSymLink encoding:NSUTF8StringEncoding error:nil];
            
            // Only want files that contain a path.  When ZipArchive unzips symbolic links it
            // creates a single line file with the "real" path.  Weird!!
            if (linkPath && [linkPath rangeOfString:[[SFAppConfig sharedInstance] getLocalContentSymlinkRef]].location == NSNotFound) {
                linkPath = nil;
            }
        }
        
        // Is this a relative path symbolic link or absolute
        if (linkPath) {
            if ([linkPath rangeOfString:@"../"].location == 0) {
                NSArray *linkPathComponents = [linkPath pathComponents];
                int relativePathCount = 0;
                
                for (NSString *pathComponent in linkPathComponents) {
                    if ([pathComponent isEqualToString:@".."]) {
                        relativePathCount++;
                    }
                }
                
                // Build the actual link path
                linkPath = @"";
                for (int i = 0; i < [pathComponents count] - (relativePathCount + 1); i++) {
                    linkPath = [linkPath stringByAppendingPathComponent:(NSString *) [pathComponents objectAtIndex:i]];
                }
                
                // Add the path components from the link path that are not relative
                for (NSString *pathComponent in linkPathComponents) {
                    if (![pathComponent isEqualToString:@".."]) {
                        linkPath = [linkPath stringByAppendingPathComponent:pathComponent];
                    }
                } 
            } else {
                // Make sure the link absolute path is correct
                NSString *toloContentPath = [[SFAppConfig sharedInstance] getLocalContentDocPath];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString *cacheDirectory = [paths objectAtIndex:0];
                NSString *basePath = [cacheDirectory stringByAppendingPathComponent:toloContentPath];
                
                // Append to base path (after Content/ToloApp/ path component in the symlink)
                NSRange foundRange = [linkPath rangeOfString:[[SFAppConfig sharedInstance] getLocalContentSymlinkRef]];
                
                if (foundRange.location != NSNotFound) {
                    return [basePath stringByAppendingPathComponent:[linkPath substringFromIndex:foundRange.location + foundRange.length]];
                }
            }
            
            // Just return the link path (all options exhausted at this point
            return linkPath;
        }
        
        return fullPathSymLink;
    }
    
    return nil;
}

+ (NSString *) fileDirName:(NSString *)fileDirPath {
    if (fileDirPath == nil) {
        return nil;
    }
    
    NSArray *pathElements = [fileDirPath componentsSeparatedByString:@"/"];
    
    if (pathElements && [pathElements count] > 0) {
        return (NSString *) [pathElements lastObject];
    }
    
    return fileDirPath;
}

+(NSString *) labelForPath:(NSString *)path {
    if ([[SFAppConfig sharedInstance] doWordifyLabel]) {
        NSString *pathName = [ContentUtils fileDirName:path];
        
        // Strip off any number prefix used for ordering
        if (pathName && [pathName length] > 0) {
            if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[pathName characterAtIndex:0]]) {
                NSRange dashRange = [pathName rangeOfString:@"-"];
                if (dashRange.length != 0) {
                    pathName = [pathName substringFromIndex:dashRange.location + 1];
                }
            }
            
            // Do Tolomatic special token replacement
            pathName = [pathName stringByReplacingOccurrencesOfString:LABEL_TOKEN_REGISTER_TRADEMARK withString:@"®"];
            pathName = [pathName stringByReplacingOccurrencesOfString:LABEL_TOKEN_FORWARD_DASH withString:@"-"];
            pathName = [pathName stringByReplacingOccurrencesOfString:LABEL_TOKEN_FORWARD_SLASH withString:@"/"];
            
            return [pathName wordify];
        }
        
        return @"";
    } else {
        return path;
    }
    
}

+ (NSArray *) dirContentPathsAt: (NSString *) startPath withFileMgr:(NSFileManager *)fileMgr {
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

+ (UIImage *) imageFromPdf:(NSString *)pdfPath {
    // Get from Cache or Generate the image
    NSArray *pathComponents = [pdfPath pathComponents];
    NSString *imagePath = @"/";
    
    for (int i = 0; i < pathComponents.count-1; i++) {
        imagePath = [imagePath stringByAppendingFormat:@"/%@", pathComponents[i]];
    }
    imagePath = [imagePath stringByAppendingPathComponent:[NSString stringWithFormat:@".tmp-%@.png", pathComponents.lastObject]];
    
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        BOOL isDir;
        BOOL cacheImageExists = [fileMgr fileExistsAtPath:imagePath isDirectory:&isDir];
        
        if (cacheImageExists && !isDir) {
            return [UIImage imageWithContentsOfFile:imagePath];
        } else {
            // Generate PDF image of first page
            CFStringRef path;
            CFURLRef url;
            CGPDFDocumentRef document;
            CGPDFPageRef page;
            CGColorSpaceRef colorSpace;
            
            path = CFStringCreateWithCString (NULL, [pdfPath UTF8String], kCFStringEncodingUTF8);
            url = CFURLCreateWithFileSystemPath (NULL, path, kCFURLPOSIXPathStyle, 0);
            
            document = CGPDFDocumentCreateWithURL (url);
            
            // Get the first page of the document
            page = CGPDFDocumentGetPage(document, 1);
            CGPDFPageRetain(page);
            
            // determine the size of the PDF page
            CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
            
            CGFloat pdfScale = 1.0;
            pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
            
            // Create a low res image representation of the PDF page to display before the TiledPDFView
            // renders its content.
            colorSpace = CGColorSpaceCreateDeviceRGB();
            // floorf is used to truncate the calculated float values in order to prevent CGContextRef
            // errors. SMM
            CGContextRef context = CGBitmapContextCreate(NULL,
                                                         floorf(pageRect.size.width),
                                                         floorf(pageRect.size.height),
                                                         8,
                                                         4*floorf(pageRect.size.width),
                                                         colorSpace,
                                                         (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
            
            // First fill the background with white.
            CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
            CGContextFillRect(context,pageRect);
            
            // Scale the context so that the PDF page is rendered
            // at the correct size for the zoom level.
            CGContextScaleCTM(context, pdfScale, pdfScale);
            
            CGContextSetInterpolationQuality(context, kCGInterpolationHigh); CGContextSetRenderingIntent(context, kCGRenderingIntentDefault);
            CGContextDrawPDFPage(context, page);
            
            CGImageRef newImageRef = CGBitmapContextCreateImage(context);
            UIImage *pdfImage = [UIImage imageWithCGImage:newImageRef];
            
            // Clean up PDF document
            CFRelease (path);
            CFRelease(url);
            CGPDFPageRelease(page);
            CGPDFDocumentRelease (document);
            
            CGColorSpaceRelease(colorSpace);
            CGContextRelease(context);
            CGImageRelease(newImageRef);
            
            // Scale the image (183px is the standard height for the preview images)
            pdfImage = [pdfImage resizedImage:CGSizeMake(pdfImage.size.width/pdfImage.size.height * 183, 183) interpolationQuality:kCGInterpolationHigh];
            
            // Cache the image
            [UIImagePNGRepresentation(pdfImage) writeToFile:imagePath atomically:YES];
            
            return pdfImage;
        }
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
}

+ (UIImage *) imageFromMovie:(NSString *)moviePath {
    // Get from Cache or Generate the image
    NSArray *pathComponents = [moviePath pathComponents];
    NSString *imagePath = @"/";
    
    for (int i = 0; i < pathComponents.count-1; i++) {
        imagePath = [imagePath stringByAppendingFormat:@"/%@", pathComponents[i]];
    }
    imagePath = [imagePath stringByAppendingPathComponent:[NSString stringWithFormat:@".tmp-%@.png", pathComponents.lastObject]];
    
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        BOOL isDir;
        BOOL cacheImageExists = [fileMgr fileExistsAtPath:imagePath isDirectory:&isDir];
        
        if (cacheImageExists && !isDir) {
            NSDictionary *imageAttrs = [fileMgr attributesOfItemAtPath:imagePath error:nil];
            NSDictionary *movieAttrs = [fileMgr attributesOfItemAtPath:moviePath error:nil];
            if (imageAttrs != nil && movieAttrs != nil) {
                NSDate *imageModDate = (NSDate *)[imageAttrs objectForKey:NSFileModificationDate];
                NSDate *movieModDate = (NSDate *)[movieAttrs objectForKey:NSFileModificationDate];
                if (imageModDate != nil && movieModDate != nil) {
                    NSComparisonResult res = [movieModDate compare:imageModDate];
                    if (res != NSOrderedDescending) {
                        // Cached thumbnail is a later modification date
                        // than the movie file, so return the cached
                        // thumbnail.
                        return [UIImage imageWithContentsOfFile:imagePath];
                    }
                    // Movie file has a later modification date than
                    // the thumbnail cache.  Need to regenerate the
                    // thumbnail so fall through here.
                }
            }
        }
        
        UIImage *movieImage;
        NSURL *url = [[NSURL alloc] initFileURLWithPath:moviePath];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMakeWithSeconds(5, NSEC_PER_SEC);
        CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
        
        movieImage = [[UIImage alloc] initWithCGImage:imgRef];
        
        CGImageRelease(imgRef);
        
        movieImage = [movieImage resizedImage:CGSizeMake(238, 183) interpolationQuality:kCGInterpolationLow];
        
        // Cache the image
        [UIImagePNGRepresentation(movieImage) writeToFile:imagePath atomically:YES];
        
        return movieImage;
        
    }
    @finally {
        fileMgr = nil;
    }
}

+ (void) createDirForFile:(NSString *) filePath {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        [self createDirForFile:filePath withFileMgr:fileMgr];
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
}

+ (void) createDirForFile:(NSString *) filePath withFileMgr:(NSFileManager *)fileMgr {
    if (fileMgr) {
        NSError *error = nil;
        BOOL isDir = YES;
        
        // Make sure the parent/containing directory exists for the file
        NSArray *pathComponents = [filePath pathComponents];
        NSString *dirPath = @"/";
        
        for (int i = 0; i < [pathComponents count] - 1; i++) {
            dirPath = [dirPath stringByAppendingPathComponent:(NSString *) [pathComponents objectAtIndex:i]];
        }
        
        if (![fileMgr fileExistsAtPath:dirPath isDirectory:&isDir]) {
            [fileMgr createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
            
            if (error) {
                NSLog(@"%@", [error description]);
            }
        }
    }
}


#pragma mark - Cache Cleanup
+ (void) cleanFastPdfKitCache {
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDirectory = [paths objectAtIndex:0];
        NSString *pdfCachePath = [cachesDirectory stringByAppendingPathComponent:@"shared"];
        NSError *error = nil;
        BOOL isDir = YES;
        
        if ([fileMgr fileExistsAtPath:pdfCachePath isDirectory:&isDir]) {
            if (![fileMgr removeItemAtPath:pdfCachePath error:&error]) {
                NSLog(@"Error removing PDF cache directory:  %@", [error description]);
            }
        }
    }
    @finally {
        fileMgr = nil;
        fileMgr = nil;
    }
}

+ (void) clearCachedPreviewImage:(NSString *)path {
    // Get from Cache or Generate the image
    NSArray *pathComponents = [path pathComponents];
    NSString *imagePath = @"/";
    
    for (int i = 0; i < pathComponents.count-1; i++) {
        imagePath = [imagePath stringByAppendingFormat:@"/%@", pathComponents[i]];
    }
    imagePath = [imagePath stringByAppendingPathComponent:[NSString stringWithFormat:@".tmp-%@.png", pathComponents.lastObject]];
    
    NSFileManager *fileMgr;
    @try {
        fileMgr = [[NSFileManager alloc] init];
        BOOL isDir;
        BOOL cacheImageExists = [fileMgr fileExistsAtPath:imagePath isDirectory:&isDir];
        
        if (cacheImageExists && !isDir) {
            // Remove the file
            [fileMgr removeItemAtPath:imagePath error:nil];
        }
    }
    @finally {
        fileMgr = nil;
    }
}

+ (void) cleanContentVideos:(BOOL)cleanVideo andPresentations:(BOOL)cleanPresentations {
    
    if (cleanVideo == YES || cleanPresentations == YES) {

        //ContentSyncConfig *syncConfig = [[SFAppConfig sharedInstance] getContentSyncConfig];
        NSFileManager *fileMgr;
        @try {
            fileMgr = [[NSFileManager alloc] init];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDirectory = [paths objectAtIndex:0];
            
            ContentMetaData *metadata = [[ContentSyncManager sharedInstance] getAppContentMetaData];
            
            NSMutableArray *cleanFiles = [[NSMutableArray alloc] init];
            
            for (ContentItem *item in [metadata getFileItems]) {
                if (cleanVideo == YES &&
                    item.mustSync == NO &&
                    [self isMovieFile:item.path]) {
                    [cleanFiles addObject:[cachesDirectory stringByAppendingPathComponent:item.path]];
                }
                
                if (cleanPresentations == YES &&
                    item.mustSync == NO &&
                    [self isPresentationFile:item.path]) {
                    [cleanFiles addObject:[cachesDirectory stringByAppendingPathComponent:item.path]];
                }
            }
            
            NSError *error;
            for (NSString *fileToClean in cleanFiles) {
                NSLog(@"Cleaning suppressed file: %@", fileToClean);
                [fileMgr removeItemAtPath:fileToClean error:&error];
                if (error) {
                    NSLog(@"Error: %@ removing file: %@", error.localizedDescription, fileToClean);
                    error = nil;
                }
            }
        }
        @finally {
            fileMgr = nil;
        }
        
    }
}

@end

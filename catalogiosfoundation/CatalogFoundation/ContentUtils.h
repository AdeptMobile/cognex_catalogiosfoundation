//
//  ContentUtils.h
//  ToloApp
//
//  Created by Torey Lomenda on 6/7/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ContentMetaData.h"
#import "ZipArchive.h"

@interface ContentUtils : NSObject 

#pragma mark - Configuration Checks
+ (BOOL) isAppConfigured;
+ (void) setAppConfigured:(BOOL)configured;

#pragma mark - Username and Password Handling
+ (NSString *) getUsernameFromKeychain;
+ (void) setUsernameInKeychain:(NSString *)username;
+ (void) removeUsernameInKeychain;
+ (NSString *) getPasswordFromKeychain;
+ (void) setPasswordInKeychain:(NSString *)password;
+ (void) removePasswordInKeychain;

#pragma mark - User configuration settings for sync
+ (BOOL) isVideoSyncDisabled;
+ (void) setVideoSyncDisabled:(BOOL)disableVideoSync;
+ (BOOL) isPresentationSyncDisabled;
+ (void) setPresentationSyncDisabled:(BOOL)disablePresentationSync;

#pragma mark Content Structure
//+ (void) getAppContentStructureData;

#pragma mark Building Content MetaData
/*
+ (ContentMetaData *) getAppContentMetaData;
+ (ContentMetaData *) getWebContentMetaData;
*/

#pragma mark Content Locators
/*
+(void) createDirForFile: (NSString *) filePath;
+(void) createDirForFile: (NSString *) filePath withFileMgr: (NSFileManager *) fileMgr;
+(BOOL) fileExists: (NSString *) filePath withFileMgr: (NSFileManager *) fileMgr;

+(BOOL) contentDirExists;
+(void) setupContentDirectories;
*/

//+ (NSArray *) mainCategoryPaths;
//+ (NSString *) mainCategoryPath: (NSString *) catName;

+ (BOOL) fileExists: (NSString *) filePath;
+ (void) removeFile:(NSString *)filePath;
+ (NSArray *) subCategoryPaths:(NSString *) mainContentPath;

#pragma mark - Product Related content
+ (NSArray *) itemPaths:(NSString *) categoryPath;
+ (BOOL) isProductItemPath: (NSString *) contentPath;
+ (NSArray *) resourceItemsAtPath: (NSString *) resourceItemsPath;

+ (UIImage *) itemThumbnailImage: (NSString *) itemPath;
+ (UIImage *) itemDetailImage: (NSString *) itemPath;
+ (NSString *) itemThumbnailImagePath: (NSString *) itemPath;
+ (NSString *) itemDetailImagePath: (NSString *) itemPath;

#pragma mark -
#pragma mark Resource Item methods
+ (UIImage *) itemContentPreviewImage: (NSString *) itemContentItemPath;
//+ (NSURL *) itemContentDocURL: (NSString *) itemContentItemPath;
+ (BOOL) canOpenInApp: (NSURL *) docUrl;
+ (BOOL) isMovieFile: (NSString *) filePath;
+ (BOOL) isPDFFile: (NSString *) filePath;
+ (BOOL) isImageFile: (NSString *) filePath;
+ (BOOL) isCADFile: (NSString *) filePath;
+ (BOOL) isPresentationFile: (NSString *) filePath;

#pragma mark -
#pragma File Path Helpers
//+ (NSArray *) allFilePathsInDir: (NSString *) dirPath traverseDir: (BOOL) doTraverseDir withFileMgr: (NSFileManager *) fileMgr;;

+ (NSArray *) dirContentPathsAt: (NSString *) startPath withFileMgr: (NSFileManager *) fileMgr;
+ (NSString *) fileDirName: (NSString *) fileDirPath;
+ (NSString *) filePathForSymbolicLink: (NSString *) fullPathSymLink withFileMgr: (NSFileManager *) fileMgr;

+ (BOOL) isThumbnailOrPreview: (NSString *) path;
+ (void) createDirForFile:(NSString *) filePath;
+ (void) createDirForFile:(NSString *) filePath withFileMgr:(NSFileManager *)fileMgr;

#pragma Content Display Helpers
+ (BOOL) isSymbolicLink: (NSString *) path withFileMgr: (NSFileManager *) fileMgr;
+ (NSString *) labelForPath: (NSString *) path;
+ (UIImage *) imageFromPdf:(NSString *) pdfPath;
+ (UIImage *) imageFromMovie: (NSString *) moviePath;

#pragma mark - Cache Cleanup
+ (void) cleanFastPdfKitCache;
+ (void) clearCachedPreviewImage: (NSString *) path;

// When we suppress different types of content from downloading
// this routine should be called to remove existing types of
// files from the local device.
+ (void) cleanContentVideos:(BOOL)cleanVideo andPresentations:(BOOL)cleanPresentations;
@end

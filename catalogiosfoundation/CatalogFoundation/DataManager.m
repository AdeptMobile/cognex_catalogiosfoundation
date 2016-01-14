//
//  DataManager.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 3/15/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "DataManager.h"

NSString * const DataManagerDidSaveNotification = @"DataManagerDidSaveNotification";
NSString * const DataManagerDidSaveFailedNotification = @"DataManagerDidSaveFailedNotification";

@interface DataManager ()

- (NSString*)sharedDocumentsPath;

@end

@implementation DataManager

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize objectModel = _objectModel;
@synthesize SharedDocumentsPath;

NSString * const kDataManagerBundleName = @"CatalogFoundationResources";
NSString * const kDataManagerModelName = @"ContentStructure";
NSString * const kDataManagerSQLiteName = @"ContentStructure.sqlite";

+ (DataManager*)sharedInstance {
	static dispatch_once_t pred;
	static DataManager *sharedInstance = nil;
    
	dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
	return sharedInstance;
}

- (id) init {
    self = [super init];
    if (self) {
        SharedDocumentsPath = nil;
    }
    return self;
}

- (void)dealloc {
	[self save];
    
    
	
}

- (NSManagedObjectModel*)objectModel {
	if (_objectModel)
		return _objectModel;
    
	NSBundle *bundle = [NSBundle mainBundle];
	if (kDataManagerBundleName) {
		NSString *bundlePath = [[NSBundle mainBundle] pathForResource:kDataManagerBundleName ofType:@"bundle"];
        
        // TRL: Fix (Check to see that the bundle path exists first
        if (bundlePath) {
            bundle = [NSBundle bundleWithPath:bundlePath];
        }
	}
	NSString *modelPath = [bundle pathForResource:kDataManagerModelName ofType:@"momd"];
	_objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
    
	return _objectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
	if (_persistentStoreCoordinator)
		return _persistentStoreCoordinator;
    
	// Get the paths to the SQLite file
	NSString *storePath = [[self sharedDocumentsPath] stringByAppendingPathComponent:kDataManagerSQLiteName];
	NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
	// Define the Core Data version migration options
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    
	// Attempt to load the persistent store
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objectModel];
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
		NSLog(@"Fatal error while creating persistent store: %@", error);
		abort();
	}
    
	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext*)mainObjectContext {
	if (_mainObjectContext)
		return _mainObjectContext;
    
	// Create the main context only on the main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(mainObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
		return _mainObjectContext;
	}
    
	_mainObjectContext = [[NSManagedObjectContext alloc] init];
	[_mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return _mainObjectContext;
}

- (BOOL)save {
	if (![self.mainObjectContext hasChanges])
		return YES;
    
	NSError *error = nil;
	if (![self.mainObjectContext save:&error]) {
		NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);
		[[NSNotificationCenter defaultCenter] postNotificationName:DataManagerDidSaveFailedNotification
                                                            object:error];
		return NO;
	}
    
	[[NSNotificationCenter defaultCenter] postNotificationName:DataManagerDidSaveNotification object:nil];
	return YES;
}

- (NSString*)sharedDocumentsPath {
	if (SharedDocumentsPath)
		return SharedDocumentsPath;
    
	// Compose a path to the <Library>/Database directory
	NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	SharedDocumentsPath = [libraryPath stringByAppendingPathComponent:@"Database"];
    
	// Ensure the database directory exists
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL isDirectory;
	if (![manager fileExistsAtPath:SharedDocumentsPath isDirectory:&isDirectory] || !isDirectory) {
		NSError *error = nil;
		NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
		[manager createDirectoryAtPath:SharedDocumentsPath
		   withIntermediateDirectories:YES
                            attributes:attr
                                 error:&error];
		if (error)
			NSLog(@"Error creating directory path: %@", [error localizedDescription]);
	}
    
	return SharedDocumentsPath;
}

- (NSManagedObjectContext*)managedObjectContext {
	NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init];
	[ctx setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return ctx;
}

// NOTE:  This assumes you have only ONE persistent store!!!!!! 
- (void)reset {
    NSError *error;
    NSManagedObjectContext *managedObjectContext = [self mainObjectContext];
    NSPersistentStoreCoordinator *storeCoordinator = [self persistentStoreCoordinator];
    
    NSURL *storeURL = [storeCoordinator URLForPersistentStore:[[storeCoordinator persistentStores] lastObject]];
    
    // Lock the context.
    [managedObjectContext lock];
    // This drops any pending changes.
    [managedObjectContext reset];
    
    if ([storeCoordinator removePersistentStore:[[storeCoordinator persistentStores] lastObject] error:&error]) {
        // Remove the file containing our data.
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        
        // Recreate the store.
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                 nil];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:storeURL
                                                             options:options
                                                               error:&error]) {
            NSLog(@"Fatal error while creating persistent store: %@", error);
            abort();
        }
    }
    
    // Unlock the context and we should be good to go.
    [managedObjectContext unlock];
    
}

@end

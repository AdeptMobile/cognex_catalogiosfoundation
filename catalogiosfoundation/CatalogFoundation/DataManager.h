//
//  DataManager.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 3/15/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const DataManagerDidSaveNotification;
extern NSString * const DataManagerDidSaveFailedNotification;

@interface DataManager : NSObject {
    NSString *SharedDocumentsPath;
}

@property (nonatomic, readonly, strong) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, strong) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly, strong) NSString *SharedDocumentsPath;

+ (DataManager*)sharedInstance;
- (BOOL)save;
- (NSManagedObjectContext*)managedObjectContext;
- (void)reset;

@end

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ResourceItem.h instead.

#import <CoreData/CoreData.h>


extern const struct ResourceItemAttributes {
	__unsafe_unretained NSString *contentPath;
	__unsafe_unretained NSString *displayOrder;
	__unsafe_unretained NSString *infoText;
	__unsafe_unretained NSString *remotePath;
	__unsafe_unretained NSString *resourceItemId;
	__unsafe_unretained NSString *resourceType;
	__unsafe_unretained NSString *startPage;
	__unsafe_unretained NSString *thumbNail;
	__unsafe_unretained NSString *title;
} ResourceItemAttributes;

extern const struct ResourceItemRelationships {
	__unsafe_unretained NSString *gallery;
	__unsafe_unretained NSString *resource;
} ResourceItemRelationships;

extern const struct ResourceItemFetchedProperties {
} ResourceItemFetchedProperties;

@class Gallery;
@class Resource;











@interface ResourceItemID : NSManagedObjectID {}
@end

@interface _ResourceItem : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ResourceItemID*)objectID;





@property (nonatomic, strong) NSString* contentPath;



//- (BOOL)validateContentPath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDecimalNumber* displayOrder;



//- (BOOL)validateDisplayOrder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* infoText;



//- (BOOL)validateInfoText:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* remotePath;



//- (BOOL)validateRemotePath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* resourceItemId;



//- (BOOL)validateResourceItemId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* resourceType;



//- (BOOL)validateResourceType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDecimalNumber* startPage;



//- (BOOL)validateStartPage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbNail;



//- (BOOL)validateThumbNail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Gallery *gallery;

//- (BOOL)validateGallery:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Resource *resource;

//- (BOOL)validateResource:(id*)value_ error:(NSError**)error_;





@end

@interface _ResourceItem (CoreDataGeneratedAccessors)

@end

@interface _ResourceItem (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveContentPath;
- (void)setPrimitiveContentPath:(NSString*)value;




- (NSDecimalNumber*)primitiveDisplayOrder;
- (void)setPrimitiveDisplayOrder:(NSDecimalNumber*)value;




- (NSString*)primitiveInfoText;
- (void)setPrimitiveInfoText:(NSString*)value;




- (NSString*)primitiveRemotePath;
- (void)setPrimitiveRemotePath:(NSString*)value;




- (NSString*)primitiveResourceItemId;
- (void)setPrimitiveResourceItemId:(NSString*)value;




- (NSString*)primitiveResourceType;
- (void)setPrimitiveResourceType:(NSString*)value;




- (NSDecimalNumber*)primitiveStartPage;
- (void)setPrimitiveStartPage:(NSDecimalNumber*)value;




- (NSString*)primitiveThumbNail;
- (void)setPrimitiveThumbNail:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (Gallery*)primitiveGallery;
- (void)setPrimitiveGallery:(Gallery*)value;



- (Resource*)primitiveResource;
- (void)setPrimitiveResource:(Resource*)value;


@end

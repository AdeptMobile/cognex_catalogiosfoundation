// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Gallery.h instead.

#import <CoreData/CoreData.h>


extern const struct GalleryAttributes {
	__unsafe_unretained NSString *displayOrder;
	__unsafe_unretained NSString *galleryId;
	__unsafe_unretained NSString *infoText;
	__unsafe_unretained NSString *thumbNail;
	__unsafe_unretained NSString *title;
} GalleryAttributes;

extern const struct GalleryRelationships {
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *resourceItems;
	__unsafe_unretained NSString *tags;
} GalleryRelationships;

extern const struct GalleryFetchedProperties {
} GalleryFetchedProperties;

@class SFCategory;
@class ResourceItem;
@class Tag;







@interface GalleryID : NSManagedObjectID {}
@end

@interface _Gallery : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (GalleryID*)objectID;





@property (nonatomic, strong) NSDecimalNumber* displayOrder;



//- (BOOL)validateDisplayOrder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* galleryId;



//- (BOOL)validateGalleryId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* infoText;



//- (BOOL)validateInfoText:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbNail;



//- (BOOL)validateThumbNail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) SFCategory *category;

//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *resourceItems;

- (NSMutableSet*)resourceItemsSet;




@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;





@end

@interface _Gallery (CoreDataGeneratedAccessors)

- (void)addResourceItems:(NSSet*)value_;
- (void)removeResourceItems:(NSSet*)value_;
- (void)addResourceItemsObject:(ResourceItem*)value_;
- (void)removeResourceItemsObject:(ResourceItem*)value_;

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(Tag*)value_;
- (void)removeTagsObject:(Tag*)value_;

@end

@interface _Gallery (CoreDataGeneratedPrimitiveAccessors)


- (NSDecimalNumber*)primitiveDisplayOrder;
- (void)setPrimitiveDisplayOrder:(NSDecimalNumber*)value;




- (NSString*)primitiveGalleryId;
- (void)setPrimitiveGalleryId:(NSString*)value;




- (NSString*)primitiveInfoText;
- (void)setPrimitiveInfoText:(NSString*)value;




- (NSString*)primitiveThumbNail;
- (void)setPrimitiveThumbNail:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (SFCategory*)primitiveCategory;
- (void)setPrimitiveCategory:(SFCategory*)value;



- (NSMutableSet*)primitiveResourceItems;
- (void)setPrimitiveResourceItems:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;


@end

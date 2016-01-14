// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Product.h instead.

#import <CoreData/CoreData.h>


extern const struct ProductAttributes {
	__unsafe_unretained NSString *displayOrder;
	__unsafe_unretained NSString *infoText;
	__unsafe_unretained NSString *productId;
	__unsafe_unretained NSString *thumbNail;
	__unsafe_unretained NSString *title;
} ProductAttributes;

extern const struct ProductRelationships {
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *images;
	__unsafe_unretained NSString *resources;
	__unsafe_unretained NSString *tags;
} ProductRelationships;

extern const struct ProductFetchedProperties {
} ProductFetchedProperties;

@class SFCategory;
@class Image;
@class Resource;
@class Tag;







@interface ProductID : NSManagedObjectID {}
@end

@interface _Product : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ProductID*)objectID;





@property (nonatomic, strong) NSDecimalNumber* displayOrder;



//- (BOOL)validateDisplayOrder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* infoText;



//- (BOOL)validateInfoText:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* productId;



//- (BOOL)validateProductId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbNail;



//- (BOOL)validateThumbNail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) SFCategory *category;

//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *images;

- (NSMutableSet*)imagesSet;




@property (nonatomic, strong) NSSet *resources;

- (NSMutableSet*)resourcesSet;




@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;





@end

@interface _Product (CoreDataGeneratedAccessors)

- (void)addImages:(NSSet*)value_;
- (void)removeImages:(NSSet*)value_;
- (void)addImagesObject:(Image*)value_;
- (void)removeImagesObject:(Image*)value_;

- (void)addResources:(NSSet*)value_;
- (void)removeResources:(NSSet*)value_;
- (void)addResourcesObject:(Resource*)value_;
- (void)removeResourcesObject:(Resource*)value_;

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(Tag*)value_;
- (void)removeTagsObject:(Tag*)value_;

@end

@interface _Product (CoreDataGeneratedPrimitiveAccessors)


- (NSDecimalNumber*)primitiveDisplayOrder;
- (void)setPrimitiveDisplayOrder:(NSDecimalNumber*)value;




- (NSString*)primitiveInfoText;
- (void)setPrimitiveInfoText:(NSString*)value;




- (NSString*)primitiveProductId;
- (void)setPrimitiveProductId:(NSString*)value;




- (NSString*)primitiveThumbNail;
- (void)setPrimitiveThumbNail:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (SFCategory*)primitiveCategory;
- (void)setPrimitiveCategory:(SFCategory*)value;



- (NSMutableSet*)primitiveImages;
- (void)setPrimitiveImages:(NSMutableSet*)value;



- (NSMutableSet*)primitiveResources;
- (void)setPrimitiveResources:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;


@end

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Industry.h instead.

#import <CoreData/CoreData.h>


extern const struct IndustryAttributes {
	__unsafe_unretained NSString *displayOrder;
	__unsafe_unretained NSString *industryId;
	__unsafe_unretained NSString *infoText;
	__unsafe_unretained NSString *thumbNail;
	__unsafe_unretained NSString *title;
} IndustryAttributes;

extern const struct IndustryRelationships {
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *images;
	__unsafe_unretained NSString *industryProducts;
	__unsafe_unretained NSString *resources;
	__unsafe_unretained NSString *tags;
} IndustryRelationships;

extern const struct IndustryFetchedProperties {
} IndustryFetchedProperties;

@class SFCategory;
@class Image;
@class IndustryProduct;
@class Resource;
@class Tag;







@interface IndustryID : NSManagedObjectID {}
@end

@interface _Industry : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (IndustryID*)objectID;





@property (nonatomic, strong) NSDecimalNumber* displayOrder;



//- (BOOL)validateDisplayOrder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* industryId;



//- (BOOL)validateIndustryId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* infoText;



//- (BOOL)validateInfoText:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbNail;



//- (BOOL)validateThumbNail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) SFCategory *category;

//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *images;

- (NSMutableSet*)imagesSet;




@property (nonatomic, strong) NSSet *industryProducts;

- (NSMutableSet*)industryProductsSet;




@property (nonatomic, strong) NSSet *resources;

- (NSMutableSet*)resourcesSet;




@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;





@end

@interface _Industry (CoreDataGeneratedAccessors)

- (void)addImages:(NSSet*)value_;
- (void)removeImages:(NSSet*)value_;
- (void)addImagesObject:(Image*)value_;
- (void)removeImagesObject:(Image*)value_;

- (void)addIndustryProducts:(NSSet*)value_;
- (void)removeIndustryProducts:(NSSet*)value_;
- (void)addIndustryProductsObject:(IndustryProduct*)value_;
- (void)removeIndustryProductsObject:(IndustryProduct*)value_;

- (void)addResources:(NSSet*)value_;
- (void)removeResources:(NSSet*)value_;
- (void)addResourcesObject:(Resource*)value_;
- (void)removeResourcesObject:(Resource*)value_;

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(Tag*)value_;
- (void)removeTagsObject:(Tag*)value_;

@end

@interface _Industry (CoreDataGeneratedPrimitiveAccessors)


- (NSDecimalNumber*)primitiveDisplayOrder;
- (void)setPrimitiveDisplayOrder:(NSDecimalNumber*)value;




- (NSString*)primitiveIndustryId;
- (void)setPrimitiveIndustryId:(NSString*)value;




- (NSString*)primitiveInfoText;
- (void)setPrimitiveInfoText:(NSString*)value;




- (NSString*)primitiveThumbNail;
- (void)setPrimitiveThumbNail:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (SFCategory*)primitiveCategory;
- (void)setPrimitiveCategory:(SFCategory*)value;



- (NSMutableSet*)primitiveImages;
- (void)setPrimitiveImages:(NSMutableSet*)value;



- (NSMutableSet*)primitiveIndustryProducts;
- (void)setPrimitiveIndustryProducts:(NSMutableSet*)value;



- (NSMutableSet*)primitiveResources;
- (void)setPrimitiveResources:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;


@end

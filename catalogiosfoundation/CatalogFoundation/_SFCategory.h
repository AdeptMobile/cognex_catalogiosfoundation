// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SFCategory.h instead.

#import <CoreData/CoreData.h>


extern const struct SFCategoryAttributes {
	__unsafe_unretained NSString *categoryId;
	__unsafe_unretained NSString *displayOrder;
	__unsafe_unretained NSString *thumbNail;
	__unsafe_unretained NSString *title;
} SFCategoryAttributes;

extern const struct SFCategoryRelationships {
	__unsafe_unretained NSString *catalog;
	__unsafe_unretained NSString *categories;
	__unsafe_unretained NSString *galleries;
	__unsafe_unretained NSString *images;
	__unsafe_unretained NSString *industries;
	__unsafe_unretained NSString *parentCategory;
	__unsafe_unretained NSString *products;
	__unsafe_unretained NSString *tags;
} SFCategoryRelationships;

extern const struct SFCategoryFetchedProperties {
} SFCategoryFetchedProperties;

@class Catalog;
@class SFCategory;
@class Gallery;
@class Image;
@class Industry;
@class SFCategory;
@class Product;
@class Tag;






@interface SFCategoryID : NSManagedObjectID {}
@end

@interface _SFCategory : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SFCategoryID*)objectID;





@property (nonatomic, strong) NSString* categoryId;



//- (BOOL)validateCategoryId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDecimalNumber* displayOrder;



//- (BOOL)validateDisplayOrder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbNail;



//- (BOOL)validateThumbNail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Catalog *catalog;

//- (BOOL)validateCatalog:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *categories;

- (NSMutableSet*)categoriesSet;




@property (nonatomic, strong) NSSet *galleries;

- (NSMutableSet*)galleriesSet;




@property (nonatomic, strong) NSSet *images;

- (NSMutableSet*)imagesSet;




@property (nonatomic, strong) NSSet *industries;

- (NSMutableSet*)industriesSet;




@property (nonatomic, strong) SFCategory *parentCategory;

//- (BOOL)validateParentCategory:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *products;

- (NSMutableSet*)productsSet;




@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;





@end

@interface _SFCategory (CoreDataGeneratedAccessors)

- (void)addCategories:(NSSet*)value_;
- (void)removeCategories:(NSSet*)value_;
- (void)addCategoriesObject:(SFCategory*)value_;
- (void)removeCategoriesObject:(SFCategory*)value_;

- (void)addGalleries:(NSSet*)value_;
- (void)removeGalleries:(NSSet*)value_;
- (void)addGalleriesObject:(Gallery*)value_;
- (void)removeGalleriesObject:(Gallery*)value_;

- (void)addImages:(NSSet*)value_;
- (void)removeImages:(NSSet*)value_;
- (void)addImagesObject:(Image*)value_;
- (void)removeImagesObject:(Image*)value_;

- (void)addIndustries:(NSSet*)value_;
- (void)removeIndustries:(NSSet*)value_;
- (void)addIndustriesObject:(Industry*)value_;
- (void)removeIndustriesObject:(Industry*)value_;

- (void)addProducts:(NSSet*)value_;
- (void)removeProducts:(NSSet*)value_;
- (void)addProductsObject:(Product*)value_;
- (void)removeProductsObject:(Product*)value_;

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(Tag*)value_;
- (void)removeTagsObject:(Tag*)value_;

@end

@interface _SFCategory (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCategoryId;
- (void)setPrimitiveCategoryId:(NSString*)value;




- (NSDecimalNumber*)primitiveDisplayOrder;
- (void)setPrimitiveDisplayOrder:(NSDecimalNumber*)value;




- (NSString*)primitiveThumbNail;
- (void)setPrimitiveThumbNail:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (Catalog*)primitiveCatalog;
- (void)setPrimitiveCatalog:(Catalog*)value;



- (NSMutableSet*)primitiveCategories;
- (void)setPrimitiveCategories:(NSMutableSet*)value;



- (NSMutableSet*)primitiveGalleries;
- (void)setPrimitiveGalleries:(NSMutableSet*)value;



- (NSMutableSet*)primitiveImages;
- (void)setPrimitiveImages:(NSMutableSet*)value;



- (NSMutableSet*)primitiveIndustries;
- (void)setPrimitiveIndustries:(NSMutableSet*)value;



- (SFCategory*)primitiveParentCategory;
- (void)setPrimitiveParentCategory:(SFCategory*)value;



- (NSMutableSet*)primitiveProducts;
- (void)setPrimitiveProducts:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;


@end

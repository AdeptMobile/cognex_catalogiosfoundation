// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Tag.h instead.

#import <CoreData/CoreData.h>


extern const struct TagAttributes {
	__unsafe_unretained NSString *tag;
} TagAttributes;

extern const struct TagRelationships {
	__unsafe_unretained NSString *catalogs;
	__unsafe_unretained NSString *categories;
	__unsafe_unretained NSString *galleries;
	__unsafe_unretained NSString *industries;
	__unsafe_unretained NSString *products;
} TagRelationships;

extern const struct TagFetchedProperties {
} TagFetchedProperties;

@class Catalog;
@class SFCategory;
@class Gallery;
@class Industry;
@class Product;



@interface TagID : NSManagedObjectID {}
@end

@interface _Tag : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TagID*)objectID;





@property (nonatomic, strong) NSString* tag;



//- (BOOL)validateTag:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *catalogs;

- (NSMutableSet*)catalogsSet;




@property (nonatomic, strong) NSSet *categories;

- (NSMutableSet*)categoriesSet;




@property (nonatomic, strong) NSSet *galleries;

- (NSMutableSet*)galleriesSet;




@property (nonatomic, strong) NSSet *industries;

- (NSMutableSet*)industriesSet;




@property (nonatomic, strong) NSSet *products;

- (NSMutableSet*)productsSet;





@end

@interface _Tag (CoreDataGeneratedAccessors)

- (void)addCatalogs:(NSSet*)value_;
- (void)removeCatalogs:(NSSet*)value_;
- (void)addCatalogsObject:(Catalog*)value_;
- (void)removeCatalogsObject:(Catalog*)value_;

- (void)addCategories:(NSSet*)value_;
- (void)removeCategories:(NSSet*)value_;
- (void)addCategoriesObject:(SFCategory*)value_;
- (void)removeCategoriesObject:(SFCategory*)value_;

- (void)addGalleries:(NSSet*)value_;
- (void)removeGalleries:(NSSet*)value_;
- (void)addGalleriesObject:(Gallery*)value_;
- (void)removeGalleriesObject:(Gallery*)value_;

- (void)addIndustries:(NSSet*)value_;
- (void)removeIndustries:(NSSet*)value_;
- (void)addIndustriesObject:(Industry*)value_;
- (void)removeIndustriesObject:(Industry*)value_;

- (void)addProducts:(NSSet*)value_;
- (void)removeProducts:(NSSet*)value_;
- (void)addProductsObject:(Product*)value_;
- (void)removeProductsObject:(Product*)value_;

@end

@interface _Tag (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveTag;
- (void)setPrimitiveTag:(NSString*)value;





- (NSMutableSet*)primitiveCatalogs;
- (void)setPrimitiveCatalogs:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCategories;
- (void)setPrimitiveCategories:(NSMutableSet*)value;



- (NSMutableSet*)primitiveGalleries;
- (void)setPrimitiveGalleries:(NSMutableSet*)value;



- (NSMutableSet*)primitiveIndustries;
- (void)setPrimitiveIndustries:(NSMutableSet*)value;



- (NSMutableSet*)primitiveProducts;
- (void)setPrimitiveProducts:(NSMutableSet*)value;


@end

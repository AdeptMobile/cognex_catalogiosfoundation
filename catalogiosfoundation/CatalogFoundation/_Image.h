// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Image.h instead.

#import <CoreData/CoreData.h>


extern const struct ImageAttributes {
	__unsafe_unretained NSString *imagePath;
} ImageAttributes;

extern const struct ImageRelationships {
	__unsafe_unretained NSString *catalogs;
	__unsafe_unretained NSString *categories;
	__unsafe_unretained NSString *industries;
	__unsafe_unretained NSString *infoPanels;
	__unsafe_unretained NSString *products;
} ImageRelationships;

extern const struct ImageFetchedProperties {
} ImageFetchedProperties;

@class Catalog;
@class SFCategory;
@class Industry;
@class InfoPanel;
@class Product;



@interface ImageID : NSManagedObjectID {}
@end

@interface _Image : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ImageID*)objectID;





@property (nonatomic, strong) NSString* imagePath;



//- (BOOL)validateImagePath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *catalogs;

- (NSMutableSet*)catalogsSet;




@property (nonatomic, strong) NSSet *categories;

- (NSMutableSet*)categoriesSet;




@property (nonatomic, strong) NSSet *industries;

- (NSMutableSet*)industriesSet;




@property (nonatomic, strong) NSSet *infoPanels;

- (NSMutableSet*)infoPanelsSet;




@property (nonatomic, strong) NSSet *products;

- (NSMutableSet*)productsSet;





@end

@interface _Image (CoreDataGeneratedAccessors)

- (void)addCatalogs:(NSSet*)value_;
- (void)removeCatalogs:(NSSet*)value_;
- (void)addCatalogsObject:(Catalog*)value_;
- (void)removeCatalogsObject:(Catalog*)value_;

- (void)addCategories:(NSSet*)value_;
- (void)removeCategories:(NSSet*)value_;
- (void)addCategoriesObject:(SFCategory*)value_;
- (void)removeCategoriesObject:(SFCategory*)value_;

- (void)addIndustries:(NSSet*)value_;
- (void)removeIndustries:(NSSet*)value_;
- (void)addIndustriesObject:(Industry*)value_;
- (void)removeIndustriesObject:(Industry*)value_;

- (void)addInfoPanels:(NSSet*)value_;
- (void)removeInfoPanels:(NSSet*)value_;
- (void)addInfoPanelsObject:(InfoPanel*)value_;
- (void)removeInfoPanelsObject:(InfoPanel*)value_;

- (void)addProducts:(NSSet*)value_;
- (void)removeProducts:(NSSet*)value_;
- (void)addProductsObject:(Product*)value_;
- (void)removeProductsObject:(Product*)value_;

@end

@interface _Image (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveImagePath;
- (void)setPrimitiveImagePath:(NSString*)value;





- (NSMutableSet*)primitiveCatalogs;
- (void)setPrimitiveCatalogs:(NSMutableSet*)value;



- (NSMutableSet*)primitiveCategories;
- (void)setPrimitiveCategories:(NSMutableSet*)value;



- (NSMutableSet*)primitiveIndustries;
- (void)setPrimitiveIndustries:(NSMutableSet*)value;



- (NSMutableSet*)primitiveInfoPanels;
- (void)setPrimitiveInfoPanels:(NSMutableSet*)value;



- (NSMutableSet*)primitiveProducts;
- (void)setPrimitiveProducts:(NSMutableSet*)value;


@end

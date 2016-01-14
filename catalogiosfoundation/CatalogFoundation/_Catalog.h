// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Catalog.h instead.

#import <CoreData/CoreData.h>


extern const struct CatalogAttributes {
	__unsafe_unretained NSString *catalogId;
	__unsafe_unretained NSString *thumbNail;
	__unsafe_unretained NSString *title;
} CatalogAttributes;

extern const struct CatalogRelationships {
	__unsafe_unretained NSString *categories;
	__unsafe_unretained NSString *images;
	__unsafe_unretained NSString *infoPanels;
	__unsafe_unretained NSString *tags;
} CatalogRelationships;

extern const struct CatalogFetchedProperties {
} CatalogFetchedProperties;

@class SFCategory;
@class Image;
@class InfoPanel;
@class Tag;





@interface CatalogID : NSManagedObjectID {}
@end

@interface _Catalog : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CatalogID*)objectID;





@property (nonatomic, strong) NSString* catalogId;



//- (BOOL)validateCatalogId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbNail;



//- (BOOL)validateThumbNail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *categories;

- (NSMutableSet*)categoriesSet;




@property (nonatomic, strong) NSSet *images;

- (NSMutableSet*)imagesSet;




@property (nonatomic, strong) NSSet *infoPanels;

- (NSMutableSet*)infoPanelsSet;




@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;





@end

@interface _Catalog (CoreDataGeneratedAccessors)

- (void)addCategories:(NSSet*)value_;
- (void)removeCategories:(NSSet*)value_;
- (void)addCategoriesObject:(SFCategory*)value_;
- (void)removeCategoriesObject:(SFCategory*)value_;

- (void)addImages:(NSSet*)value_;
- (void)removeImages:(NSSet*)value_;
- (void)addImagesObject:(Image*)value_;
- (void)removeImagesObject:(Image*)value_;

- (void)addInfoPanels:(NSSet*)value_;
- (void)removeInfoPanels:(NSSet*)value_;
- (void)addInfoPanelsObject:(InfoPanel*)value_;
- (void)removeInfoPanelsObject:(InfoPanel*)value_;

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(Tag*)value_;
- (void)removeTagsObject:(Tag*)value_;

@end

@interface _Catalog (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCatalogId;
- (void)setPrimitiveCatalogId:(NSString*)value;




- (NSString*)primitiveThumbNail;
- (void)setPrimitiveThumbNail:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (NSMutableSet*)primitiveCategories;
- (void)setPrimitiveCategories:(NSMutableSet*)value;



- (NSMutableSet*)primitiveImages;
- (void)setPrimitiveImages:(NSMutableSet*)value;



- (NSMutableSet*)primitiveInfoPanels;
- (void)setPrimitiveInfoPanels:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;


@end

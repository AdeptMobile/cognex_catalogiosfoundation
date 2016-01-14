// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Resource.h instead.

#import <CoreData/CoreData.h>


extern const struct ResourceAttributes {
	__unsafe_unretained NSString *displayOrder;
	__unsafe_unretained NSString *resourceId;
	__unsafe_unretained NSString *title;
} ResourceAttributes;

extern const struct ResourceRelationships {
	__unsafe_unretained NSString *industry;
	__unsafe_unretained NSString *product;
	__unsafe_unretained NSString *resourceItems;
} ResourceRelationships;

extern const struct ResourceFetchedProperties {
} ResourceFetchedProperties;

@class Industry;
@class Product;
@class ResourceItem;





@interface ResourceID : NSManagedObjectID {}
@end

@interface _Resource : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ResourceID*)objectID;





@property (nonatomic, strong) NSDecimalNumber* displayOrder;



//- (BOOL)validateDisplayOrder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* resourceId;



//- (BOOL)validateResourceId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Industry *industry;

//- (BOOL)validateIndustry:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Product *product;

//- (BOOL)validateProduct:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *resourceItems;

- (NSMutableSet*)resourceItemsSet;





@end

@interface _Resource (CoreDataGeneratedAccessors)

- (void)addResourceItems:(NSSet*)value_;
- (void)removeResourceItems:(NSSet*)value_;
- (void)addResourceItemsObject:(ResourceItem*)value_;
- (void)removeResourceItemsObject:(ResourceItem*)value_;

@end

@interface _Resource (CoreDataGeneratedPrimitiveAccessors)


- (NSDecimalNumber*)primitiveDisplayOrder;
- (void)setPrimitiveDisplayOrder:(NSDecimalNumber*)value;




- (NSString*)primitiveResourceId;
- (void)setPrimitiveResourceId:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (Industry*)primitiveIndustry;
- (void)setPrimitiveIndustry:(Industry*)value;



- (Product*)primitiveProduct;
- (void)setPrimitiveProduct:(Product*)value;



- (NSMutableSet*)primitiveResourceItems;
- (void)setPrimitiveResourceItems:(NSMutableSet*)value;


@end

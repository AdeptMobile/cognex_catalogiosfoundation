// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IndustryProduct.h instead.

#import <CoreData/CoreData.h>


extern const struct IndustryProductAttributes {
	__unsafe_unretained NSString *productId;
	__unsafe_unretained NSString *thumbNail;
	__unsafe_unretained NSString *title;
} IndustryProductAttributes;

extern const struct IndustryProductRelationships {
	__unsafe_unretained NSString *industry;
} IndustryProductRelationships;

extern const struct IndustryProductFetchedProperties {
} IndustryProductFetchedProperties;

@class Industry;





@interface IndustryProductID : NSManagedObjectID {}
@end

@interface _IndustryProduct : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (IndustryProductID*)objectID;





@property (nonatomic, strong) NSString* productId;



//- (BOOL)validateProductId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbNail;



//- (BOOL)validateThumbNail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Industry *industry;

//- (BOOL)validateIndustry:(id*)value_ error:(NSError**)error_;





@end

@interface _IndustryProduct (CoreDataGeneratedAccessors)

@end

@interface _IndustryProduct (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveProductId;
- (void)setPrimitiveProductId:(NSString*)value;




- (NSString*)primitiveThumbNail;
- (void)setPrimitiveThumbNail:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (Industry*)primitiveIndustry;
- (void)setPrimitiveIndustry:(Industry*)value;


@end

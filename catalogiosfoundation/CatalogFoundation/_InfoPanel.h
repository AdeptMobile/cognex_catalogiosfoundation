// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InfoPanel.h instead.

#import <CoreData/CoreData.h>


extern const struct InfoPanelAttributes {
	__unsafe_unretained NSString *contentPath;
	__unsafe_unretained NSString *displayOrder;
	__unsafe_unretained NSString *panelId;
	__unsafe_unretained NSString *title;
} InfoPanelAttributes;

extern const struct InfoPanelRelationships {
	__unsafe_unretained NSString *catalog;
	__unsafe_unretained NSString *images;
} InfoPanelRelationships;

extern const struct InfoPanelFetchedProperties {
} InfoPanelFetchedProperties;

@class Catalog;
@class Image;






@interface InfoPanelID : NSManagedObjectID {}
@end

@interface _InfoPanel : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (InfoPanelID*)objectID;





@property (nonatomic, strong) NSString* contentPath;



//- (BOOL)validateContentPath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDecimalNumber* displayOrder;



//- (BOOL)validateDisplayOrder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* panelId;



//- (BOOL)validatePanelId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Catalog *catalog;

//- (BOOL)validateCatalog:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *images;

- (NSMutableSet*)imagesSet;





@end

@interface _InfoPanel (CoreDataGeneratedAccessors)

- (void)addImages:(NSSet*)value_;
- (void)removeImages:(NSSet*)value_;
- (void)addImagesObject:(Image*)value_;
- (void)removeImagesObject:(Image*)value_;

@end

@interface _InfoPanel (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveContentPath;
- (void)setPrimitiveContentPath:(NSString*)value;




- (NSDecimalNumber*)primitiveDisplayOrder;
- (void)setPrimitiveDisplayOrder:(NSDecimalNumber*)value;




- (NSString*)primitivePanelId;
- (void)setPrimitivePanelId:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (Catalog*)primitiveCatalog;
- (void)setPrimitiveCatalog:(Catalog*)value;



- (NSMutableSet*)primitiveImages;
- (void)setPrimitiveImages:(NSMutableSet*)value;


@end

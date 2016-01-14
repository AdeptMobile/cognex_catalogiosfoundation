// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Catalog.m instead.

#import "_Catalog.h"

const struct CatalogAttributes CatalogAttributes = {
	.catalogId = @"catalogId",
	.thumbNail = @"thumbNail",
	.title = @"title",
};

const struct CatalogRelationships CatalogRelationships = {
	.categories = @"categories",
	.images = @"images",
	.infoPanels = @"infoPanels",
	.tags = @"tags",
};

const struct CatalogFetchedProperties CatalogFetchedProperties = {
};

@implementation CatalogID
@end

@implementation _Catalog

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Catalog" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Catalog";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Catalog" inManagedObjectContext:moc_];
}

- (CatalogID*)objectID {
	return (CatalogID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic catalogId;






@dynamic thumbNail;






@dynamic title;






@dynamic categories;

	
- (NSMutableSet*)categoriesSet {
	[self willAccessValueForKey:@"categories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"categories"];
  
	[self didAccessValueForKey:@"categories"];
	return result;
}
	

@dynamic images;

	
- (NSMutableSet*)imagesSet {
	[self willAccessValueForKey:@"images"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"images"];
  
	[self didAccessValueForKey:@"images"];
	return result;
}
	

@dynamic infoPanels;

	
- (NSMutableSet*)infoPanelsSet {
	[self willAccessValueForKey:@"infoPanels"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"infoPanels"];
  
	[self didAccessValueForKey:@"infoPanels"];
	return result;
}
	

@dynamic tags;

	
- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];
  
	[self didAccessValueForKey:@"tags"];
	return result;
}
	






@end

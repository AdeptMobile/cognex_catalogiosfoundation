// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Product.m instead.

#import "_Product.h"

const struct ProductAttributes ProductAttributes = {
	.displayOrder = @"displayOrder",
	.infoText = @"infoText",
	.productId = @"productId",
	.thumbNail = @"thumbNail",
	.title = @"title",
};

const struct ProductRelationships ProductRelationships = {
	.category = @"category",
	.images = @"images",
	.resources = @"resources",
	.tags = @"tags",
};

const struct ProductFetchedProperties ProductFetchedProperties = {
};

@implementation ProductID
@end

@implementation _Product

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Product";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Product" inManagedObjectContext:moc_];
}

- (ProductID*)objectID {
	return (ProductID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic displayOrder;






@dynamic infoText;






@dynamic productId;






@dynamic thumbNail;






@dynamic title;






@dynamic category;

	

@dynamic images;

	
- (NSMutableSet*)imagesSet {
	[self willAccessValueForKey:@"images"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"images"];
  
	[self didAccessValueForKey:@"images"];
	return result;
}
	

@dynamic resources;

	
- (NSMutableSet*)resourcesSet {
	[self willAccessValueForKey:@"resources"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"resources"];
  
	[self didAccessValueForKey:@"resources"];
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

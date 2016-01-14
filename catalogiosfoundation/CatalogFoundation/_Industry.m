// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Industry.m instead.

#import "_Industry.h"

const struct IndustryAttributes IndustryAttributes = {
	.displayOrder = @"displayOrder",
	.industryId = @"industryId",
	.infoText = @"infoText",
	.thumbNail = @"thumbNail",
	.title = @"title",
};

const struct IndustryRelationships IndustryRelationships = {
	.category = @"category",
	.images = @"images",
	.industryProducts = @"industryProducts",
	.resources = @"resources",
	.tags = @"tags",
};

const struct IndustryFetchedProperties IndustryFetchedProperties = {
};

@implementation IndustryID
@end

@implementation _Industry

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Industry" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Industry";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Industry" inManagedObjectContext:moc_];
}

- (IndustryID*)objectID {
	return (IndustryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic displayOrder;






@dynamic industryId;






@dynamic infoText;






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
	

@dynamic industryProducts;

	
- (NSMutableSet*)industryProductsSet {
	[self willAccessValueForKey:@"industryProducts"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"industryProducts"];
  
	[self didAccessValueForKey:@"industryProducts"];
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

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Resource.m instead.

#import "_Resource.h"

const struct ResourceAttributes ResourceAttributes = {
	.displayOrder = @"displayOrder",
	.resourceId = @"resourceId",
	.title = @"title",
};

const struct ResourceRelationships ResourceRelationships = {
	.industry = @"industry",
	.product = @"product",
	.resourceItems = @"resourceItems",
};

const struct ResourceFetchedProperties ResourceFetchedProperties = {
};

@implementation ResourceID
@end

@implementation _Resource

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Resource" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Resource";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Resource" inManagedObjectContext:moc_];
}

- (ResourceID*)objectID {
	return (ResourceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic displayOrder;






@dynamic resourceId;






@dynamic title;






@dynamic industry;

	

@dynamic product;

	

@dynamic resourceItems;

	
- (NSMutableSet*)resourceItemsSet {
	[self willAccessValueForKey:@"resourceItems"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"resourceItems"];
  
	[self didAccessValueForKey:@"resourceItems"];
	return result;
}
	






@end

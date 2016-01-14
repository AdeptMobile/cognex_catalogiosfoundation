// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Tag.m instead.

#import "_Tag.h"

const struct TagAttributes TagAttributes = {
	.tag = @"tag",
};

const struct TagRelationships TagRelationships = {
	.catalogs = @"catalogs",
	.categories = @"categories",
	.galleries = @"galleries",
	.industries = @"industries",
	.products = @"products",
};

const struct TagFetchedProperties TagFetchedProperties = {
};

@implementation TagID
@end

@implementation _Tag

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Tag";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:moc_];
}

- (TagID*)objectID {
	return (TagID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic tag;






@dynamic catalogs;

	
- (NSMutableSet*)catalogsSet {
	[self willAccessValueForKey:@"catalogs"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"catalogs"];
  
	[self didAccessValueForKey:@"catalogs"];
	return result;
}
	

@dynamic categories;

	
- (NSMutableSet*)categoriesSet {
	[self willAccessValueForKey:@"categories"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"categories"];
  
	[self didAccessValueForKey:@"categories"];
	return result;
}
	

@dynamic galleries;

	
- (NSMutableSet*)galleriesSet {
	[self willAccessValueForKey:@"galleries"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"galleries"];
  
	[self didAccessValueForKey:@"galleries"];
	return result;
}
	

@dynamic industries;

	
- (NSMutableSet*)industriesSet {
	[self willAccessValueForKey:@"industries"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"industries"];
  
	[self didAccessValueForKey:@"industries"];
	return result;
}
	

@dynamic products;

	
- (NSMutableSet*)productsSet {
	[self willAccessValueForKey:@"products"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"products"];
  
	[self didAccessValueForKey:@"products"];
	return result;
}
	






@end

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SFCategory.m instead.

#import "_SFCategory.h"

const struct SFCategoryAttributes SFCategoryAttributes = {
	.categoryId = @"categoryId",
	.displayOrder = @"displayOrder",
	.thumbNail = @"thumbNail",
	.title = @"title",
};

const struct SFCategoryRelationships SFCategoryRelationships = {
	.catalog = @"catalog",
	.categories = @"categories",
	.galleries = @"galleries",
	.images = @"images",
	.industries = @"industries",
	.parentCategory = @"parentCategory",
	.products = @"products",
	.tags = @"tags",
};

const struct SFCategoryFetchedProperties SFCategoryFetchedProperties = {
};

@implementation SFCategoryID
@end

@implementation _SFCategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SFCategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SFCategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SFCategory" inManagedObjectContext:moc_];
}

- (SFCategoryID*)objectID {
	return (SFCategoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic categoryId;






@dynamic displayOrder;






@dynamic thumbNail;






@dynamic title;






@dynamic catalog;

	

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
	

@dynamic images;

	
- (NSMutableSet*)imagesSet {
	[self willAccessValueForKey:@"images"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"images"];
  
	[self didAccessValueForKey:@"images"];
	return result;
}
	

@dynamic industries;

	
- (NSMutableSet*)industriesSet {
	[self willAccessValueForKey:@"industries"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"industries"];
  
	[self didAccessValueForKey:@"industries"];
	return result;
}
	

@dynamic parentCategory;

	

@dynamic products;

	
- (NSMutableSet*)productsSet {
	[self willAccessValueForKey:@"products"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"products"];
  
	[self didAccessValueForKey:@"products"];
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

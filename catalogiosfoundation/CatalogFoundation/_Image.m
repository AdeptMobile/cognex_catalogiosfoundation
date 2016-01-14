// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Image.m instead.

#import "_Image.h"

const struct ImageAttributes ImageAttributes = {
	.imagePath = @"imagePath",
};

const struct ImageRelationships ImageRelationships = {
	.catalogs = @"catalogs",
	.categories = @"categories",
	.industries = @"industries",
	.infoPanels = @"infoPanels",
	.products = @"products",
};

const struct ImageFetchedProperties ImageFetchedProperties = {
};

@implementation ImageID
@end

@implementation _Image

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Image";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Image" inManagedObjectContext:moc_];
}

- (ImageID*)objectID {
	return (ImageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic imagePath;






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
	

@dynamic industries;

	
- (NSMutableSet*)industriesSet {
	[self willAccessValueForKey:@"industries"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"industries"];
  
	[self didAccessValueForKey:@"industries"];
	return result;
}
	

@dynamic infoPanels;

	
- (NSMutableSet*)infoPanelsSet {
	[self willAccessValueForKey:@"infoPanels"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"infoPanels"];
  
	[self didAccessValueForKey:@"infoPanels"];
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

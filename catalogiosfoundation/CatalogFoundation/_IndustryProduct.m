// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to IndustryProduct.m instead.

#import "_IndustryProduct.h"

const struct IndustryProductAttributes IndustryProductAttributes = {
	.productId = @"productId",
	.thumbNail = @"thumbNail",
	.title = @"title",
};

const struct IndustryProductRelationships IndustryProductRelationships = {
	.industry = @"industry",
};

const struct IndustryProductFetchedProperties IndustryProductFetchedProperties = {
};

@implementation IndustryProductID
@end

@implementation _IndustryProduct

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"IndustryProduct" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"IndustryProduct";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"IndustryProduct" inManagedObjectContext:moc_];
}

- (IndustryProductID*)objectID {
	return (IndustryProductID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic productId;






@dynamic thumbNail;






@dynamic title;






@dynamic industry;

	






@end

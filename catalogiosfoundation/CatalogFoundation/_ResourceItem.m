// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ResourceItem.m instead.

#import "_ResourceItem.h"

const struct ResourceItemAttributes ResourceItemAttributes = {
	.contentPath = @"contentPath",
	.displayOrder = @"displayOrder",
	.infoText = @"infoText",
	.remotePath = @"remotePath",
	.resourceItemId = @"resourceItemId",
	.resourceType = @"resourceType",
	.startPage = @"startPage",
	.thumbNail = @"thumbNail",
	.title = @"title",
};

const struct ResourceItemRelationships ResourceItemRelationships = {
	.gallery = @"gallery",
	.resource = @"resource",
};

const struct ResourceItemFetchedProperties ResourceItemFetchedProperties = {
};

@implementation ResourceItemID
@end

@implementation _ResourceItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ResourceItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ResourceItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ResourceItem" inManagedObjectContext:moc_];
}

- (ResourceItemID*)objectID {
	return (ResourceItemID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic contentPath;






@dynamic displayOrder;






@dynamic infoText;






@dynamic remotePath;






@dynamic resourceItemId;






@dynamic resourceType;






@dynamic startPage;






@dynamic thumbNail;






@dynamic title;






@dynamic gallery;

	

@dynamic resource;

	






@end

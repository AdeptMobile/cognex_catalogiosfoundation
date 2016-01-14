// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Gallery.m instead.

#import "_Gallery.h"

const struct GalleryAttributes GalleryAttributes = {
	.displayOrder = @"displayOrder",
	.galleryId = @"galleryId",
	.infoText = @"infoText",
	.thumbNail = @"thumbNail",
	.title = @"title",
};

const struct GalleryRelationships GalleryRelationships = {
	.category = @"category",
	.resourceItems = @"resourceItems",
	.tags = @"tags",
};

const struct GalleryFetchedProperties GalleryFetchedProperties = {
};

@implementation GalleryID
@end

@implementation _Gallery

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Gallery" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Gallery";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Gallery" inManagedObjectContext:moc_];
}

- (GalleryID*)objectID {
	return (GalleryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic displayOrder;






@dynamic galleryId;






@dynamic infoText;






@dynamic thumbNail;






@dynamic title;






@dynamic category;

	

@dynamic resourceItems;

	
- (NSMutableSet*)resourceItemsSet {
	[self willAccessValueForKey:@"resourceItems"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"resourceItems"];
  
	[self didAccessValueForKey:@"resourceItems"];
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

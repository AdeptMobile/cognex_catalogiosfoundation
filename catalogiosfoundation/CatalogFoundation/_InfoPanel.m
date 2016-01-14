// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to InfoPanel.m instead.

#import "_InfoPanel.h"

const struct InfoPanelAttributes InfoPanelAttributes = {
	.contentPath = @"contentPath",
	.displayOrder = @"displayOrder",
	.panelId = @"panelId",
	.title = @"title",
};

const struct InfoPanelRelationships InfoPanelRelationships = {
	.catalog = @"catalog",
	.images = @"images",
};

const struct InfoPanelFetchedProperties InfoPanelFetchedProperties = {
};

@implementation InfoPanelID
@end

@implementation _InfoPanel

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"InfoPanel" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"InfoPanel";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"InfoPanel" inManagedObjectContext:moc_];
}

- (InfoPanelID*)objectID {
	return (InfoPanelID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic contentPath;






@dynamic displayOrder;






@dynamic panelId;






@dynamic title;






@dynamic catalog;

	

@dynamic images;

	
- (NSMutableSet*)imagesSet {
	[self willAccessValueForKey:@"images"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"images"];
  
	[self didAccessValueForKey:@"images"];
	return result;
}
	






@end

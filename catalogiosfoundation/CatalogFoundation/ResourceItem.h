#import "_ResourceItem.h"
#import "ContentViewBehavior.h"

@interface ResourceItem : _ResourceItem<ContentViewBehavior> {

}

+ (ResourceItem *)resourceItemWithJsonData:(NSDictionary *)jsonData;

@end

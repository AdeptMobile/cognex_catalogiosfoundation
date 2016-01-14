#import "_Resource.h"
#import "ContentViewBehavior.h"

@interface Resource : _Resource<ContentViewBehavior> {

}

+ (Resource *)resourceWithJsonData:(NSDictionary *)jsonData;

@end

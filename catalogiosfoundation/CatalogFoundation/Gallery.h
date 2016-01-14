#import "_Gallery.h"
#import "ContentViewBehavior.h"

@interface Gallery : _Gallery<ContentViewBehavior> {}

+ (Gallery *)galleryWithJsonData:(NSDictionary *)jsonData;

@end

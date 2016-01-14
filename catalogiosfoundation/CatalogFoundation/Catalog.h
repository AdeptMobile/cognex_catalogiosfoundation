#import "_Catalog.h"
#import "ContentViewBehavior.h"

@interface Catalog : _Catalog<ContentViewBehavior> {

}

+ (Catalog *) catalogWithJsonData: (NSDictionary *) jsonData;

@end

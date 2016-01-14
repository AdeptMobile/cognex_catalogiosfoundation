#import "_Product.h"
#import "ContentViewBehavior.h"

@interface Product : _Product<ContentViewBehavior> {

}

+ (Product *)productWithJsonData:(NSDictionary *)jsonData;

@end

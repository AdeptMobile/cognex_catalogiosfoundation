#import "_IndustryProduct.h"
#import "ContentViewBehavior.h"

@interface IndustryProduct : _IndustryProduct<ContentViewBehavior> {

}

+ (IndustryProduct *)industryProductWithJsonData:(NSDictionary *)jsonData;

@end

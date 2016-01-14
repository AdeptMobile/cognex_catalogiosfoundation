#import "_SFCategory.h"
#import "ContentViewBehavior.h"

@interface SFCategory : _SFCategory<ContentViewBehavior> {

}

+ (SFCategory *) categoryWithJsonData: (NSDictionary *) jsonData;

@end

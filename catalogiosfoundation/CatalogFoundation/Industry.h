#import "_Industry.h"
#import "ContentViewBehavior.h"

@interface Industry : _Industry<ContentViewBehavior> {

}

+ (Industry *) industryWithJsonData: (NSDictionary *) jsonData;

@end

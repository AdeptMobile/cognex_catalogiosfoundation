#import "_InfoPanel.h"
#import "ContentViewBehavior.h"

@interface InfoPanel : _InfoPanel<ContentViewBehavior> {
    
}

+ (InfoPanel *) infoPanelWithJsonData: (NSDictionary *) jsonData;

@end

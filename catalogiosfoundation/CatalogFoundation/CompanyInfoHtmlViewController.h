//
//  TolomaticInfoViewController.h
//  ToloApp
//
//  Created by Torey Lomenda on 7/7/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CompanyInfoHtmlViewConfig.h"

@interface CompanyInfoHtmlViewController : UIViewController {
    
    CompanyInfoHtmlViewConfig *viewConfig;
    
    UIView *leftIconView;
    UIView *rightIconView;
    
    UIWebView *webView;
    UIButton *mainButton;
    
    // This is for HTML in the Resources bundle
    NSString *htmlResourceNamed;
    
    // This is for HTML infoPanels synchronized in the Documents directory
    NSString *htmlPath;
}

- (id) initWithHtmlResourceNamed: (NSString *) anHtmlResource andConfig: (CompanyInfoHtmlViewConfig *) aViewConfig;
- (id) initWithHtmlPath: (NSString *) anHtmlPath  andConfig: (CompanyInfoHtmlViewConfig *) aViewConfig;

@end

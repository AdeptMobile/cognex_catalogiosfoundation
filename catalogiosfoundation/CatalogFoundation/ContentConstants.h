//
//  ContentConstants.h
//
//  Created by Torey Lomenda on 6/7/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LABEL_TOKEN_REGISTER_TRADEMARK @"_regmark"
#define LABEL_TOKEN_FORWARD_DASH @"_dash"
#define LABEL_TOKEN_FORWARD_SLASH @"_slash"

typedef enum {
    FEATURES_TYPE = 100,
    BROCHURES_TYPE = 200,
    PRESENTATIONS_TYPE = 300,
    APPLICATIONS_TYPE = 400,
    CADVIEW_TYPE = 500,
    USERMANUALS_TYPE = 600,
    PARTSHEETS_TYPE = 700,
    WHITEPAPERS_TYPE = 800
} ItemResourceType;

extern NSString *const CONTENT_TYPE_UNKNOWN;
extern NSString *const CONTENT_TYPE_CATALOG;
extern NSString *const CONTENT_TYPE_CATEGORY;
extern NSString *const CONTENT_TYPE_PRODUCT;
extern NSString *const CONTENT_TYPE_GALLERY;
extern NSString *const CONTENT_TYPE_INDUSTRY;
extern NSString *const CONTENT_TYPE_INDUSTRY_PRODUCT;
extern NSString *const CONTENT_TYPE_RESOURCE;
extern NSString *const CONTENT_TYPE_IMAGE;
extern NSString *const CONTENT_TYPE_PDF;
extern NSString *const CONTENT_TYPE_CAD;
extern NSString *const CONTENT_TYPE_MOVIE;
extern NSString *const CONTENT_TYPE_REMOTE;
extern NSString *const CONTENT_TYPE_TEXT;
extern NSString *const CONTENT_TYPE_HTML;

@interface ContentConstants : NSObject {
    
}

@end

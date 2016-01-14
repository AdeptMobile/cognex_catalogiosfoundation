//
//  ContentInfoToolbarConfig.m
//  CatalogFoundation
//
//  Created by Torey Lomenda on 2/4/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import "ContentInfoToolbarConfig.h"

@implementation ContentInfoToolbarConfig
@synthesize type = _type;
@synthesize homeBtnImageNamed = _homeBtnImageNamed;
@synthesize backBtnImageNamed = _backBtnImageNamed;
@synthesize webBtnImageNamed = _webBtnImageNamed;
@synthesize bookmarkBtnImageNamed = _bookmarkBtnImageNamed;
@synthesize searchBtnImageNamed = _searchBtnImageNamed;
@synthesize sketchBtnImageNamed = _sketchBtnImageNamed;
@synthesize refreshBtnImageNamed = _refreshBtnImageNamed;
@synthesize setupBtnImageNamed = _setupBtnImageNamed;
@synthesize centerBgImageNamed = _centerBgImageNamed;
@synthesize leftInsetBgImageNamed = _leftInsetBgImageNamed;
@synthesize rightInsetBgImageNamed = _rightInsetBgImageNamed;

@synthesize webBtnLink = _webBtnLink;

#pragma mark - init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        // Configure anything here
    }
    
    return self;
}


#pragma mark - Accessor Methods

#pragma mark - Public Methods

#pragma mark - Private Methods
@end

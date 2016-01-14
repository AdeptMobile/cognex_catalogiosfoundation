//
//  CarouselMainViewController.h
//  CatalogFoundation
//
//  Created by Torey Lomenda on 1/29/13.
//  Copyright (c) 2013 NA. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "AbstractMainViewController.h"

#import "iCarousel.h"

#import "ToloContentProgressView.h"
#import "UnpackContentOperation.h"
#import "SyncProgressHudView.h"

#import "ContentSyncManager.h"
#import "SFAppConfig.h"

@interface CarouselMainViewController : AbstractMainViewController<iCarouselDataSource, iCarouselDelegate, ContentUnpackDelegate, ContentSyncDelegate, ContentSyncApplyChangesDelegate, SyncProgressHudViewDelegate, MFMailComposeViewControllerDelegate> {
    BOOL doScrollBy;
    
    CarouselMainConfig *mainConfig;
    
    ToloContentProgressView *contentProgressView;
    SyncProgressHudView *syncProgressView;
    
    iCarousel *mainCarousel;
    
    UIView *highlightedView;
    
    UIView *leftIconView;
    UIView *rightIconView;
    UIImageView *mainBackgroundImageView;
    
    NSMutableArray *carouselItems;
    NSInteger numItemsInCarousel;
    
    //UIButton *syncButton;
    
    BOOL unpackedData;
}

@end

//
//  MainViewController.h
//  DonaldsonEngineApp
//
//  Created by Chris Pflepsen on 7/30/12.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "AbstractMainViewController.h"

#import "ToloContentProgressView.h"
#import "UnpackContentOperation.h"
#import "SyncProgressHudView.h"
#import "ProductLevelScrollView.h"
#import "GridMainConfig.h"

#import "ContentSyncManager.h"

@interface GridMainViewController : AbstractMainViewController<ContentUnpackDelegate, ContentSyncDelegate, ContentSyncApplyChangesDelegate, SyncProgressHudViewDelegate, ProductThumbnailDelegate, MFMailComposeViewControllerDelegate> {
    BOOL doScrollBy;
    BOOL unpackedData;
}

@property (nonatomic, strong) ToloContentProgressView *contentProgressView;
@property (nonatomic, strong) SyncProgressHudView *syncProgressView;

@property (nonatomic, strong) ProductLevelScrollView *productScrollView;

@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UIImageView *mainBackgroundImageView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UIImageView *bottomBarImageView;
@property (nonatomic, strong) GridMainConfig *config;

@property (nonatomic, strong)UIView *leftIconView;
@property (nonatomic, strong)UIView *rightIconView;

@end

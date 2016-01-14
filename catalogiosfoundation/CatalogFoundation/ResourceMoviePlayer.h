//
//  ResourceMoviePlayer.h
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/9/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ExpandOverlayViewController.h"

@class ResourceMoviePlayer;

@protocol ResourceMoviePlayerDelegate <NSObject>

@optional
- (void) moviePlayerFinished:(ResourceMoviePlayer *)resourceMoviePlayer atTime:(NSTimeInterval)timeEnded;
- (void) moviePlayerExitedFullScreen:(ResourceMoviePlayer *)resourceMoviewPlayer;
@end

@interface ResourceMoviePlayer : UIView {

    NSObject <ResourceMoviePlayerDelegate>* __weak delegate;
    MPMoviePlayerController *moviePlayer;
    NSURL *movieUrl;
    UIView *playerBackgroundView;
    ExpandOverlayViewController *__weak overlayController;
    UIButton *closeButton;
    NSString *movieTitle;
    UILabel *movieTitleLabel;
    
}

@property (nonatomic, weak) NSObject<ResourceMoviePlayerDelegate>* delegate;
@property (nonatomic, strong) NSURL *movieUrl;
@property (nonatomic, strong) UIView *playerBackgroundView;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, weak) ExpandOverlayViewController *overlayController;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, copy) NSString *movieTitle;
@property (nonatomic, strong) UILabel *movieTitleLabel;

- (id) initWithFrame:(CGRect)frame andUrl:(NSURL *)aMovieUrl;
- (id) initWithFrame:(CGRect)frame title:(NSString *)aMovieTitle andUrl:(NSURL *)aMovieUrl;
- (void) readyPlayer;
- (void) readyPlayerWithStartTime:(NSTimeInterval)startTime;

@end

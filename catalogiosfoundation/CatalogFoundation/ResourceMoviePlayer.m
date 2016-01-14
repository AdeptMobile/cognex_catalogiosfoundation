//
//  ResourceMoviePlayer.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/9/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "ResourceMoviePlayer.h"

#import "SFAppConfig.h"

#import "UIView+ViewLayout.h"
#import "UIImage+CatalogFoundationResourceImage.h"

@interface ResourceMoviePlayer ()

- (void) moviePlayerLoadStateChanged:(NSNotification*)notification;
- (void) moviePlayBackDidFinish:(NSNotification*)notification;
- (void) moviePlayBackDidExitFullScreen:(NSNotification *)notification;

- (void) handleCloseButton:(id)selector;
- (void) cleanupAndExit;

// -(void) handlePinch:(id)sender;
// -(void) doneButtonClicked;

@end

@implementation ResourceMoviePlayer

@synthesize delegate;
@synthesize movieUrl;
@synthesize playerBackgroundView;
@synthesize moviePlayer;
@synthesize overlayController;
@synthesize closeButton;
@synthesize movieTitle;
@synthesize movieTitleLabel;

#pragma mark - init/dealloc
- (id) initWithFrame:(CGRect)frame andUrl:(NSURL *)aMovieUrl {
    return [self initWithFrame:frame title:nil andUrl:aMovieUrl];
}

- (id) initWithFrame:(CGRect)frame title:(NSString *)aMovieTitle andUrl:(NSURL *)aMovieUrl {
    self = [super initWithFrame:frame];
    if (self) {
        self.movieUrl = aMovieUrl;
        self.movieTitle = aMovieTitle;
        
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.playerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 710.0f, 550.0f)];
        self.playerBackgroundView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        [self addSubview:self.playerBackgroundView];
        
        NSString *layerName = @"rounded";
        self.playerBackgroundView.clipsToBounds = NO;
        
        // Remove any previous layer
        [self.playerBackgroundView removeLayerNamed:layerName];
        
        CALayer *round = [CALayer layer];
        round.name = layerName;
        round.frame = self.playerBackgroundView.bounds;
        // Round the corners
        round.masksToBounds = YES;
        round.cornerRadius = 20.0f;
        // Set the borders
        round.borderWidth = 4.0f;
        round.borderColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f] CGColor];
        
        [self.playerBackgroundView.layer insertSublayer:round atIndex:0];
        
        // Add the drop shadow
        self.playerBackgroundView.layer.cornerRadius = 20.0f;
        self.playerBackgroundView.layer.shadowColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f] CGColor];
        self.playerBackgroundView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        self.playerBackgroundView.layer.shadowOpacity = 0.80f;
        self.playerBackgroundView.layer.shadowRadius = 20.0f;
        
        self.closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.closeButton setImage:[UIImage contentFoundationResourceImageNamed:@"circle-X.png"] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(handleCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.playerBackgroundView addSubview:self.closeButton];
        
        self.movieTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.movieTitleLabel.backgroundColor = [UIColor clearColor];
        self.movieTitleLabel.font = [UIFont systemFontOfSize:14.0f];
        self.movieTitleLabel.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
        self.movieTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.movieTitleLabel.adjustsFontSizeToFitWidth = YES;
        self.movieTitleLabel.text = self.movieTitle;
        [self.playerBackgroundView addSubview:self.movieTitleLabel];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
    
    
    
    
    
    delegate = nil;
    
}

#pragma mark - View lifecycle
- (void) layoutSubviews {
    
    [self.playerBackgroundView centerOn:self];
    self.closeButton.frame = CGRectMake(self.playerBackgroundView.frame.size.width - 36.0f, 10.0f, 26.0f, 26.0f);
    self.movieTitleLabel.frame = CGRectMake(36.0f, 10.0f, self.playerBackgroundView.frame.size.width - 72.0f, 26.0f);
    [[self.moviePlayer view] centerOn:self];

}

#pragma mark - Public methods
- (void) readyPlayerWithStartTime:(NSTimeInterval)startTime {
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.movieUrl];
    [self.moviePlayer setControlStyle:[[SFAppConfig sharedInstance] getPortfolioPreviewMoviePlayerStyle]];
     
    [self.moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
    [self.moviePlayer setFullscreen:NO];
    [self.moviePlayer setInitialPlaybackTime:startTime];
    [self.moviePlayer prepareToPlay];
    // Register that the load state changed (movie is ready)
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayerLoadStateChanged:) 
                                                 name:MPMoviePlayerLoadStateDidChangeNotification 
                                               object:nil];
    
    // Register to receive a notification when the movie has finished playing. 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackDidFinish:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidExitFullScreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
}

- (void) readyPlayer {
    [self readyPlayerWithStartTime:0];
}

#pragma mark - MPMoviePlayerController notification handlers
- (void) moviePlayerLoadStateChanged:(NSNotification *)notification {
    // Unless state is unknown, start playback
    if ([self.moviePlayer loadState] != MPMovieLoadStateUnknown) {
        
        // Remove the load state observer
        [[NSNotificationCenter defaultCenter] 
         removeObserver:self
         name:MPMoviePlayerLoadStateDidChangeNotification 
         object:nil];
        
        [[self.moviePlayer view] setFrame:CGRectMake(0.0f, 0.0f, 640.0f, 480.0f)];
        // Add the movie player as a subview
        [self addSubview:[self.moviePlayer view]];
        [[self.moviePlayer view] centerOn:self];
        
        // Play the movie
        [self.moviePlayer play];
    }
}

- (void) moviePlayBackDidFinish:(NSNotification *)notification {    
    // Notify delegate?  The delegate should not close the view right now as it is not fully cleaned up.
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(moviePlayerFinished:atTime:)]) {
        NSTimeInterval endTime = [self.moviePlayer currentPlaybackTime];
        if (endTime > 0.0 && endTime < [self.moviePlayer duration]) {
            [self.delegate moviePlayerFinished:self atTime:endTime];
        } else {
            [self.delegate moviePlayerFinished:self atTime:0.0];
        }
    }
    
    // Call stop waiting for the user to restart.
    [self.moviePlayer pause];
    [self.moviePlayer setCurrentPlaybackTime:0.0];
}

- (void) moviePlayBackDidExitFullScreen:(NSNotification *)notification {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(moviePlayerExitedFullScreen:)]) {
        [self.delegate moviePlayerExitedFullScreen:self];
    }
}

- (void) handleCloseButton:(id)selector {
    [self cleanupAndExit];
}

- (void) cleanupAndExit {
    // Remove observer
    [[NSNotificationCenter 	defaultCenter] 
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification 
     object:nil];
    [[NSNotificationCenter 	defaultCenter]
     removeObserver:self
     name:MPMoviePlayerWillExitFullscreenNotification
     object:nil];
    
    // Notify delegate
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(moviePlayerFinished:atTime:)]) {
        NSTimeInterval endTime = [self.moviePlayer currentPlaybackTime];
        if (endTime > 0.0 && endTime < [self.moviePlayer duration]) {
            [self.delegate moviePlayerFinished:self atTime:endTime];
        } else {
            [self.delegate moviePlayerFinished:self atTime:0.0];
        }
    }
    
    // Cleanup
    [self.moviePlayer stop];
    [self.moviePlayer.view removeFromSuperview];
    
    if (overlayController) {
        [overlayController dismissOverlay];
    }
}


@end

//
//  GrayPageControl.m
//  HealthDemo
//
//  Created by Zachary Lendon on 10/20/10.
//  Copyright 2010 N/A. All rights reserved.
//

#import "GrayPageControl.h"

@implementation GrayPageControl

@synthesize activeImage;
@synthesize inactiveImage;

- (id) init
{
    self = [super init];
	
    if (self == nil)
        return nil;
    
    activeImage = [UIImage imageNamed:@"black_dot.png"];
    inactiveImage = [UIImage imageNamed:@"gray_dot.png"];
	[self updateDots];
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	if (self == nil) {
        return nil;
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self == nil) {
		return nil;
	}

	activeImage = [UIImage imageNamed:@"black_dot.png"];
    inactiveImage = [UIImage imageNamed:@"gray_dot.png"];
	[self updateDots];
    return self;
	
}


- (void) layoutSubviews {
    [super layoutSubviews];
    [self updateDots];
}

- (void) updateDots
{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        //UIImageView* dot = [self.subviews objectAtIndex:i];
        //if (i == self.currentPage) dot.image = activeImage;
        //else dot.image = inactiveImage;
        UIView* dotView = [self.subviews objectAtIndex:i];
        UIImageView* dot = nil;
        
        for (UIView* subview in dotView.subviews)
        {
            if ([subview isKindOfClass:[UIImageView class]])
            {
                dot = (UIImageView*)subview;
                break;
            }
        }
        
        if (dot == nil)
        {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dotView.frame.size.width, dotView.frame.size.height)];
            [dotView addSubview:dot];
        }
        
        if (i == self.currentPage)
        {
            if(self.activeImage)
                dot.image = activeImage;
        }
        else
        {
            if (self.inactiveImage)
                dot.image = inactiveImage;
        }
    }
}

/** override to update dots */
- (void) updateCurrentPageDisplay
{
	[super updateCurrentPageDisplay];
	
	// update dot views
	[self updateDots];
}

- (void) setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    [self updateDots];
}


/** Override setImageNormal */
- (void) setImageNormal:(UIImage*)image
{
	inactiveImage = image;
	
	// update dot views
	[self updateDots];
}

/** Override setImageCurrent */
- (void) setImageCurrent:(UIImage*)image
{
	activeImage = image;
	
	// update dot views
	[self updateDots];
}

/** Override to fix when dots are directly clicked */
- (void) endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event 
{
	[super endTrackingWithTouch:touch withEvent:event];
	
	[self updateDots];
}
@end

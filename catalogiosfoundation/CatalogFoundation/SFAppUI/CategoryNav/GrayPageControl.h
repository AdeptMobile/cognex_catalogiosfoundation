//
//  GrayPageControl.h
//  HealthDemo
//
//  Created by Zachary Lendon on 10/20/10.
//  Copyright 2010 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GrayPageControl : UIPageControl
{
    UIImage* activeImage;
    UIImage* inactiveImage;
}

@property (nonatomic, strong) UIImage *activeImage;
@property (nonatomic, strong) UIImage *inactiveImage;

-(void) updateDots;
-(void) setCurrentPage:(NSInteger)page;

@end

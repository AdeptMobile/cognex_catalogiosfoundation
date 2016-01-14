//
//  PlaceHolderView.h
//  HealthDemo
//
//  Created by Steven McCoole on 10/12/10.
//  Copyright 2010 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PH_DEFAULT_STROKE_COLOR		[UIColor blackColor]
#define PH_DEFAULT_BG_COLOR			[UIColor whiteColor]
#define PH_DEFAULT_STROKE_WIDTH		1.0f

@interface PlaceHolderView : UIView 
{
	UIColor	*_strokeColor;
	UIColor	*_bgColor;
	CGFloat _strokeWidth;
	id _placeHolderItem;
	UILabel *_placeHolderLabel;
}

@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, strong) id placeHolderItem; 
@property (nonatomic, strong) UILabel *placeHolderLabel;

@end

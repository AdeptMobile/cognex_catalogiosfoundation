//
//  OutlineViewControllerDelegate.h
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PdfContentOutlineViewController;

@protocol PdfContentOutlineViewControllerDelegate

-(void)outlineViewController:(PdfContentOutlineViewController *)ovc didRequestPage:(NSUInteger)page;

@end

//
//  BookmarkViewControllerDelegate.h
//  FastPdfKit Sample
//
//  Created by Gianluca Orsini on 28/02/11.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PdfBookmarkViewController;

@protocol PdfBookmarkViewControllerDelegate

-(NSUInteger)pageForBookmarking;
-(void)bookmarkViewController:(PdfBookmarkViewController *)bvc didRequestPage:(NSUInteger)page;
-(NSString *)documentIdForBookmarking;

@end

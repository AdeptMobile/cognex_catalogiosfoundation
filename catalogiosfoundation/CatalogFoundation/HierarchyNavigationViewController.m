//
//  HierarchyNavigationViewController.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/22/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "HierarchyNavigationViewController.h"
#import "OPIFoundation.h"
#import "HierarchyNavigationViewControllerDelegate.h"
#import "ControllerReference.h"
#import "HierarchyNavigationTableCell.h"
#import "ContentViewBehavior.h"
#import "UIImage+CatalogFoundationResourceImage.h"
#import "UIImage+Extensions.h"
#import "NSBundle+CatalogFoundationResource.h"
#import "NSArray+Helpers.h"

#define POPOVER_WIDTH 300.0f
#define POPOVER_HEIGHT 300.0f

@interface HierarchyNavigationViewController ()

- (NSArray *) loadControllerHierarchy;

@end

@implementation HierarchyNavigationViewController

@synthesize controllers;
@synthesize delegate;
@synthesize navController;
@synthesize rootLevelVCAtTop;

#pragma mark - init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.preferredContentSize = CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT);
        } else {
            self.contentSizeForViewInPopover = CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT);
        }
        rootLevelVCAtTop = YES;
        NSArray *controllerArray = [NSArray array];
        [self setControllers:controllerArray];
    }
    return self;
}

- (void) dealloc {
    
    delegate = nil;
    
}

#pragma mark - accessors
- (void) setNavController:(UINavigationController *)aNavController {
    navController = aNavController;
    
    NSArray *controllerArray = [self loadControllerHierarchy];
    [self setControllers:controllerArray];
    
    /*
    if (hierarchyNavigationTableView == nil) {
        // Loaded earlier
    } else {
        [hierarchyNavigationTableView reloadData];
    }
     */
}

#pragma mark - view lifecycle
- (void) loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, POPOVER_WIDTH, POPOVER_HEIGHT)];
    mainView.backgroundColor = [UIColor whiteColor];
    
    hierarchyNavigationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                                  POPOVER_WIDTH,
                                                                                  POPOVER_HEIGHT)
                                                                 style:UITableViewStylePlain];
    hierarchyNavigationTableView.dataSource = self;
    hierarchyNavigationTableView.delegate = self;
    hierarchyNavigationTableView.backgroundColor = [UIColor clearColor];
    hierarchyNavigationTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [mainView addSubview:hierarchyNavigationTableView];
    
    [self setView:mainView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    /*
    NSArray *controllerArray = [NSArray array];
    [self setControllers:controllerArray];
    
    if (hierarchyNavigationTableView == nil) {
        // Loaded earlier
    } else {
        [hierarchyNavigationTableView reloadData];
    }
     */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated {
    [hierarchyNavigationTableView reloadData];
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDelegate/UITableViewSource methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HierarchyNavigationTableCell *cell = (HierarchyNavigationTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) {
        NSInteger controllerIndex = cell.controller.controllerIndex;
        [delegate hierarchyNavigationController:self didSelectControllerIndex:controllerIndex];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	NSInteger count = (controllers == nil) ? 0 : [controllers count];
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ControllerReference *controllerRef = (ControllerReference *)[controllers objectAtIndex:[indexPath row]];
    NSString *cellId = [@"hierarchyNavCell" stringByAppendingString:[controllerRef toString]];
    
    HierarchyNavigationTableCell *cell = (HierarchyNavigationTableCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[HierarchyNavigationTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    cell.controller = controllerRef;
    
    return cell;
    
}

#pragma mark - private methods
- (NSArray *) loadControllerHierarchy {
    NSMutableArray *results = [NSMutableArray array];

    NSArray *viewControllers = [navController viewControllers];

    if (viewControllers && [viewControllers count] > 0) {
        int index = 0;
        for (UIViewController *vc in viewControllers) {
            NSObject<HierarchyNavigationViewControllerDelegate> *vcDelegate = (NSObject<HierarchyNavigationViewControllerDelegate> *)vc;
            ControllerReference *cref = [[ControllerReference alloc] init];
            if (index == 0) {
                cref.name = vc.title;
                cref.controllerIndex = index;
                cref.controllerThumbnail = [UIImage contentFoundationResourceImageNamed:@"sf-default-home.png"];
                cref.controllerThumbnailPath = [NSBundle contentFoundationResourceBundlePathForResource:@"sf-default-home.png"];
            } else if ([vcDelegate respondsToSelector:@selector(contentForNavigationDisplay)]) {
                id<ContentViewBehavior> content = [vcDelegate contentForNavigationDisplay];
                cref.name = [content contentTitle];
                cref.controllerIndex = index;
                UIImage *thumbnail = nil;
                NSString *thumbnailPath = nil;
                if ([content contentThumbNail]) {
                    thumbnail = [UIImage imageWithContentsOfFile:[content contentThumbNail]];
                    thumbnailPath = [content contentThumbNail];
                } 
                //else {
                  //  thumbnail = [UIImage contentFoundationResourceImageNamed:@"not-found.png"];
                  //  thumbnailPath = [NSBundle contentFoundationResourceBundlePathForResource:@"not-found.png"];
                //}
                cref.controllerThumbnail = thumbnail;
                cref.controllerThumbnailPath = thumbnailPath;
            } else {
                cref.name = vc.title;
                cref.controllerIndex = index;
                cref.controllerThumbnail = nil;
                cref.controllerThumbnailPath = nil;
            }
            [results addObject:cref];
            index++;
        }
    }
    
    if (!rootLevelVCAtTop) {
        return [results reversedArray];
    } else {
        return [NSArray arrayWithArray:results];
    }
}

@end

//
//  DetailFavoritesViewController.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/2/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "DetailFavoritesViewController.h"
#import "OPIFoundation.h"
#import "DetailReference.h"
#import "DetailFavoriteTableCell.h"
#import "ContentViewBehavior.h"

#import "NSNotificationCenter+MainThread.h"
#import "NSDictionary+ContentViewBehavior.h"

#define DETAIL_FAVORITES_KEY @"SickApp_Product_Favorites"

#define EDIT_BUTTON_INDEX 2

#define POPOVER_WIDTH 300.0f
#define POPOVER_HEIGHT 300.0f

#define TOOLBAR_HEIGHT 44.0f

@interface DetailFavoritesViewController ()

- (void) disableEditing;
- (void) enableEditing;

- (void) handleAddFavorite:(id)sender;
- (void) handleToggleEdit:(id)sender;

- (void) sortFavorites;

- (DetailReference *) createFavoriteFromString:(NSString *)detailFavoriteString;

@end

@implementation DetailFavoritesViewController

@synthesize delegate;
@synthesize detailFavorites;
@synthesize addBookmarkBtn;

#pragma mark - init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        status = STATUS_NORMAL;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.preferredContentSize = CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT);
        } else {
            self.contentSizeForViewInPopover = CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT);
        }
    }
    return self;
}


#pragma mark - Favorites code
- (void) saveDetailFavorites {
    NSMutableArray *savedDetailFavorites = [NSMutableArray arrayWithCapacity:[detailFavorites count]];
    
    if ([detailFavorites count] > 0) {
        [self sortFavorites];
        
        for (DetailReference *fav in detailFavorites) {
            [savedDetailFavorites addObject:[fav toString]];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:savedDetailFavorites forKey:DETAIL_FAVORITES_KEY];
}

- (NSMutableArray *) loadFavorites {
    NSMutableArray *favoritesArray = nil;
    
    NSArray *storedFavorites = [[NSUserDefaults standardUserDefaults] objectForKey:DETAIL_FAVORITES_KEY];
    if (storedFavorites) {
        favoritesArray = [NSMutableArray arrayWithCapacity:[storedFavorites count]];
        for (NSString *favString in storedFavorites) {
            [favoritesArray addObject:[self createFavoriteFromString:favString]];
        }
    } else {
        favoritesArray = [NSMutableArray array];
    }
    
    return favoritesArray;
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];	
    return YES;
}

#pragma mark - UITableViewDelegate/UITableViewSource methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailFavoriteTableCell *cell = (DetailFavoriteTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) {
        NSString *detailId = cell.favorite.detailId;
        NSString *detailType = cell.favorite.detailType;
        
        if ([detailType isEqualToString:CONTENT_TYPE_PRODUCT]) {
            if (delegate && [delegate respondsToSelector:@selector(favoritesViewController:didRequestProduct:)]) {
                [delegate favoritesViewController:self didRequestProduct:detailId];
            }
        } else if ([detailType isEqualToString:CONTENT_TYPE_INDUSTRY]) {
            if (delegate && [delegate respondsToSelector:@selector(favoritesViewController:didRequestIndustry:)]) {
                [delegate favoritesViewController:self didRequestIndustry:detailId];
            }
        } else if ([detailType isEqualToString:CONTENT_TYPE_GALLERY]) {
            if (delegate && [delegate respondsToSelector:@selector(favoritesViewController:didRequestGallery:)]) {
                [delegate favoritesViewController:self didRequestGallery:detailId];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSUInteger index = indexPath.row;
		[detailFavorites removeObjectAtIndex:index];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	}
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	NSInteger count = [detailFavorites count];
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DetailReference *favorite = (DetailReference *) [detailFavorites objectAtIndex:[indexPath row]];
    NSString *cellId = [@"favoriteCell" stringByAppendingString:[favorite toString]];
    
	DetailFavoriteTableCell *cell = (DetailFavoriteTableCell *) [tableView dequeueReusableCellWithIdentifier:cellId];
	
	if(cell == nil) {
        cell = [[DetailFavoriteTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.favoriteTextField.delegate = self;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	}
    
    cell.favorite = favorite;
	
    if (status == STATUS_NORMAL) {
        cell.isInEditMode = NO;
    } else {
        cell.isInEditMode = YES;
    }
	
	return cell;	
}

#pragma mark - view lifecycle
- (void)loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, POPOVER_WIDTH, POPOVER_HEIGHT)];
    mainView.backgroundColor = [UIColor whiteColor];
    
    //Setup the toolbar at the bottom
    UIBarButtonItem *tbFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    addBookmarkBtn = [[UIBarButtonItem alloc] initWithTitle: @"Add" 
                                                      style:UIBarButtonItemStyleBordered
                                                     target:self 
                                                     action:@selector(handleAddFavorite:)];
    UIBarButtonItem *editBookmarkBtn = [[UIBarButtonItem alloc] initWithTitle: @"Edit" 
                                                                         style:UIBarButtonItemStyleBordered
                                                                        target:self 
                                                                        action:@selector(handleToggleEdit:)];
    
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, POPOVER_HEIGHT - TOOLBAR_HEIGHT,
                                                          POPOVER_WIDTH, TOOLBAR_HEIGHT)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    [toolbar setItems:[NSArray arrayWithObjects:addBookmarkBtn, tbFlex, editBookmarkBtn, nil]];
    [mainView addSubview:toolbar];
    [self setView:mainView];
    
    // Disable add button initially until we know if the delegate supports the productFromFavorites method
    addBookmarkBtn.enabled = NO;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSMutableArray *aFavoritesArray = [self loadFavorites];
    
    [self setDetailFavorites:aFavoritesArray];
    [self sortFavorites];
    
    if (detailFavoritesTableView == nil) {
        detailFavoritesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                                  POPOVER_WIDTH,
                                                                                  POPOVER_HEIGHT - TOOLBAR_HEIGHT)
                                                                 style:UITableViewStylePlain];
        detailFavoritesTableView.dataSource = self;
        detailFavoritesTableView.delegate = self;
        detailFavoritesTableView.backgroundColor = [UIColor clearColor];
        detailFavoritesTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        [self.view addSubview:detailFavoritesTableView];
    } else {
        [detailFavoritesTableView reloadData];
    }
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated {
    
    if (delegate && [delegate respondsToSelector:@selector(canAddFavorite)] && [delegate canAddFavorite] == YES) {
        addBookmarkBtn.enabled = YES;
    } else {
        addBookmarkBtn.enabled = NO;
    }
    
    //Make sure that the favorites are up to date
    NSMutableArray *aFavoritesArray = [self loadFavorites];
    
    [self setDetailFavorites:aFavoritesArray];
    [self sortFavorites];
    [detailFavoritesTableView reloadData];
    
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // disable editing
    [self disableEditing];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark Private Methods
- (void) enableEditing {
	NSMutableArray * items = [[toolbar items] mutableCopy];
    
	UIBarButtonItem * button = [items objectAtIndex:EDIT_BUTTON_INDEX];
	[button setTitle:@"Done"];
	
	[toolbar setItems:items];
    
	
    status = STATUS_EDITING;
    [detailFavoritesTableView setEditing:YES];
    [detailFavoritesTableView reloadData];
    
}

- (void) disableEditing {
    
	NSMutableArray *items = [[toolbar items]mutableCopy];
    
	UIBarButtonItem *button = [items objectAtIndex:EDIT_BUTTON_INDEX];
	[button setTitle:@"Edit"];
	
	[toolbar setItems:items];
	
    status = STATUS_NORMAL;
    
    
    // This will commit the data to the user preferences
    [self saveDetailFavorites];
    
    [detailFavoritesTableView setEditing:NO];
    [detailFavoritesTableView reloadData];
    
}

-(void) handleToggleEdit:(id)sender {
    
	if(status == STATUS_NORMAL) {
		[self enableEditing];
        
	} else if (status == STATUS_EDITING) {
		[self disableEditing];
	}
}

- (void) handleAddFavorite:(id)sender {
	
    if (delegate && [delegate respondsToSelector:@selector(detailForFavorites)]) {
        id<ContentViewBehavior>detail = [delegate detailForFavorites];
        
        [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"contentDetailFavoriteAdded" object:self userInfo:[NSDictionary dictionaryFromContentViewBehavior:detail]];
        
        DetailReference *favorite = [[DetailReference alloc] init];
        favorite.name = [NSString stringWithString:[detail contentTitle]];
        favorite.detailType = [NSString stringWithString:[detail contentType]];
        favorite.detailId = [NSString stringWithString:[detail contentId]];
        [detailFavorites addObject:favorite];
        
        [self saveDetailFavorites];
        
        [detailFavoritesTableView reloadData];
    }
}

- (DetailReference *) createFavoriteFromString:(NSString *)detailFavoriteString {
    DetailReference *favorite = [[DetailReference alloc] init];
    
    NSArray *comps = [detailFavoriteString componentsSeparatedByString:@"::"];
    
    if (comps && [comps count] > 0) {
        NSInteger c = [comps count];
        // Before favorites had types, they were all products.  Default to that.
        favorite.detailType = [NSString stringWithString:CONTENT_TYPE_PRODUCT];
        
        if (c >= 1) {
            favorite.name = (NSString *)[comps objectAtIndex:0];
        }
        if (c >= 2) {
            favorite.detailId = (NSString *)[comps objectAtIndex:1];
        }
        if (c >= 3) {
            favorite.detailType = (NSString *)[comps objectAtIndex:2];
        }
    }
    
    return favorite;
}

- (void) sortFavorites {
    // Copy to the item sorted with primary first
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                  ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray *sortedFavorites = [NSMutableArray arrayWithArray:[detailFavorites sortedArrayUsingDescriptors:sortDescriptors]];
    
    [self setDetailFavorites:sortedFavorites];
}


@end

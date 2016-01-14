//
//  DetailSearchViewController.m
//  CatalogFoundation
//
//  Created by Steven McCoole on 5/11/12.
//  Copyright (c) 2012 NA. All rights reserved.
//

#import "DetailSearchViewController.h"
#import "OPIFoundation.h"
#import "DetailReference.h"
#import "DetailSearchTableCell.h"
#import "ContentViewBehavior.h"
#import "ContentLookup.h"

#import "UIImage+Extensions.h"
#import "UIImage+CatalogFoundationResourceImage.h"
#import "NSNotificationCenter+MainThread.h"

#define POPOVER_WIDTH 300.0f
#define POPOVER_HEIGHT 344.0f

#define SEARCHBAR_HEIGHT 44.0f
#define TOOLBAR_HEIGHT 44.0f

@interface DetailSearchViewController ()

- (void) sortSearchResults;
- (void) searchClearButtonClicked:(id)sender;

@end

@implementation DetailSearchViewController

@synthesize detailSearchResults;
@synthesize delegate;
@synthesize searchClearBtn;

#pragma mark - init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.preferredContentSize = CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT);
        } else {
            self.contentSizeForViewInPopover = CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT);
        }
    }
    return self;
}

- (void) dealloc {
    
    delegate = nil;
    
}

#pragma mark - view lifecycle
- (void) loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, POPOVER_WIDTH, POPOVER_HEIGHT)];
    mainView.backgroundColor = [UIColor whiteColor];

    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, POPOVER_WIDTH, SEARCHBAR_HEIGHT)];
    searchBar.barStyle = UIBarStyleBlackTranslucent;
    searchBar.showsCancelButton = NO;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    detailSearchResultsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                                  POPOVER_WIDTH,
                                                                                  POPOVER_HEIGHT - TOOLBAR_HEIGHT)
                                                                 style:UITableViewStylePlain];
    detailSearchResultsTableView.dataSource = self;
    detailSearchResultsTableView.delegate = self;
    detailSearchResultsTableView.backgroundColor = [UIColor clearColor];
    detailSearchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [detailSearchResultsTableView setTableHeaderView:searchBar];
    
    [mainView addSubview:detailSearchResultsTableView];
    
    
    //Setup the toolbar at the bottom
    UIBarButtonItem *tbFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    searchClearBtn = [[UIBarButtonItem alloc] initWithTitle: @"Clear" 
                                                      style:UIBarButtonItemStyleBordered
                                                     target:self 
                                                     action:@selector(searchClearButtonClicked:)];
    
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, POPOVER_HEIGHT - TOOLBAR_HEIGHT,
                                                          POPOVER_WIDTH, TOOLBAR_HEIGHT)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    [toolbar setItems:[NSArray arrayWithObjects:tbFlex, searchClearBtn, nil]];
    [mainView addSubview:toolbar];
    
    [self setView:mainView];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSArray *resultsArray = [NSArray array];
    [self setDetailSearchResults:resultsArray];
    
    if (detailSearchResultsTableView == nil) {

    } else {
        [detailSearchResultsTableView reloadData];
    }
    
    searchBar.delegate = self;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDelegate/UITableViewSource methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DetailSearchTableCell *cell = (DetailSearchTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) {
        NSString *detailId = cell.searchResult.detailId;
        if (cell.searchResult.detailType == CONTENT_TYPE_PRODUCT) {
            if (delegate && [delegate respondsToSelector:@selector(searchViewController:didRequestProduct:)]) {
                [delegate searchViewController:self didRequestProduct:detailId];
            }
        } else if (cell.searchResult.detailType == CONTENT_TYPE_INDUSTRY) {
            if (delegate && [delegate respondsToSelector:@selector(searchViewController:didRequestIndustry:)]) {
                [delegate searchViewController:self didRequestIndustry:detailId];
            }
        } else if (cell.searchResult.detailType == CONTENT_TYPE_GALLERY) {
            if (delegate && [delegate respondsToSelector:@selector(searchViewController:didRequestGallery:)]) {
                [delegate searchViewController:self didRequestGallery:detailId];
            }
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	NSInteger count = (detailSearchResults == nil) ? 0 : [detailSearchResults count];
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DetailReference *searchResult = (DetailReference *)[detailSearchResults objectAtIndex:[indexPath row]];
    NSString *cellId = [@"searchResultCell" stringByAppendingString:[searchResult toString]];
    
    DetailSearchTableCell *cell = (DetailSearchTableCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[DetailSearchTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    cell.searchResult = searchResult;
    
    return cell;
    
}

#pragma mark - UISearchBarDelegate methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar {
    [aSearchBar setShowsCancelButton:YES animated:YES];
    detailSearchResultsTableView.allowsSelection = NO;
    detailSearchResultsTableView.scrollEnabled = NO;
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    [aSearchBar setShowsCancelButton:NO animated:YES];
    detailSearchResultsTableView.allowsSelection = YES;
    detailSearchResultsTableView.scrollEnabled = YES;

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    NSString *searchString = aSearchBar.text;
    NSArray *searchResults = [[[ContentLookup sharedInstance] impl] searchProductsAndIndustriesAndGalleries:searchString];
    
    // Let interested parties know about the search.  This is mostly for analytics but could be used for other
    // purposes.    
    NSNumber *searchHits = [NSNumber numberWithInteger:(searchResults) ? [searchResults count] : 0];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:searchString forKey:@"SEARCH_TERMS"];
    [dict setValue:searchHits forKey:@"SEARCH_HITS"];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThreadName:@"contentSearchPerformed" object:self userInfo:[NSDictionary dictionaryWithDictionary:dict]];
    
    if (searchResults && [searchResults count] > 0) {
        NSMutableArray *results = [NSMutableArray arrayWithCapacity:[searchResults count]];
        for (id<ContentViewBehavior> detail in searchResults) {
            DetailReference *ref = [[DetailReference alloc] init];
            ref.name = [detail contentTitle];
            ref.detailType = [detail contentType];
            ref.detailId = [detail contentId];
            UIImage *thumbnail = nil;
            if ([detail contentThumbNail]) {
                thumbnail = [UIImage imageWithContentsOfFile:[detail contentThumbNail]];
            } else {
                thumbnail = [UIImage contentFoundationResourceImageNamed:@"not-found.png"];
            }
            ref.detailThumbnail = thumbnail;
            [results addObject:ref];
        }
        
        [aSearchBar setShowsCancelButton:NO animated:YES];
        [aSearchBar resignFirstResponder];
        
        detailSearchResultsTableView.allowsSelection = YES;
        detailSearchResultsTableView.scrollEnabled = YES;
        self.detailSearchResults = [NSArray arrayWithArray:results];
        [self sortSearchResults];
        [detailSearchResultsTableView reloadData];

    }
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)aSearchBar {
    aSearchBar.text = @"";
    [aSearchBar setShowsCancelButton:NO animated:YES];
    [aSearchBar resignFirstResponder];
}

- (void) searchClearButtonClicked:(id)sender {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    self.detailSearchResults = [NSArray array];
    detailSearchResultsTableView.allowsSelection = YES;
    detailSearchResultsTableView.scrollEnabled = YES;
    [detailSearchResultsTableView reloadData];
    
}

#pragma mark - private methods
- (void) sortSearchResults {    
    NSSortDescriptor *sortDescriptor =[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES comparator:^(id firstDocumentName, id secondDocumentName) {
        static NSStringCompareOptions comparisonOptions =
        NSCaseInsensitiveSearch | NSNumericSearch |
        NSWidthInsensitiveSearch | NSForcedOrderingSearch;
        
        return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
    }];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedResults = [NSArray arrayWithArray:[detailSearchResults sortedArrayUsingDescriptors:sortDescriptors]];
    
    [self setDetailSearchResults:sortedResults];
}
@end

    //
//  BookmarkViewController.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/27/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import "PdfBookmarkViewController.h"
#import "OPIFoundation.h"
#import "BookmarkTableCell.h"

#define KEY_FROM_DOCUMENT_ID(doc_id) [NSString stringWithFormat:@"bookmarks_%@",(doc_id)]

#define EDIT_BUTTON_INDEX 2

#define POPOVER_WIDTH 300.0f
#define POPOVER_HEIGHT 300.0f

#define TOOLBAR_HEIGHT 44.0f

@interface PdfBookmarkViewController()

- (void) disableEditing;
- (void) enableEditing;

- (void) handleAddBookmark:(id)sender;
- (void) handleToggleEdit:(id)sender;

- (void) sortBookmarks;

- (Bookmark *) createBookMarkFromString: (NSString *) bookmarkString;

@end

@implementation PdfBookmarkViewController
@synthesize delegate;
@synthesize bookmarks;

#pragma mark - 
#pragma mark init/dealloc Methods
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
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

- (void)dealloc {
	bookmarksTableView = nil;
}

#pragma mark -
#pragma mark Bookmarking code
-(void)saveBookmarks {
    NSString * documentId = [delegate documentIdForBookmarking];
    NSMutableArray *savedBookmarks = [NSMutableArray arrayWithCapacity:[bookmarks count]];
    
    // Convert the bookmarks back for saving
    if ([bookmarks count] > 0) {
        [self sortBookmarks];
        
        for (Bookmark *bookmark in bookmarks) {
            [savedBookmarks addObject:[bookmark toString]];
        }
    }
    
    [[NSUserDefaults standardUserDefaults]setObject:savedBookmarks forKey:KEY_FROM_DOCUMENT_ID(documentId)];
}

-(NSMutableArray *) loadBookmarks {
	
	NSString * documentId = [delegate documentIdForBookmarking];
    NSString *bookmarksKey = KEY_FROM_DOCUMENT_ID(documentId);
	NSMutableArray * bookmarksArray = nil;
    
	NSArray * storedBookmarks = [[NSUserDefaults standardUserDefaults]objectForKey:bookmarksKey];
	if(storedBookmarks) {
        
        // Loop through all building bookmark objects
        if ([storedBookmarks count] > 0) {
            bookmarksArray = [NSMutableArray arrayWithCapacity:[storedBookmarks count]];
            
            for (NSString *bookmarkString in storedBookmarks) {
                [bookmarksArray addObject:[self createBookMarkFromString:bookmarkString]];
            }
        }
	} else {
		bookmarksArray = [NSMutableArray array];
	}
	
	return bookmarksArray;
	
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];	
    return YES;
}

#pragma mark -
#pragma mark Table Datasource and Delegate methods
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    //	Get the right page number from the array
    BookmarkTableCell *cell = (BookmarkTableCell *) [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell) {
        NSNumber *pageNumber = cell.bookmark.pageNumber;
        NSUInteger page = [pageNumber unsignedIntValue];
        
        [delegate bookmarkViewController:self didRequestPage:page];
    }
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSUInteger index = indexPath.row;
		[bookmarks removeObjectAtIndex:index];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	}
}


-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	NSInteger count = [bookmarks count];
	return count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	Bookmark *bookmark = (Bookmark *) [bookmarks objectAtIndex:[indexPath row]];
    NSString *cellId = [@"bookmarkCell" stringByAppendingString:[bookmark toString]];
    
	BookmarkTableCell *cell = (BookmarkTableCell *) [tableView dequeueReusableCellWithIdentifier:cellId];
	
	if(cell == nil) {
        cell = [[BookmarkTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.bookmarkTextField.delegate = self;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	}
    
    cell.bookmark = bookmark;
	
    if (status == STATUS_NORMAL) {
        cell.isInEditMode = NO;
    } else {
        cell.isInEditMode = YES;
    }
	
	return cell;	
}

#pragma mark -
#pragma mark View Lifecycle
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, POPOVER_WIDTH, POPOVER_HEIGHT)];
    mainView.backgroundColor = [UIColor whiteColor];
    
    //Setup the toolbar at the bottom
    UIBarButtonItem *tbFlex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *addBookmarkBtn = [[UIBarButtonItem alloc] initWithTitle: @"Add" 
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self 
                                                                    action:@selector(handleAddBookmark:)];
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
    
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//
//	Here we recover the bookmarks from the userdefaults. While this is fine for an application with a single 
//	pdf document, you probably want to store them in coredata or some other way and bind them to a specific document
//	by setting or passing to this viewcontroller an identifier for the document or tell a delegate to load/save
//	them for us.
    
	NSMutableArray *aBookmarksArray = [self loadBookmarks];
	
	[self setBookmarks:aBookmarksArray];
    [self sortBookmarks];
	
	// Add the table view for the bookmarks
    if (bookmarksTableView == nil) {
        bookmarksTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 
                                                                           POPOVER_WIDTH,
                                                                           POPOVER_HEIGHT - TOOLBAR_HEIGHT)
                                                          style:UITableViewStylePlain];
        bookmarksTableView.dataSource = self;
        bookmarksTableView.delegate = self;
        bookmarksTableView.backgroundColor = [UIColor clearColor];
        bookmarksTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        [self.view addSubview:bookmarksTableView];
    } else {
        [bookmarksTableView reloadData];
    }
}

- (void) viewWillAppear:(BOOL)animated {
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Private Methods
-(void)enableEditing {
	NSMutableArray * items = [[toolbar items] mutableCopy];
    
	UIBarButtonItem * button = [items objectAtIndex:EDIT_BUTTON_INDEX];
	[button setTitle:@"Done"];
	
	[toolbar setItems:items];
    
	
    status = STATUS_EDITING;
    [bookmarksTableView setEditing:YES];
    [bookmarksTableView reloadData];
    
}

-(void)disableEditing {
    
	NSMutableArray *items = [[toolbar items]mutableCopy];
    
	UIBarButtonItem *button = [items objectAtIndex:EDIT_BUTTON_INDEX];
	[button setTitle:@"Edit"];
	
	[toolbar setItems:items];
	
     status = STATUS_NORMAL;
    
    
    // This will commit the data to the user preferences
    [self saveBookmarks];
    
    [bookmarksTableView setEditing:NO];
    [bookmarksTableView reloadData];
   
}

-(void) handleToggleEdit:(id)sender {
    
	if(status == STATUS_NORMAL) {
		[self enableEditing];
        
	} else if (status == STATUS_EDITING) {
		[self disableEditing];
	}
}

- (void) handleAddBookmark:(id)sender {
	
	NSUInteger currentPage = [delegate pageForBookmarking];
	
    Bookmark *bookmark = [[Bookmark alloc] init];
    bookmark.name = [NSString stringWithFormat:@"Page %lu", (unsigned long)currentPage];
    bookmark.pageNumber = [NSNumber numberWithUnsignedInteger:currentPage];
	[bookmarks addObject:bookmark];
	
    [self saveBookmarks];
    
	[bookmarksTableView reloadData];
}
                         
- (Bookmark *) createBookMarkFromString:(NSString *)bookmarkString {
    Bookmark *bookmark = [[Bookmark alloc] init];
    
    NSRange dashRange = [bookmarkString rangeOfString:@"::"];
    
    if (dashRange.location != NSNotFound) {
        bookmark.name = [bookmarkString substringToIndex:dashRange.location]; 
        bookmark.pageNumber = [NSNumber numberWithInt:[[bookmarkString substringFromIndex: dashRange.location + 2] intValue]];
    }
    
    return bookmark;
}

- (void) sortBookmarks {
    // Copy to the item sorted with primary first
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                  ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray *sortedBookmarks = [NSMutableArray arrayWithArray:[bookmarks sortedArrayUsingDescriptors:sortDescriptors]];
    
    [self setBookmarks:sortedBookmarks];
}

@end

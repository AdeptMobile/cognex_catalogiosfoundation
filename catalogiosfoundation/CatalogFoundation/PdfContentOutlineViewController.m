    //
//  OutlineViewController.m
//  FastPDFKitTest
//
//  Created by Nicolò Tosi on 8/30/10.
//  Copyright 2010 MobFarm S.r.l. All rights reserved.
//

#import <FastPdfKit/FastPdfKit.h>

#import "PdfContentOutlineViewController.h"
#import "OPIFoundation.h"

#import "UIImage+Extensions.h"
#import "UIImage+CatalogFoundationResourceImage.h"

#define POPOVER_WIDTH 400.0f
#define POPOVER_HEIGHT 500.0f

@interface PdfContentOutlineViewController()

-(void) accessoryButtonTapped:(id)sender event:(id)event;

@end
@implementation PdfContentOutlineViewController

@synthesize outlineEntries, openOutlineEntries;
@synthesize delegate;

#pragma mark -
#pragma mark init/dealloc
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.preferredContentSize = CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT);
        } else {
            self.contentSizeForViewInPopover = CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT);
        }
        
        openOutlineEntries = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}


-(void)recursivelyAddVisibleChildrenOfEntry:(MFPDFOutlineEntry *)entry toArray:(NSMutableArray *)array {
	// This will return the array of item to be added/remove from the table. Since the first entry is just
	// closed and not added/removed we should take that into account. If the entry is not the array, we
	// are running the first iteration, otherwise not.
	
	if(![array containsObject:entry]) {
		// First iteration, just add the children, since at least them will be removed/added.
		NSArray * children = [entry bookmarks];
		[array addObjectsFromArray:children];
		
		// Now recursively call this method on the childrend just addded. Don't use array since
		// it is going to me modified and you will get an exception (array being modified while
		// being enumerated)
		for(MFPDFOutlineEntry * e in children) {
			
			[self recursivelyAddVisibleChildrenOfEntry:e toArray:array];
		}
	} else {
		
		// This may seem tricky at first, but it is rather straightforward: if the entry 
		// is in the openOutlineEntries, its children will be visible right under it in the list, so
		// we need to add them in the array.
		// Thus, we take the position of the entry in the array and insert its children at the right
		// positions in the array, then invoke this very same method on every children just added.
		
		if([openOutlineEntries containsObject:entry]) {
			
			NSUInteger position = [array indexOfObject:entry];
			NSMutableArray *children = [[entry bookmarks]mutableCopy];
			NSUInteger count = [children count];
			
			// NSIndexSet indexSetWithIndexesInRange: factory method is really useful :)
			[array insertObjects:children atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(position+1, count)]];
			
			for(MFPDFOutlineEntry *e in children) {
				[self recursivelyAddVisibleChildrenOfEntry:e toArray:array];
			}
			
			
		} else {
			
			// Well, no children to add/remove since the entry is closed and none of its children
			// is visible. Just return.
			
			return;
		}
	}
	
}

#pragma mark -
#pragma mark UITableViewDelegate & DataSource methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [outlineEntries count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Well, this is just common cell creation depending on the items in the data source. The cell used
	// in the example is rather simple, just a default cell with an accessory button. You can probably
	// want something customized, for example a clickable button to open/hide the cildren or a touchable
	// title to go to the selected outline entry. It is really up to you.
	MFPDFOutlineEntry *entry = [outlineEntries objectAtIndex:indexPath.row];
    NSString *cellId = [@"outlineCellId" stringByAppendingFormat:@"%lu-%ld", (unsigned long)entry.pageNumber, (long)entry.indentation];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	
	if(nil == cell) {
		
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
		
	}
	
    if([[entry bookmarks] count] > 0) {
        UIImage *image = nil;
        
        if ([openOutlineEntries containsObject:entry]) {
            //image = [UIImage imageResource:@"minus.png"];
            image = [UIImage contentFoundationResourceImageNamed:@"minus.png"];
        } else {
            //image = [UIImage imageResource:@"plus.png"];
            image = [UIImage contentFoundationResourceImageNamed:@"plus.png"];
        }

        if (cell.accessoryView) {
            UIButton *button = (UIButton *) cell.accessoryView;
            [button setImage:image forState:UIControlStateNormal];
        } else {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect frame = CGRectMake(0.0, 0.0, image.size.width*4, image.size.height*2.5);
            button.frame = frame;
            [button setImage:image forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(accessoryButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor clearColor];
            cell.accessoryView = button;
        }
    } else {
		[cell setAccessoryType:UITableViewCellAccessoryNone];
        
        if (cell.accessoryView) {
            [cell.accessoryView removeFromSuperview];
        }
	} 
    
	[cell setIndentationLevel:[entry indentation]];
	
	[[cell textLabel]setText:[entry title]];
	
	return cell;
}

-(void) accessoryButtonTapped:(id)sender event:(id)event {	
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    
    if (indexPath) {
        // We try to replicate the outline view of adobe reader, but you can also choose to use a more
        // simpler navigation using nested table views. It probably depend on how deep the outline tree
        // is and how important is to your application: for a book is probably vital, for a catalog not
        // so much...
        
        MFPDFOutlineEntry * entry = [outlineEntries objectAtIndex:indexPath.row];
        
        // If the entry is a leaf (it doesn't have children), return immediately.
        if(![[entry bookmarks]count]>0) {
            return;
        }
        
        // We need to add/remove a certain number of rows depending on how
        // many entries are visible in the tree branch we are going to open/close. Do do that,
        // we get the selected entry and traverse it breadth first and add the children if the node
        // result open (that is, if the entry is in the open entry list). If it is not, we can skip to its next
        // siebling.
        
        // Create and array of children with a utility method. Check of it works.
        NSMutableArray * children = [NSMutableArray array];
        [self recursivelyAddVisibleChildrenOfEntry:entry toArray:children];
        
        // Then we need an NSIndexSet to update the entry array and an array of NSIndexPath to update the table view.
        // The number of object to add/remove and the first position of them are necessary to be know. 
        NSUInteger count = [children count];						// Number of row to be removed.
        NSUInteger firstPosition = [outlineEntries indexOfObject:entry]+1;	// The position right under the selected cell.
        
        // This is the indexSet of the item to be added/removed from the outline array.
        NSIndexSet * indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstPosition, count)];
        
        // To update the table view we need an array of indexPaths. I don't know a factory method to generate them, 
        // so let's do it manually...
        NSMutableArray * indexPaths = [NSMutableArray array];				// The array.
        NSUInteger index;
        for (index = 0; index < count; index++) {
            // The cell to be removed start right under the entry selected.
            [indexPaths addObject:[NSIndexPath indexPathForRow:firstPosition+index inSection:0]];
        }
        
        // Now we will proceed differently if we are collapsing the node or not.
        if([openOutlineEntries containsObject:entry]) {
            // Remove the entry selected and all of its visible children from the outlineEntries array
            // and update the tableview by removing the cell at the corresponding indexPaths.
            
            [outlineEntries removeObjectsAtIndexes:indexSet];
            
            // Now we can update the table view.
            [self.tableView beginUpdates];
            
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            
            [self.tableView endUpdates];
            
            // Critical: remove the entry from the open list. If you want to collapse the entire subtree, you can
            // remove the children you find to be open in the recursivelyAddVisibleChildrenOfEntry: selector.
            [openOutlineEntries removeObject:entry];
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            UIButton *button = (UIButton *) cell.accessoryView;
            //UIImage *image = [UIImage imageResource:@"plus.png"];
            UIImage *image = [UIImage contentFoundationResourceImageNamed:@"plus.png"];
            [button setImage:image forState:UIControlStateNormal];
            
        } else {
            // Add the visible children of the selected entry to the outlineEntries array and update
            // the tableview by addind the cell at the corresponding indexPaths
            
            // First the entries in the array.
            [outlineEntries insertObjects:children atIndexes:indexSet];
            
            // Then the table.
            [self.tableView beginUpdates];
            
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
            
            [self.tableView endUpdates];
            
            // Critical: add the entry from the open list.
            [openOutlineEntries addObject:entry];
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            UIButton *button = (UIButton *) cell.accessoryView;
            //UIImage *image = [UIImage imageResource:@"minus.png"];
            UIImage *image = [UIImage contentFoundationResourceImageNamed:@"minus.png"];
            [button setImage:image forState:UIControlStateNormal];
        }
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MFPDFOutlineEntry *entry = [outlineEntries objectAtIndex:indexPath.row];
	
	// Go to page if it is not 0. The point is that some kind of link are not supported, for example the ones
	// that refer to actions linking to other pdf files. In this case the destination page is set to be 0, and
	// it never exist. We already have a control in the cellForRowAtIndexPath: method and the setPage: method
	// does nothing if the page is 0, but better be paranoid than sorry.
	
	NSUInteger pageNumber = [entry pageNumber];
	if(pageNumber != 0) {
		
		[delegate outlineViewController:self didRequestPage:pageNumber];
	}
	
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
		
}

#pragma mark -
#pragma mark ViewController lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Deselect all rows (reload the data to do this).
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
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

@end

//
//  CitationListTableViewController.m
//  TermPaper
//
//  Created by daltman on 6/29/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "CitationListTableViewController.h"

@implementation CitationListTableViewController

@synthesize mTermPaper, addButton, citationAddController, paperName, citationDetailController;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	self.contentSizeForViewInPopover = CGSizeMake(550, 700);										// TODO: get the appropriate size
	mTermPaper = [TermPaperModel activeTermPaper];
	[self.tableView reloadData];																	// in case user has edited the name and saved it, returning here
	self.navigationController.navigationBar.topItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	self.editing = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return mTermPaper.citations.count;
}

// Customize the appearance of table view cells.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    int index = [indexPath indexAtPosition:1];
	NSString *name = [[mTermPaper.citations objectAtIndex:index] objectForKey:@"Name"];
	if (name == nil || strcmp("NSCFString", object_getClassName(name))) {
		NSLog(@"name = %u, class = %s", (unsigned int) name, object_getClassName(name));
	}
	if (name && !strcmp("NSCFString", object_getClassName(name)) && name.length > 0) {
		cell.textLabel.text = name;
		cell.textLabel.enabled = YES;
	} else {
		cell.textLabel.enabled = NO;
		for (NSDictionary *category in [CitationModel citationTypes]) {
			NSArray *subcats = [category objectForKey:@"SubCats"];
			for (NSDictionary *item in subcats) {
				if ([[item objectForKey:@"TypeID"] isEqualToString:[[mTermPaper.citations objectAtIndex:index] objectForKey:@"TypeID"]]) {
					cell.textLabel.text = [NSString stringWithFormat:@"<%@ citation>", [item objectForKey:@"Name"]];
					break;
				}
			}
		}
	}
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	citationDetailController.mTermPaper = mTermPaper;
	citationDetailController.paperName = paperName;
	// get the selected citation
	NSDictionary *citationDictionary = [mTermPaper.citations objectAtIndex:[indexPath indexAtPosition:1]];
	CitationModel *citation = [[CitationModel alloc] initWithDictionary:citationDictionary];
	citationDetailController.citation = citation;
	citationDetailController.citationListIndex = [indexPath indexAtPosition:1];							// to replace the citation
	// initialize the navigation bar
	[citationDetailController setTitle:[NSString stringWithFormat:@"%@ Citation", citation.citationType]];
	[self.navigationController pushViewController:citationDetailController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSMutableArray *citations = [NSMutableArray arrayWithArray:mTermPaper.citations];
		[citations removeObjectAtIndex:[indexPath indexAtPosition:1]];
		mTermPaper.citations = citations;
		[mTermPaper save];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
	}
}

#pragma mark -

- (IBAction)handleAddButton:(id)sender
{
	citationAddController.mTermPaper = mTermPaper;
	citationAddController.paperName = paperName;
	[self.navigationController pushViewController:citationAddController animated:YES];
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	NSLog(@"CitationListTableViewController didReceiveMemoryWarning");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end

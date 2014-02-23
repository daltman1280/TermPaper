//
//  CitationDetailTableViewController.m
//  TermPaper
//
//  Created by daltman on 6/30/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "CitationDetailTableViewController.h"

static SelectableTextField *gFirstResponder;

@implementation CitationDetailTableViewController

@synthesize citation, paperName, mTermPaper, templateCell, citationListIndex;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	UIImage *buttonImageNormal = [UIImage imageNamed:@"blueButton.png"];
	UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	UIImage *buttonImagePressed = [UIImage imageNamed:@"darkBlueButton.png"];
	UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	
	[nextButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
	[nextButton setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
	[prevButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
	[prevButton setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
	[removeButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
	[removeButton setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
	
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)handleSave:(id)sender
{
	NSLog(@"CitationDetailTableViewController entered");
	int index = 0;
	NSArray *sortByArray;
	if ([[citation.propertySchemaDict objectForKey:@"SortBy"] isKindOfClass:[NSString class]]) {
		NSLog(@"[citation.propertySchemaDict objectForKey:@\"SortBy\"] = %@", [citation.propertySchemaDict objectForKey:@"SortBy"]);
		sortByArray = [NSArray arrayWithObject:[citation.propertySchemaDict objectForKey:@"SortBy"]];
	} else if ([[citation.propertySchemaDict objectForKey:@"SortBy"] isKindOfClass:[NSArray class]]) {
		NSLog(@"[citation.propertySchemaDict objectForKey:@\"SortBy\"] = %@", [citation.propertySchemaDict objectForKey:@"SortBy"]);
		sortByArray = [NSArray arrayWithArray:[citation.propertySchemaDict objectForKey:@"SortBy"]];
	} else
		NSAssert1(NO, @"Invalid sortBy property in definition of citation type %@", [citation.propertySchemaDict objectForKey:@"Name"]);
	BOOL found = NO;
	citation.name = @"";
	for (int i=0; i<sortByArray.count; ++i) {
		index = 0;
		for (CitationProperty *property in citation.properties) {											// look for the property whose PropertyID is equal to SortBy
			if ([property.identifier isEqualToString:[sortByArray objectAtIndex:i]]) {						// get the citation name from the table cell
				NSUInteger indexes[2];
				indexes[0] = 1;																				// second section of table
				indexes[1] = index;
				UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];
				if (((UITextField *)cell.accessoryView).text.length > 0) {									// get the last name, if reference is lastname, firstname
					citation.name = [[((UITextField *)cell.accessoryView).text componentsSeparatedByString:@","] objectAtIndex:0];
					NSLog(@"sortby citation.name = %@", citation.name);
					found = YES;
					break;
				}
			}
			++index;
		}
		if (found) break;
	}
	index = 0;
	for (CitationProperty *property in citation.properties) {
		NSUInteger indexes[2];
		indexes[0] = 1;																					// second section of table
		indexes[1] = index++;																			// iterate through rows
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];
		property.value = ((UITextField *)cell.accessoryView).text;
		NSLog(@"property.value = \"%@\"", property.value);
	}
	NSMutableDictionary *dict = [citation dictionaryFromInstance];
	NSLog(@"dict = %@", dict);
	NSMutableArray *citations = [[NSMutableArray alloc] init];
	[citations addObjectsFromArray:mTermPaper.citations];
	if (citationListIndex < 0) {																		// new citation, add it to the dictionary
		[citations addObject:dict];
	} else {																							// existing citation, replace it
		[citations replaceObjectAtIndex:citationListIndex withObject:dict];
	}
	mTermPaper.citations = citations;
	[mTermPaper save];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)handleCancel:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.tableView reloadData];
	self.navigationController.navigationBar.topItem.rightBarButtonItem = 
	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(handleSave:)];
	self.navigationController.navigationBar.topItem.leftBarButtonItem = 
	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(handleCancel:)];
	self.tableView.allowsSelection = NO;
}

//	The table's cells 
- (void)viewWillDisappear:(BOOL)animated
{
	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	self.contentSizeForViewInPopover = CGSizeMake(550, self.tableView.rowHeight*(((NSArray *)[citation.propertySchemaDict objectForKey:@"Properties"]).count+3));		// TODO: get the appropriate size
	switch (section) {
		case 0:
			return 1;
		case 1:
			return ((NSArray *)[citation.propertySchemaDict objectForKey:@"Properties"]).count;
	}
	return 0;
}

// Customize the appearance of table view cells.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	// the accessoryView is a subclass of SelectableTextField, which allows us to save the index of the next and previous view, for tabbing
	// (using its inputAccessoryView, which points to accessoryView, which is a view containing buttons for next, previous, delete, remove)
	SelectableTextField *cellAccessory;
	NSUInteger indexes[2];
	switch ([indexPath indexAtPosition:0]) {
		case 0:
			if (!cell.accessoryView) {
				cellAccessory = [[SelectableTextField alloc] initWithFrame:CGRectMake(333, 11, 255, 22)];			// TODO: figure out how to use IB
				cell.accessoryView = cellAccessory;
			} else
				cellAccessory = (SelectableTextField *) cell.accessoryView;
			indexes[0] = 1;
			indexes[1] = 0;
			cellAccessory.nextIndex = [NSIndexPath indexPathWithIndexes:indexes length:2];							// points to first cell of second section
			indexes[0] = 1;
			indexes[1] = citation.properties.count - 1;
			cellAccessory.prevIndex = [NSIndexPath indexPathWithIndexes:indexes length:2];							// points to last cell of second section
			cell.textLabel.text = @"Reference Name";
			((UITextField *)cell.accessoryView).placeholder = @"Filled in by the app";
			((UITextField *)cell.accessoryView).text = citation.name;
			((UITextField *)cell.accessoryView).autocapitalizationType = UITextAutocapitalizationTypeWords;
			((UITextField *)cell.accessoryView).inputAccessoryView = accessoryView;									// keyboard accessory
			return cell;
		case 1:
			if (!cell.accessoryView) {
				cellAccessory = [[SelectableTextField alloc] initWithFrame:CGRectMake(333, 11, 255, 22)];			// TODO: figure out how to use IB
				cell.accessoryView = cellAccessory;
			} else
				cellAccessory = (SelectableTextField *) cell.accessoryView;
			indexes[0] = [indexPath indexAtPosition:1] < citation.properties.count - 1 ? 1 : 0;						// for last property, next -> first section
			indexes[1] = [indexPath indexAtPosition:1] < citation.properties.count - 1 ? [indexPath indexAtPosition:1] + 1 : 0;
			cellAccessory.nextIndex = [NSIndexPath indexPathWithIndexes:indexes length:2];							// points to first cell of second section
			indexes[0] = [indexPath indexAtPosition:1] > 0 ? 1 : 0;													// for first property, next -> first section
			indexes[1] = [indexPath indexAtPosition:1] > 0 ? [indexPath indexAtPosition:1] - 1 : 0;
			cellAccessory.prevIndex = [NSIndexPath indexPathWithIndexes:indexes length:2];							// points to last cell of second section
			CitationProperty *property = [citation.properties objectAtIndex:[indexPath indexAtPosition:1]];
			cell.textLabel.text = property.title;
			CGRect rect = cell.textLabel.frame;
			rect.size.width = 200;
			cell.textLabel.frame = rect;
			((UITextField *)cell.accessoryView).text = property.value;
			((UITextField *)cell.accessoryView).placeholder = property.placeholder;
			((UITextField *)cell.accessoryView).autocapitalizationType = UITextAutocapitalizationTypeWords;
			((UITextField *)cell.accessoryView).inputAccessoryView = accessoryView;									// keyboard accessory
			return cell;
	}
	return nil;
}

- (IBAction)selectNextResponder:(id)sender
{
	NSIndexPath *nextIndex = ((SelectableTextField *)gFirstResponder).nextIndex;
	[[self.tableView cellForRowAtIndexPath:nextIndex].accessoryView becomeFirstResponder];
}

- (IBAction)selectPrevResponder:(id)sender
{
	NSIndexPath *prevIndex = ((SelectableTextField *)gFirstResponder).prevIndex;
	[[self.tableView cellForRowAtIndexPath:prevIndex].accessoryView becomeFirstResponder];
}

- (IBAction)handleRemoveText:(id)sender
{
	gFirstResponder.text = @"";
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	NSLog(@"CitationDetailTableViewController didReceiveMemoryWarning");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end

/*
 This UITextField subclass is used for the cell's accessoryView. It saves NSIndexPath to next and previous cell for tabbing. It saves the current first responder
 to be used when the user selects the Next or Previous keyboard accessory button.
 */

@implementation SelectableTextField

@synthesize nextIndex, prevIndex;

- (BOOL)becomeFirstResponder
{
	gFirstResponder = self;
	return [super becomeFirstResponder];
}


@end


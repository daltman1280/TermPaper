//
//  PaperFontsTableViewController.m
//  TermPaper
//
//  Created by daltman on 6/29/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "PaperFontsTableViewController.h"
#import <Crashlytics/Crashlytics.h>

@implementation PaperFontsTableViewController

#pragma mark -
#pragma mark Initialization

@synthesize mTermPaper, textView;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	// save the values. Use the text value of checked-marked cells.
	NSUInteger indexes[2];
	NSInteger numberOfFontNames = [self tableView:self.tableView numberOfRowsInSection:0];				// number of rows in font names section
	for (int i=0; i<numberOfFontNames; ++i) {
		indexes[0] = 0;
		indexes[1] = i;
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];
		if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
			mTermPaper.fontName = cell.textLabel.text;
	}
	NSInteger numberOfFontSizes = [self tableView:self.tableView numberOfRowsInSection:1];				// number of rows in font sizes section
	for (int i=0; i<numberOfFontSizes; ++i) {
		indexes[0] = 1;
		indexes[1] = i;
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];
		if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
			mTermPaper.fontSize = [cell.textLabel.text isEqualToString:@"14"] ? @"Large" : [cell.textLabel.text isEqualToString:@"12"] ? @"Medium" : @"Small";
	}
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	switch (section) {
		case 0:
			return 3;
			break;
		case 1:
			return 3;
			break;
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
	
	switch ([indexPath indexAtPosition:0]) {
		case 0:																					// font names
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					cell.textLabel.text = @"Helvetica";
					if ([mTermPaper.fontName isEqualToString:@"Helvetica"])
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					break;
				case 1:
					cell.textLabel.text = @"Times New Roman";
					if ([mTermPaper.fontName isEqualToString:@"Times New Roman"])
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					break;
				case 2:
					cell.textLabel.text = @"Georgia";
					if ([mTermPaper.fontName isEqualToString:@"Georgia"])
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					break;
			}
			break;
		case 1:																					// font sizes
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					cell.textLabel.text = @"14";
					if ([mTermPaper.fontSize isEqualToString:@"Large"])
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					break;
				case 1:
					cell.textLabel.text = @"12";
					if ([mTermPaper.fontSize isEqualToString:@"Medium"])
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					break;
				case 2:
					cell.textLabel.text = @"10";
					if ([mTermPaper.fontSize isEqualToString:@"Small"])
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					break;
			}
			break;
	}
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return @"Font Name";
			break;
		case 1:
			return @"Font Size";
			break;
		case 2:
			return nil;
			break;
	}
	return @"";
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger numberOfFontNames, numberOfFontSizes;
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	NSUInteger indexes[2];
	// Setup checkmarks for selected row, clear for other rows in same section as selected (make it behave like a radio button)
	switch ([indexPath indexAtPosition:0]) {
		case 0:																					// font names, deselect all but the selected one
			numberOfFontNames = [self tableView:tableView numberOfRowsInSection:0];				// number of rows in font names section
			for (int i=0; i<numberOfFontNames; ++i) {
				indexes[0] = 0;
				indexes[1] = i;
				UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];
				if (i != [indexPath indexAtPosition:1])
					cell.accessoryType = UITableViewCellAccessoryNone;
				else
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
					
			}
			textView.calculatedHeight = 0;														// tell him he needs to recalculate his height
			break;
		case 1:																					// font sizes, deselect all but the selected one
			numberOfFontSizes = [self tableView:tableView numberOfRowsInSection:1];				// number of rows in font sizes section
			for (int i=0; i<numberOfFontSizes; ++i) {
				indexes[0] = 1;
				indexes[1] = i;
				UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndexes:indexes length:2]];
				if (i != [indexPath indexAtPosition:1])
					cell.accessoryType = UITableViewCellAccessoryNone;
				else
					cell.accessoryType = UITableViewCellAccessoryCheckmark;
				
			}
			textView.calculatedHeight = 0;														// tell him he needs to recalculate his height
			break;
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	CLSLog(@"PaperFontsTableViewController didReceiveMemoryWarning");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end


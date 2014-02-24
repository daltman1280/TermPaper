//
//  CitationReferenceListTableViewController.m
//  TermPaper
//
//  Created by daltman on 7/25/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "TermPaperAppDelegate.h"
#import "CitationReferenceListTableViewController.h"

@implementation CitationReferenceListTableViewController

@synthesize mTermPaper;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	mTermPaper = [TermPaperModel activeTermPaper];
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
    int index = [indexPath indexAtPosition:1];
	NSString *name = [[mTermPaper.citations objectAtIndex:index] objectForKey:@"Name"];
	cell.textLabel.text = name;
	cell.textLabel.enabled = YES;
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = [indexPath indexAtPosition:1];
	NSString *name = [[mTermPaper.citations objectAtIndex:index] objectForKey:@"Name"];
	[self.textViewController pasteReferenceText:name];
	[self.textViewController.citationReferenceListPopoverController dismissPopoverAnimated:NO];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	NSLog(@"CitationReferenceListTableViewController didReceiveMemoryWarning");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end


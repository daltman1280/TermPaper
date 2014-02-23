//
//  CitationAddViewController.m
//  TermPaper
//
//  Created by daltman on 6/29/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "CitationAddViewController.h"

@implementation CitationAddViewController

@synthesize citationTypePicker, column0Selection, column1Selection, citationDetailController, paperName, mTermPaper;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	self.contentSizeForViewInPopover = CGSizeMake(550, 214);		// TODO: get the appropriate size
	self.navigationController.navigationBar.topItem.rightBarButtonItem = 
	[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handleAddCitation:)];
}

#pragma mark dataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	switch (component) {
		case 0:
			return [CitationModel citationTypes].count;
			break;
		case 1:
			return [[[[CitationModel citationTypes] objectAtIndex:self.column0Selection] objectForKey:@"SubCats"] count];
			break;
	}
	return 0;
}

#pragma mark -

#pragma mark delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == 0) {
		column0Selection = row;
		column1Selection = 0;
		[pickerView selectRow:0 inComponent:1 animated:YES];
		[pickerView reloadComponent:1];
	} else if (component == 1)
		column1Selection = row;
}
					
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	switch (component) {
		case 0:
			return [[[CitationModel citationTypes] objectAtIndex:row] objectForKey:@"CatName"];
			break;
		case 1:
			return [[[[[CitationModel citationTypes] objectAtIndex:column0Selection] objectForKey:@"SubCats"] objectAtIndex:row] objectForKey:@"Name"];
			break;
	}
	return @"";
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	switch (component) {
		case 0:
			return pickerView.frame.size.width * .25;
			break;
		case 1:
			return pickerView.frame.size.width * .75;
			break;
	}
	return 0;
}

#pragma mark -

#pragma mark actions

- (IBAction)handleAddCitation:(id)sender
{
	citationDetailController.mTermPaper = mTermPaper;
	citationDetailController.paperName = paperName;
	// create a citation
	CitationModel *citation = [[CitationModel alloc] initWithTypeIndex:column0Selection subTypeIndex:column1Selection];
	citationDetailController.citation = citation;
	citationDetailController.citationListIndex = -1;															// we're creating a new citation
	// initialize the navigation bar
	[citationDetailController setTitle:[NSString stringWithFormat:@"%@ Citation", citation.citationType]];
	// modify the navigation view controllers stack so detail table doesn't return here, but back to citation list
	NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
	[array removeLastObject];
	[array addObject:citationDetailController];
	[self.navigationController setViewControllers:array animated:YES];											// TODO: why doesn't the detail view have a back button?
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)didReceiveMemoryWarning {
	NSLog(@"CitationAddViewController didReceiveMemoryWarning");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end


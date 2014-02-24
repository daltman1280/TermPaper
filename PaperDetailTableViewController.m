//
//  PaperInfoTableViewController.m
//  TermPaper
//
//  Created by daltman on 6/27/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "PaperDetailTableViewController.h"
#import "TermPaperNotifications.h"

@interface PaperDetailTableViewController ()

@end

@implementation PaperDetailTableViewController

@synthesize titleCell, shortTitleCell, authorCell, instructorCell, courseCell, institutionCell, keywordsCell, dateCell, headerTitleCell, abstractCell, wordCountCell;
@synthesize headerOnFirstCell, fontCell, insertDoubleSpacesCell;
@synthesize contentPagesCell, citationPagesCell;

@synthesize paperName, mTermPaper, fontsTableController, citationTableController;

#pragma mark -
#pragma mark View lifecycle

 - (void)viewWillAppear:(BOOL)animated {		// TODO: always managing active paper
	 bypassFormatControlTarget = NO;																// normal state
	 if (![[TermPaperModel activeTermPaper].name isEqualToString:paperName]) {
		 mTermPaper = [[TermPaperModel alloc] initWithName:paperName];								// alloc it and read from file
		 [mTermPaper termPaperFromContentsOfFile];
	 } else
		 mTermPaper = [TermPaperModel activeTermPaper];												// managing active paper, use existing model in memory
	 [self.tableView reloadData];																	// needed, in case font name/size settings have changed
	 [super viewWillAppear:animated];
	 [self loadViews];
}

- (void)viewDidLoad
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kTPPopupVisibleNotification object:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)loadViews
{
	if (mTermPaper.title)
		((UITextField *)titleCell.accessoryView).text = mTermPaper.title;
	if (mTermPaper.shortTitle)
		((UITextField *)shortTitleCell.accessoryView).text = mTermPaper.shortTitle;
	if (mTermPaper.author)
		((UITextField *)authorCell.accessoryView).text = mTermPaper.author;
	if (mTermPaper.instructor)
		((UITextField *)instructorCell.accessoryView).text = mTermPaper.instructor;
	if (mTermPaper.course)
		((UITextField *)courseCell.accessoryView).text = mTermPaper.course;
	if (mTermPaper.date)
		((UITextField *)dateCell.accessoryView).text = mTermPaper.date;
	if (mTermPaper.headerTitle)
		((UITextField *)headerTitleCell.accessoryView).text = mTermPaper.headerTitle;
	if (mTermPaper.abstract)
		((UILabel *)[abstractCell viewWithTag:1]).text = mTermPaper.abstract;
	if (mTermPaper.institution)
		((UITextField *)institutionCell.accessoryView).text = mTermPaper.institution;
	if (mTermPaper.keywords)
		((UITextField *)keywordsCell.accessoryView).text = mTermPaper.keywords;
}

- (void)saveViews
{
	mTermPaper.title = ((UITextField *)titleCell.accessoryView).text;
	mTermPaper.author = ((UITextField *)authorCell.accessoryView).text;
	mTermPaper.format = (formatControl.selectedSegmentIndex == 0) ? @"MLA" : @"APA";
	mTermPaper.contentPages = ((UISwitch *)contentPagesCell.accessoryView).on;
	mTermPaper.citationPages = ((UISwitch *)citationPagesCell.accessoryView).on;
	mTermPaper.shortTitle = ((UITextField *)shortTitleCell.accessoryView).text;
	mTermPaper.institution = ((UITextField *)institutionCell.accessoryView).text;
	mTermPaper.keywords = ((UITextField *)keywordsCell.accessoryView).text;
	mTermPaper.instructor = ((UITextField *)instructorCell.accessoryView).text;
	mTermPaper.course = ((UITextField *)courseCell.accessoryView).text;
	mTermPaper.date = ((UITextField *)dateCell.accessoryView).text;
	mTermPaper.headerTitle = ((UITextField *)headerTitleCell.accessoryView).text;
	mTermPaper.headerOnFirst = ((UISwitch *)headerOnFirstCell.accessoryView).on;
	mTermPaper.insertDoubleSpaces = ((UISwitch *)insertDoubleSpacesCell.accessoryView).on;
	[mTermPaper save];
}

- (void)viewWillDisappear:(BOOL)animated {
	// save the values
	[self saveViews];
	[[NSNotificationCenter defaultCenter] postNotificationName:kTPPopupNotVisibleNotification object:self];
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if ([mTermPaper.format isEqualToString:@"MLA"]) {						// MLA
		return 3;
	} else {																// APA
		return 3;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if ([mTermPaper.format isEqualToString:@"MLA"]) {						// MLA
		switch (section) {
			case 0:
				return 8;
				break;
			case 1:
				return 2;
				break;
			case 2:
				return 2;
				break;
		}
	} else {																// APA
		switch (section) {
			case 0:
				return 8;
				break;
			case 1:
				return 1;
				break;
			case 2:
				return 2;
				break;
		}
	}
    return 0;
}

// Customize the appearance of table view cells.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSArray *words;
	unsigned int infoRow, optionRow;
	switch ([indexPath indexAtPosition:0]) {
		case 0:
			infoRow = ([mTermPaper.format isEqualToString:@"MLA"]) ? infoEnumMLA : infoEnumAPA;
			infoRow |= [indexPath indexAtPosition:1];
			switch (infoRow) {
				case rowAPAFormat:
				case rowMLAFormat:
					formatControl = (UISegmentedControl *)formatCell.accessoryView;
					formatControl.frame = CGRectMake(formatControl.frame.origin.x, formatControl.frame.origin.y, formatControl.frame.size.width, 30);
					formatControl.center = CGPointMake(formatControl.center.x, formatCell.center.y);
					bypassFormatControlTarget = YES;											// don't want to react to control change
					if (!mTermPaper.format)
						mTermPaper.format = @"MLA";
					formatControl.selectedSegmentIndex = ([mTermPaper.format isEqualToString:@"MLA"]) ? 0 : 1;
					bypassFormatControlTarget = NO;
					return formatCell;
					break;
				case rowAPATitle:
				case rowMLATitle:
					return titleCell;
					break;
				case rowAPAShortTitle:
					return shortTitleCell;
					break;
				case rowAPAAuthor:
				case rowMLAAuthor:
					return authorCell;
					break;
				case rowMLAInstructor:
					return instructorCell;
					break;
				case rowMLACourse:
					return courseCell;
					break;
				case rowMLADate:
					return dateCell;
					break;
				case rowMLAHeaderTitle:
					return headerTitleCell;
					break;
				case rowAPAAbstract:
					return abstractCell;
					break;
				case rowAPAWordCount:
				case rowMLAWordCount:
					words = [mTermPaper.content componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					NSUInteger count = words.count;
					if (((NSString *)[words objectAtIndex:0]).length == 0) --count;
					if (count > 0 && ((NSString *)[words lastObject]).length == 0) --count;
					((UITextField *)wordCountCell.accessoryView).text = [NSString stringWithFormat:@"%ld", count];
					return wordCountCell;
					break;
				case rowAPAInstitution:
					return institutionCell;
					break;
				case rowAPAKeywords:
					return keywordsCell;
					break;
			}
		case 1:
			optionRow = ([mTermPaper.format isEqualToString:@"MLA"]) ? optionEnumMLA : optionEnumAPA;
			optionRow |= [indexPath indexAtPosition:1];
			switch (optionRow) {
				case rowMLAHeaderOnFirst:
					if (mTermPaper.headerOnFirst)
						((UISwitch *)headerOnFirstCell.accessoryView).on = mTermPaper.headerOnFirst;
					else
						((UISwitch *)headerOnFirstCell.accessoryView).on = NO;
					return headerOnFirstCell;
					break;
				case rowMLAFont:
					((UILabel *)[fontCell viewWithTag:1]).text = [NSString stringWithFormat:@"%@, %@", mTermPaper.fontName, mTermPaper.fontSize];
					return fontCell;
					break;
				case rowAPAInsertDoubleSpaces:
					if (mTermPaper.insertDoubleSpaces)
						((UISwitch *)insertDoubleSpacesCell.accessoryView).on = mTermPaper.insertDoubleSpaces;
					else
						((UISwitch *)insertDoubleSpacesCell.accessoryView).on = NO;
					return insertDoubleSpacesCell;
					break;
			}
		case 2:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					if (mTermPaper.contentPages)
						((UISwitch *)contentPagesCell.accessoryView).on = mTermPaper.contentPages;
					else
						((UISwitch *)contentPagesCell.accessoryView).on = NO;
					return contentPagesCell;
					break;
				case 1:
					if (mTermPaper.citationPages)
						((UISwitch *)citationPagesCell.accessoryView).on = mTermPaper.citationPages;
					else
						((UISwitch *)citationPagesCell.accessoryView).on = NO;
					return citationPagesCell;
					break;
			}
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0:
			return @"Settings";
			break;
		case 1:
			return @"Options";
			break;
		case 2:
			return @"Page Output";
			break;
	}
	return @"";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"fonts"]) {
		PaperFontsTableViewController *controller = (PaperFontsTableViewController *) segue.destinationViewController;
		controller.title = [NSString stringWithFormat:@"%@ Font", paperName];
		controller.mTermPaper = mTermPaper;
	} else if ([segue.identifier isEqualToString:@"abstract"]) {
		AbstractViewController *controller = (AbstractViewController *) segue.destinationViewController;
		controller.title = [NSString stringWithFormat:@"%@ Font", paperName];
		controller.mTermPaper = mTermPaper;
	}
}

#pragma mark -
#pragma mark Control actions

- (IBAction)handleOutputToggle:(id)sender
{
	textView.calculatedHeight = 0;														// tell him he needs to recalculate his height
}

- (IBAction)handleFormatControl:(id)sender
{
	if (!bypassFormatControlTarget) {
		mTermPaper.format = [formatControl titleForSegmentAtIndex:formatControl.selectedSegmentIndex];
		[self saveViews];
		[self.tableView reloadData];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	NSLog(@"PaperDetailTableViewController didReceiveMemoryWarning");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


@end


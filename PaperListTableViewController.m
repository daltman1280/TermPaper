//
//  PaperListTableViewController.m
//  TermPaper
//
//  Created by daltman on 6/23/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "PaperListTableViewController.h"
#import "TermPaperNotifications.h"

const static int kSGTextFieldTagNumber = 99;

@interface PaperListTableViewController ()

@property (assign) NSInteger						activeEditingSessionIndex;				// in case user taps another row during an active editing session (rename drawing). -1: no active session

@end
@implementation PaperListTableViewController

@synthesize paperNames, popoverViewController, exportPaperActionSheetVisible;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// setup toolbar
	self.toolbarItems = [NSArray arrayWithObjects:addPaper, 
						 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], 
						 deletePaper, 
						 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], 
						 renamePaper, 
						 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], 
						 duplicatePaper, 
						 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], 
						 actionPaper, 
						 nil];
    self.clearsSelectionOnViewWillAppear = NO;
	exportPaperActionSheetVisible = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:kTPPopupVisibleNotification object:self];
	self.activeEditingSessionIndex = -1;																		// initially, no active editing session. Will have row index whenever a session begins
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.tableView reloadData];
	NSUInteger indexes[2];
	indexes[0] = 0;
	indexes[1] = [paperNames indexOfObject:[TermPaperModel activeTermPaper].name];
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
	[self setDeleteButtonEnabled];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] postNotificationName:kTPPopupNotVisibleNotification object:self];
}

- (void)setDeleteButtonEnabled
{
	deletePaper.enabled = self.paperNames.count > 1; 
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.paperNames.count;
}

// Customize the appearance of table view cells.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
	cell.textLabel.text = [self.paperNames objectAtIndex:[indexPath indexAtPosition:1]];
	// create the editing text field
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
	textField.tag = kSGTextFieldTagNumber;
	[cell.contentView insertSubview:textField belowSubview:cell.textLabel];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.clearButtonMode = UITextFieldViewModeAlways;
	textField.hidden = YES;
	if ([[paperNames objectAtIndex:[indexPath indexAtPosition:1]] isEqualToString:[TermPaperModel activeTermPaper].name]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
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
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if ([[paperNames objectAtIndex:[indexPath indexAtPosition:1]] isEqualToString:[TermPaperModel activeTermPaper].name]) {	// it's already selected, just dismiss the popover
		return;
	}
	NSArray *visibleCells = [tableView visibleCells];
	for (UITableViewCell *visibleCell in visibleCells) {
		if (visibleCell != cell)
			visibleCell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	if (self.activeEditingSessionIndex >= 0)
		[self deselectedActiveEditingSession];																// need to handle deselected row BEFORE calling active document setter!
	[self performSelector:@selector(handlePaperPick:) withObject:cell.textLabel.text];	// open the selected paper
}

#pragma mark -
#pragma mark Actions

- (IBAction)handleAddPaper:(id)sender
{
	NSString *newPaperName = [TermPaperModel newPaper];
	if (newPaperName) {
		[self.tableView reloadData];															// display the new name
		NSUInteger indexes[2];
		indexes[0] = 0;
		indexes[1] = [paperNames indexOfObject:newPaperName];
		NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
		[self handlePaperPick:newPaperName];
		[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
	}
	[self setDeleteButtonEnabled];
}

//	UIActionSheetDelegate method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	exportPaperActionSheetVisible = NO;
	if (buttonIndex == actionSheet.cancelButtonIndex) return;									// user canceled
	if (actionSheet == deletePaperActionSheet) {
		NSUInteger previousSelectionIndex = [paperNames indexOfObject:[TermPaperModel activeTermPaper].name];
		[[TermPaperModel activeTermPaper] remove];
		if (previousSelectionIndex >= paperNames.count) --previousSelectionIndex;					// in case user has deleted the last paper in the list
		NSUInteger indexes[2];
		indexes[0] = 0;
		indexes[1] = previousSelectionIndex;
		NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
		[self.tableView reloadData];
		if (self.paperNames.count > 0) {
			[self handlePaperPick:[paperNames objectAtIndex:previousSelectionIndex]];
			[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
		}
		[self setDeleteButtonEnabled];
	} else if (actionSheet == exportPaperActionSheet) {
		NSLog(@"buttonIndex = %ld", (long)buttonIndex);
		switch (buttonIndex) {
			case 0:
				[self handleEmailFeedbackButton:self];
				break;
			case 1:
				[self handleEmailDOCXButton:self];
				break;
			case 2:
				[self handleExportDOCXButton:self];
				break;
			case 3:
				[self handleDropboxPDFButton:self];
				break;
			case 4:
				[self handleEmailPDFButton:self];
				break;
			case 5:
				[self handleExportPDFButton:self];
				break;
#if CONSOLE
			case 6:
				NSLog(@"console output");
				[self handleEmailConsoleButton:self];
				break;
#endif
		}
	} else
		NSAssert(NO, @"Illegal value for actionSheet.");
}

- (IBAction)handleDeletePaper:(id)sender			// TODO: implement UIPopoverControllerDelegate
{
	deletePaperActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Paper" otherButtonTitles:nil];
	[deletePaperActionSheet showFromBarButtonItem:actionPaper animated:YES];
}

//	make the cell's label invisible and activate the text field

- (IBAction)handleRenamePaper:(id)sender
{
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
	cell.textLabel.hidden = YES;
	UITextField *textField = (UITextField *)[cell.contentView viewWithTag:kSGTextFieldTagNumber];
	textField.hidden = NO;
	textField.text = cell.textLabel.text;
	textField.delegate = self;
	[textField becomeFirstResponder];
	self.activeEditingSessionIndex = [[self.tableView indexPathForSelectedRow] indexAtPosition:1];					// active editing session here!
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
	[self closeEditingSessionOfCell:cell textField:textField];
	return YES;																										// always allow the session to end
}

//	User has tapped a different row from the active editing session, we need to end it (and possibly rename its drawing)

- (void)deselectedActiveEditingSession
{
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.activeEditingSessionIndex inSection:0]];		// row that contained active editing session
	UITextField *textField = (UITextField *) [cell.contentView viewWithTag:kSGTextFieldTagNumber];
	[self closeEditingSessionOfCell:cell textField:textField];														// close the editing session
	self.activeEditingSessionIndex = -1;																			// no active editing session
}

/*
 Active editing session terminated, either because user dismissed keyboard, dismissed popover, or tapped a different drawing
 row in the popover.
 */

- (void)closeEditingSessionOfCell:(UITableViewCell *)cell textField:(UITextField *)textField
{
	if (textField.text.length > 0 && ![[TermPaperModel termPapers] containsObject:textField.text]) {				// rename the drawing if it's legal
		BOOL success = [[TermPaperModel activeTermPaper] rename:textField.text];
		if (success) {																								// test return code from rename operation
			[self.tableView reloadData];
			[self handlePaperPick:textField.text];
		}
	}
	// deactivate editing control and activate original cell label
	textField.hidden = YES;
	textField.delegate = nil;
	[textField resignFirstResponder];
	cell.textLabel.hidden = NO;
	cell.textLabel.text = textField.text;
}

- (IBAction)handleDuplicatePaper:(id)sender
{
	NSString *newPaperName = [[TermPaperModel activeTermPaper] duplicate];
	if (newPaperName) {
		[self.tableView reloadData];															// display the new name
		NSUInteger indexes[2];
		indexes[0] = 0;
		indexes[1] = [paperNames indexOfObject:newPaperName];
		NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
		[self handlePaperPick:newPaperName];
		[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
	}
	[self setDeleteButtonEnabled];
}

- (IBAction)handleDropboxPDFButton:(id)sender
{
	dispatch_queue_t exportQueue = dispatch_queue_create("dropbox queue", NULL);
	dispatch_async(exportQueue, ^{
		[self.viewController handleExportPDFButton:self];
		NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *pdfFile = [NSString stringWithFormat:@"%@.pdf", [TermPaperModel activeTermPaper].name];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.restClient uploadFile:pdfFile toPath:@"/" withParentRev:nil fromPath:[documentsFolder stringByAppendingPathComponent:pdfFile]];
		});
	});
}

- (DBRestClient *)restClient {
	if (!_restClient) {
		_restClient =
		[[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		_restClient.delegate = self;
	}
	return _restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
			  from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
	
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Can\'t access Dropbox." delegate:nil cancelButtonTitle:@"" destructiveButtonTitle:@"OK" otherButtonTitles:@"", nil];
	sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[sheet showInView:[[[UIApplication sharedApplication] keyWindow] rootViewController].view];
}

- (IBAction)handleExportPDFButton:(id)sender
{
	[self.viewController handleExportPDFButton:self];
}

- (IBAction)handleExportDOCXButton:(id)sender
{
	[self.viewController saveActivePaper];
	[[TermPaperModel activeTermPaper] exportDocxFile];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)handleEmailCompletion:(NSNotificationCenter *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kDWPDFCompleteNotificationName object:nil];
	if (![MFMailComposeViewController canSendMail])
		;
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:[NSString stringWithFormat:@"Printable PDF for %@", [TermPaperModel activeTermPaper].name]];
	
	NSString *emailBody = @"Please print the attached PDF document.";
	[picker setMessageBody:emailBody isHTML:NO];
	
	NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *pdfFile = [documentsFolder stringByAppendingFormat:@"/%@.pdf", [TermPaperModel activeTermPaper].name];
	NSLog(@"pdffile = %@", pdfFile);
    NSData *myData = [NSData dataWithContentsOfFile:pdfFile];
	NSLog(@"myData.length = %ld", (unsigned long)myData.length);
	NSLog(@"name = %@", [[TermPaperModel activeTermPaper].name stringByAppendingString:@".pdf"]);
	[picker addAttachmentData:myData mimeType:@"application/pdf" fileName:[[TermPaperModel activeTermPaper].name stringByAppendingString:@".pdf"]];
	
	[self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)handleEmailFeedbackButton:(id)sender
{
	if (![MFMailComposeViewController canSendMail])
		;
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setToRecipients:[NSArray arrayWithObject:@"support@homebodyapps.com"]];
	[picker setSubject:[NSString stringWithFormat:@"TermPaper Question/Bug/Suggestion/Feedback"]];
	
	NSString *emailBody = [NSString stringWithFormat:@"TermPaper 1.3 for iPad v%f\n\nDear HomebodyApps Support:\n", NSFoundationVersionNumber];
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)handleEmailPDFButton:(id)sender
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEmailCompletion:) name:kDWPDFCompleteNotificationName object:nil];
	[self.viewController handleExportPDFButton:self];
}

- (IBAction)handleEmailDOCXButton:(id)sender
{
	[self.viewController saveActivePaper];
	[[TermPaperModel activeTermPaper] exportDocxFile];
	if (![MFMailComposeViewController canSendMail])
		;
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:[NSString stringWithFormat:@"Microsoft Word® for %@", [TermPaperModel activeTermPaper].name]];
	
	NSString *emailBody = @"Please print the attached Microsoft Word® document.";
	[picker setMessageBody:emailBody isHTML:NO];
	
	NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *wordFile = [documentsFolder stringByAppendingFormat:@"/%@.docx", [TermPaperModel activeTermPaper].name];
    NSData *myData = [NSData dataWithContentsOfFile:wordFile];
	[picker addAttachmentData:myData mimeType:@"application/doc" fileName:[[TermPaperModel activeTermPaper].name stringByAppendingString:@".docx"]];
	
	[self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)handleActionPaper:(id)sender
{
	exportPaperActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Feedback…", @"Email .docx", @"Export .docx", @"Dropbox PDF", @"Email PDF", @"Export PDF",nil];
	[exportPaperActionSheet showFromBarButtonItem:actionPaper animated:YES];
	exportPaperActionSheetVisible = YES;
}

//	User has selected a paper from the list in the popover, save the current paper and open the selected paper

- (IBAction)handlePaperPick:(NSString *)selectedPaperName
{
	[self.viewController saveActivePaper];
	[[NSUserDefaults standardUserDefaults] setObject:selectedPaperName forKey:@"activePaper"];
	[TermPaperModel makeActive:selectedPaperName];
	[self.viewController openPaper];
	[paperDetailTableController.navigationController popToRootViewControllerAnimated:NO];					// force popover navigationcontrollers back to their root views
	[citationTableController.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	NSLog(@"PaperListTableViewController didReceiveMemoryWarning");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}



@end

@implementation RenameViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

@end


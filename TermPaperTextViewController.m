//
//  ScrollingTextViewController.m
//  TermPaper
//
//  Created by daltman on 6/15/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "TermPaperTextViewController.h"
#import "TermPaperAppDelegate.h"

static BOOL gIsPlainMode = YES;

@implementation TermPaperTextViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	// setup keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillShow:) name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillShow:) name:UIMenuControllerWillHideMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillShow:) name:UIMenuControllerDidShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillShow:) name:UIMenuControllerMenuFrameDidChangeNotification object:nil];
	formattedTextView.mode = multiPageMode;
	// look for new documents to import
	[TermPaperModel importExternalDocuments];
	// initialize text contents of textView
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"activePaper"]) {
		[TermPaperModel makeActive:[[NSUserDefaults standardUserDefaults] objectForKey:@"activePaper"]];
		[self openPaper];
	} else if ([TermPaperModel termPapers].count > 0) {												// just select the first one
		[TermPaperModel makeActive:[[TermPaperModel termPapers] objectAtIndex:0]];
		[self openPaper];
	} else {
		NSString *newPaperName = [TermPaperModel newPaper];
		[[NSUserDefaults standardUserDefaults] setObject:newPaperName forKey:@"activePaper"];
		[TermPaperModel makeActive:newPaperName];
		[self openPaper];
	}
}

#pragma mark UIWindow notifications

- (IBAction)handleInsertCitationReference:(id)sender
{
#pragma mark TOD: fix this
//	[(TermPaperAppDelegate *)appDelegate handleInsertCitationReferenceButton:sender];
}

//	We've resized the text scroll view in keyboardWillShow. We can't get the selection until keyboardDidShow. We will decide whether we need to scroll
//	the view in order to make it visible after the resize.

- (void)keyboardDidShow:(NSNotification *)aNotification
{
	float heightOfView = [self.view convertRect:self.view.frame fromView:nil].size.height;				// taking screen rotation into account
	float heightOfText = plainTextView.frame.size.height;
	CGRect rawKeyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect keyboardRect = [self.view convertRect:rawKeyboardRect fromView:nil];							// to account for interface rotation
	float keyboardHeight = keyboardRect.size.height;
	if (keyboardHeight + heightOfText >= heightOfView) {												// only if the keyboard forces text to be covered
		int selection = plainTextView.selectedRange.location;
		int count = plainTextView.text.length;
		int countFromEnd = count - selection;
		if (countFromEnd < 300) {																		// TODO: why doesn't scrollRectToVisible work?
			[plainTextScrollView scrollRectToVisible:CGRectMake(0, heightOfText-10, 10, 10) animated:YES];
		}
	}
	//	Add the citation reference button in the edit menu
	UIMenuController *theMenu = [UIMenuController sharedMenuController];
	theMenu.menuItems = [NSArray arrayWithObject:[[UIMenuItem alloc] initWithTitle:@"Insert Citation Reference…" action:@selector(handleInsertCitationReference:)]];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
	if (mBKeyboardIsShowing)
		return;
	mBKeyboardIsShowing = YES;
	// the keyboard is showing so resize the table's height
	CGRect rawKeyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect keyboardRect = [self.view convertRect:rawKeyboardRect fromView:nil];							// to account for interface rotation
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = plainTextScrollView.frame;
    frame.size.height -= keyboardRect.size.height;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    plainTextScrollView.frame = frame;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
	mBKeyboardIsShowing = NO;
    // the keyboard is hiding reset the table's height
	CGRect rawKeyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect keyboardRect = [self.view convertRect:rawKeyboardRect fromView:nil];							// to account for interface rotation
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = plainTextScrollView.frame;
    frame.size.height += keyboardRect.size.height;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    plainTextScrollView.frame = frame;
    [UIView commitAnimations];
#pragma mark TODO: fix this
//	[appDelegate dismissCitationReferenceListPopover];													// since there's no longer a selection, can't insert a reference
}

- (void)menuWillShow:(NSNotification *)aNotification
{
	NSLog(@"menuWillShow");														// TODO: how to detect menus
}

#pragma mark UIViewController overrides

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self calculateTextViewBounds];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)didReceiveMemoryWarning {
	NSLog(@"TermPaperTextViewController didReceiveMemoryWarning");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)aTextView
{
	if (plainTextView.contentSize.height != mPreviousContentHeight)
		[self calculateTextViewBounds];
	mPreviousContentHeight = plainTextView.contentSize.height;
	formattedTextView.calculatedHeight = 0;											// force it to recalculate its content height (for its scrollview)
	[formattedTextScrollView invalidate];
}

// TODO: detect the user selection to determine whether it's necessary to scroll the text to make it visible

#if 0
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	NSLog(@"textViewShouldBeginEditing, selection = %d, total = %d", textView.selectedRange.location, textView.text.length);
	return YES;
}

- (BOOL)textViewDidChangeSelection:(UITextView *)textView
{
	NSLog(@"textViewDidChangeSelection, selection = %d, total = %d", textView.selectedRange.location, textView.text.length);
	return YES;
}
#endif

#pragma mark Custom methods

- (void)calculateTextViewBounds
{
	plainTextView.scrollEnabled = YES;
	float contentHeight = plainTextView.contentSize.height+66;							// show some space at the end of content
	CGRect frame = plainTextView.frame;
	frame.size.height = contentHeight;
	plainTextView.frame = frame;
	plainTextView.scrollEnabled = NO;
	[plainTextScrollView setContentSize:CGSizeMake(plainTextScrollView.contentSize.width, contentHeight)];
}

- (NSString *)content
{
	return plainTextView.text;
}

- (void)openPaper
{
	TermPaperModel *termPaper = [TermPaperModel activeTermPaper];
	plainTextView.text = termPaper.content;
	plainTextView.font = [UIFont systemFontOfSize:18.035713];							// to make the leading match the line spacing (22 pixels) of the background paper
	barTitle.title = termPaper.name;
	formattedTextView.calculatedHeight = 0;												// force him to recalculate his height
	[self calculateTextViewBounds];
	if (!gIsPlainMode)																	// if we're in formatted mode, switch back to plain mode
		modeControl.selectedSegmentIndex = 0;
}

- (void)saveActivePaper
{
	[[TermPaperModel activeTermPaper] setContent:plainTextView.text];
	[[TermPaperModel activeTermPaper] save];
}

- (void)formattedTextViewReady:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kDWFormattedViewCompleteNotificationName object:nil];
	[formattedTextScrollView setContentSize:CGSizeMake(formattedTextView.frame.size.width, formattedTextView.calculatedHeight)];
	[formattedTextScrollView scrollRectToVisible:CGRectMake(0, 10, 10, 10) animated:NO];	// scroll to top
	[UIView beginAnimations:@"FormattedToPlainTransition" context:nil];
	[UIView setAnimationDuration:0.5];
	formattedTextScrollView.alpha = 1.0;
	plainTextScrollView.alpha = 0.0;
	[UIView commitAnimations];
}

- (IBAction)handleTogglePlainFormattedButton:(id)sender
{
	if (gIsPlainMode) {														// we're in plain text view, switch to formatted text
		// notification for when formatted view is available to display
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formattedTextViewReady:) name:kDWFormattedViewCompleteNotificationName object:nil];
		[self saveActivePaper];
		[plainTextView resignFirstResponder];
		[formattedTextView setNeedsDisplayInRect:CGRectMake(0, 0, formattedTextView.frame.size.width, 150000)];
		[formattedTextScrollView invalidate];
		formattedTextView.mode = multiPageMode;
	} else {																// we're in formatted text view, switch to plain text mode
		[UIView beginAnimations:@"FormattedToPlainTransition" context:nil];
		[UIView setAnimationDuration:0.5];
		plainTextScrollView.alpha = 1.0;
		formattedTextScrollView.alpha = 0.0;
		[UIView commitAnimations];
	}
	gIsPlainMode = !gIsPlainMode;
}

- (IBAction)handleExportPDFButton:(id)sender
{
	if (gIsPlainMode) {
		[self saveActivePaper];
		[formattedTextView setNeedsDisplayInRect:CGRectMake(0, 0, formattedTextView.frame.size.width, 150000)];
		[formattedTextScrollView setContentSize:CGSizeMake(formattedTextView.frame.size.width, fmin(formattedTextView.frame.size.height, formattedTextView.calculatedHeight))];
	}
	[formattedTextView setNeedsDisplayInRect:CGRectMake(0, 0, formattedTextView.frame.size.width, 150000)];
	formattedTextView.mode = PDFMode;
}

- (void)pasteReferenceText:(NSString *)referenceText
{
	NSRange selectedRange = plainTextView.selectedRange;
	NSMutableString *text = [NSMutableString stringWithString:plainTextView.text];
	NSString *preSpace = [[text substringWithRange:NSMakeRange(MAX(selectedRange.location-1,0), 1)] isEqualToString:@" "] ? @"" : @" ";
	NSString *postSpace = [[text substringWithRange:NSMakeRange(MIN(selectedRange.location, text.length-1), 1)] isEqualToString:@" "] ? @"" : @" ";
	//	Make sure there is space before and after the reference
	NSString *reference = [NSString stringWithFormat:@"%@(%@ )%@", preSpace, referenceText, postSpace];
	[text insertString:reference atIndex:selectedRange.location];
	plainTextView.text = text;
	selectedRange.location += [reference rangeOfString:@")"].location;		// position it to location in front of right paren
	selectedRange.length = 0;
	plainTextView.selectedRange = selectedRange;
}

@end

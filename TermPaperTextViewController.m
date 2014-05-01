//
//  ScrollingTextViewController.m
//  TermPaper
//
//  Created by daltman on 6/15/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "TermPaperTextViewController.h"
#import "TermPaperAppDelegate.h"
#import "PaperListTableViewController.h"
#import "CitationReferenceListTableViewController.h"
#import "TermPaperNotifications.h"
#import <Crashlytics/Crashlytics.h>

static BOOL gIsPlainMode = YES;
static float kSystemFontSizeForPlainText = 18.440904;

@interface TermPaperTextViewController ()

@property UIPopoverController *popover;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *papersButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *modeButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *citationsButton;

@end

@implementation TermPaperTextViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	// setup keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillShow:) name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillShow:) name:UIMenuControllerWillHideMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillShow:) name:UIMenuControllerDidShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillShow:) name:UIMenuControllerMenuFrameDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePopupVisible:) name:kTPPopupVisibleNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePopupNotVisible:) name:kTPPopupNotVisibleNotification object:nil];
	formattedTextView.mode = multiPageMode;
	// look for new documents to import
	[TermPaperModel importExternalDocuments];
	// initialize text contents of textView
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"activePaper"]) {
		if (![TermPaperModel makeActive:[[NSUserDefaults standardUserDefaults] objectForKey:@"activePaper"]]) {
			NSString *newPaperName = [TermPaperModel newPaper];
			[[NSUserDefaults standardUserDefaults] setObject:newPaperName forKey:@"activePaper"];
			[TermPaperModel makeActive:newPaperName];
		}
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"papers"]) {
		[self saveActivePaper];
		UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
		((PaperListTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController).viewController = self;// set up ourselves as delegate
		((UIStoryboardPopoverSegue *)segue).popoverController.delegate = (id) self;																	// popover controller delegate
		self.popover = popoverSegue.popoverController;																								// so we can dismiss the popover
		((PaperListTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController).paperNames = [TermPaperModel termPapers];
	} else if ([segue.identifier isEqualToString:@"settings"]) {
		PaperDetailTableViewController *controller = (PaperDetailTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
		[controller setTitle:[NSString stringWithFormat:@"%@ Settings", [TermPaperModel activeTermPaper].name]];
		controller.paperName = [TermPaperModel activeTermPaper].name;	// tell him which paper to manage
	} else if ([segue.identifier isEqualToString:@"citations"]) {
		NSString *paperName = [TermPaperModel activeTermPaper].name;
		// initialize the navigation bar
		CitationListTableViewController *controller = (CitationListTableViewController *)((UINavigationController *)segue.destinationViewController).topViewController;
		[controller setTitle:[NSString stringWithFormat:@"%@ Citations", paperName]];
		[controller.navigationItem setRightBarButtonItem:controller.addButton animated:NO];
	}
}

#pragma mark UIWindow notifications

- (IBAction)handleInsertCitationReference:(id)sender
{
	CitationReferenceListTableViewController *controller = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"citationReference"];
	controller.textViewController = self;
	controller.mTermPaper = [TermPaperModel activeTermPaper];
	CGRect rect = ((UIMenuController *)sender).menuFrame;
	rect.origin.x += rect.size.width/2;												// center of menu
	rect.origin.y += 50;															// bottom of menu
	rect.size.height = 1;
	rect.size.width = 1;
	self.citationReferenceListPopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
	[self.citationReferenceListPopoverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

//	Set the contentInset height to be the keyboard height. If our selection is covered by the keyboard, set contenOffset to make it visible.

- (void)keyboardDidShow:(NSNotification *)aNotification
{
	float heightOfView = [self.view convertRect:self.view.frame fromView:nil].size.height;				// taking screen rotation into account
	float heightOfText = plainTextView.frame.size.height;
	CGRect rawKeyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	CGRect keyboardRect = [self.view convertRect:rawKeyboardRect fromView:nil];							// to account for interface rotation
	float keyboardHeight = keyboardRect.size.height;
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
	plainTextScrollView.contentInset = contentInsets;
	plainTextScrollView.scrollIndicatorInsets = contentInsets;
	if (keyboardHeight + heightOfText >= heightOfView) {												// only if the keyboard forces text to be covered
		NSUInteger selection = plainTextView.selectedRange.location;
		NSUInteger count = plainTextView.text.length;
		NSUInteger countFromEnd = count - selection;
		if (countFromEnd < 300) {
			[plainTextScrollView setContentOffset:CGPointMake(0, heightOfText-heightOfView+keyboardHeight) animated:YES];
		}
	}
	//	Add the citation reference button in the edit menu
	UIMenuController *theMenu = [UIMenuController sharedMenuController];
	theMenu.menuItems = [NSArray arrayWithObject:[[UIMenuItem alloc] initWithTitle:@"Insert Citation Reference…" action:@selector(handleInsertCitationReference:)]];
}

//	Reset the contentInset

- (void)keyboardWillHide:(NSNotification *)aNotification
{
	NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
	[UIView setAnimationDuration:animationDuration];
	UIEdgeInsets contentInsets = UIEdgeInsetsZero;
	plainTextScrollView.contentInset = contentInsets;
	plainTextScrollView.scrollIndicatorInsets = contentInsets;
	[UIView commitAnimations];
#pragma mark TODO: fix this
	//	[appDelegate dismissCitationReferenceListPopover];													// since there's no longer a selection, can't insert a reference
}

- (void)menuWillShow:(NSNotification *)aNotification
{
	CLSLog(@"menuWillShow");														// TODO: how to detect menus
}

- (void)handlePopupVisible:(id)sender
{
	self.papersButton.enabled = NO;
	self.settingsButton.enabled = NO;
	self.modeButton.enabled = NO;
	self.citationsButton.enabled = NO;
}

- (void)handlePopupNotVisible:(id)sender
{
	self.papersButton.enabled = YES;
	self.settingsButton.enabled = YES;
	self.modeButton.enabled = YES;
	self.citationsButton.enabled = YES;
	if (!gIsPlainMode) {																				// we're in page mode, redisplay pages
		// notification for when formatted view is available to display
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formattedTextViewReady:) name:kDWFormattedViewCompleteNotificationName object:nil];
		[formattedTextView setNeedsDisplayInRect:CGRectMake(0, 0, formattedTextView.frame.size.width, 150000)];
		[formattedTextScrollView invalidate];
		formattedTextView.mode = multiPageMode;
	}
}

#pragma mark UIViewController overrides

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self calculateTextViewBounds];
}

- (void)didReceiveMemoryWarning {
	CLSLog(@"TermPaperTextViewController didReceiveMemoryWarning");
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

//	Recalculate the frame height of plainTextView, whenever the text content changes

- (void)textViewDidChange:(UITextView *)aTextView
{
	[self calculateTextViewBounds];
	formattedTextView.calculatedHeight = 0;											// force it to recalculate its content height (for its scrollview)
	[formattedTextScrollView invalidate];
}

//	Called from paste method of PlainTextView class. Only called if pasteboard contains some form of text. PlainTextView has converted it to NSAttributedString

- (void)paste:(id)sender
{
	NSAttributedString *rawString = plainTextView.pastedString;																					// pasted text
	NSMutableAttributedString *plainTextWithAttributes = [[NSMutableAttributedString alloc] initWithAttributedString:rawString];				// mutable version of pasted text
	// change the font of the pasted text to match our draft view
	[plainTextWithAttributes setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kSystemFontSizeForPlainText]} range:NSMakeRange(0, rawString.length)];
	// bold and italic fonts which match our draft view
	UIFontDescriptor *fontDescriptorBold = [UIFontDescriptor fontDescriptorWithFontAttributes:@{ UIFontDescriptorFamilyAttribute : @"Helvetica", UIFontDescriptorTraitsAttribute : @{UIFontSymbolicTrait: @(UIFontDescriptorTraitBold)} }];
	UIFont *boldFont = [UIFont fontWithDescriptor:fontDescriptorBold size:kSystemFontSizeForPlainText];
	UIFontDescriptor *fontDescriptorItalic = [UIFontDescriptor fontDescriptorWithFontAttributes:@{ UIFontDescriptorFamilyAttribute : @"Helvetica", UIFontDescriptorTraitsAttribute : @{UIFontSymbolicTrait: @(UIFontDescriptorTraitItalic)} }];
	UIFont *italicFont = [UIFont fontWithDescriptor:fontDescriptorItalic size:kSystemFontSizeForPlainText];
	// apply bold and italic traits from rawString to plainTextWithAttributes
	NSUInteger length = rawString.length;
	NSRange effectiveRange = NSMakeRange(0, 0);
	id attributeValue;
	while (NSMaxRange(effectiveRange) < length) {
		attributeValue = [rawString attribute:NSFontAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
		UIFont *font = (UIFont *) attributeValue;
		UIFontDescriptor *descriptor = font.fontDescriptor;
		if (descriptor.symbolicTraits & UIFontDescriptorTraitItalic)
			[plainTextWithAttributes addAttribute:NSFontAttributeName value:italicFont range:effectiveRange];
		else if (descriptor.symbolicTraits & UIFontDescriptorTraitBold)
			[plainTextWithAttributes addAttribute:NSFontAttributeName value:boldFont range:effectiveRange];
	}
	// apply underline style from rawString to plainTextWithAttributes
	effectiveRange = NSMakeRange(0, 0);
	while (NSMaxRange(effectiveRange) < length) {
		attributeValue = [rawString attribute:NSUnderlineStyleAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
		if (attributeValue) {
			[plainTextWithAttributes addAttribute:NSUnderlineStyleAttributeName value:@1 range:effectiveRange];
		}
	}
	// paste plainTextWithAttributes into our selection
	NSMutableAttributedString *textViewString = [[NSMutableAttributedString alloc] initWithAttributedString:plainTextView.attributedText];
	[textViewString replaceCharactersInRange:plainTextView.selectedRange withAttributedString:plainTextWithAttributes];
	plainTextView.attributedText = textViewString;
	[self calculateTextViewBounds];																												// has changed, due to paste operation
}

#pragma mark Custom methods

- (void)calculateTextViewBounds
{
	//	based on the bounding rectangle of the text
	CGRect rect = [plainTextView.attributedText boundingRectWithSize:CGSizeMake(plainTextView.frame.size.width, 1000000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];
	float contentHeight = rect.size.height+166;										// show some space at the end of content
	CGRect frame = plainTextView.frame;
	frame.size.height = contentHeight;
	plainTextView.frame = frame;
	[plainTextScrollView setContentSize:CGSizeMake(plainTextScrollView.contentSize.width, contentHeight)];
}

- (NSString *)content
{
	return plainTextView.text;
}

- (void)openPaper
{
	TermPaperModel *termPaper = [TermPaperModel activeTermPaper];
	NSMutableAttributedString *string;
	if (termPaper.attributedContent) string = [[NSMutableAttributedString alloc] initWithAttributedString:termPaper.attributedContent];
	if (!string) {
		string = [[NSMutableAttributedString alloc] initWithString:termPaper.content ? termPaper.content : @""];
		[string setAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:kSystemFontSizeForPlainText] } range:NSMakeRange(0, string.length)];
		termPaper.attributedContent = string;
	}
	plainTextView.attributedText = string;
	plainTextView.allowsEditingTextAttributes = YES;
	plainTextView.typingAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:kSystemFontSizeForPlainText] };
	barTitle.title = termPaper.name;
	formattedTextView.calculatedHeight = 0;
	// force him to recalculate his height
	[self calculateTextViewBounds];
}

- (void)saveActivePaper
{
	[[TermPaperModel activeTermPaper] setContent:plainTextView.text];
	[[TermPaperModel activeTermPaper] setAttributedContent:plainTextView.attributedText];
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
	FormattedTextView *view = [[FormattedTextView alloc] initWithFrame:formattedTextView.frame];
	view.mode = PDFMode;
	[view drawRect:CGRectZero];
}

- (void)pasteReferenceText:(NSString *)referenceText
{
	NSRange selectedRange = plainTextView.selectedRange;
	NSMutableString *text = [NSMutableString stringWithString:plainTextView.text];
	NSString *preSpace, *postSpace;
	if (text.length) {
		preSpace = [[text substringWithRange:NSMakeRange(MAX(selectedRange.location-1,0), 1)] isEqualToString:@" "] ? @"" : @" ";
		postSpace = [[text substringWithRange:NSMakeRange(MIN(selectedRange.location, text.length-1), 1)] isEqualToString:@" "] ? @"" : @" ";
	} else
		preSpace = postSpace = @"";
	//	Make sure there is space before and after the reference
	NSString *reference = [NSString stringWithFormat:@"%@(%@ )%@", preSpace, referenceText, postSpace];
	[text insertString:reference atIndex:selectedRange.location];
	plainTextView.text = text;
	selectedRange.location += [reference rangeOfString:@")"].location;		// position it to location in front of right paren
	selectedRange.length = 0;
	plainTextView.selectedRange = selectedRange;
}

@end


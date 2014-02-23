//
//  ScrollingTextViewController.h
//  TermPaper
//
//  Created by daltman on 6/15/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackgroundPaperTileView.h"
#import "TermPaperModel.h"
#import "FormattedTextView.h"
#import "PlainTextScrollView.h"
#import "FormattedTextScrollView.h"

@interface TermPaperTextViewController : UIViewController {
	IBOutlet BackgroundPaperTileView*		paperView;
	IBOutlet UITextView*					plainTextView;
	IBOutlet PlainTextScrollView*			plainTextScrollView;
	IBOutlet UIToolbar*						toolbar;
	IBOutlet UIBarButtonItem*				barTitle;
	IBOutlet UIBarButtonItem*				tabControl;
	IBOutlet FormattedTextView*				formattedTextView;						// never visible, only for layout purposes
	IBOutlet FormattedTextScrollView*		formattedTextScrollView;
	UISegmentedControl*						modeControl;
	IBOutlet id								appDelegate;
	
	float									mPreviousContentHeight;
	BOOL									mBKeyboardIsShowing;
}

- (void)calculateTextViewBounds;
- (void)openPaper;
- (void)saveActivePaper;
- (IBAction)handleTogglePlainFormattedButton:(id)sender;
- (IBAction)handleExportPDFButton:(id)sender;
- (void)pasteReferenceText:(NSString *)referenceText;
@property (unsafe_unretained, nonatomic, readonly) NSString *content;

@end


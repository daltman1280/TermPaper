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
#import "PlainTextView.h"

@interface TermPaperTextViewController : UIViewController <UIPopoverControllerDelegate> {
	IBOutlet BackgroundPaperTileView*		paperView;
	IBOutlet PlainTextView*					plainTextView;
	IBOutlet PlainTextScrollView*			plainTextScrollView;
	IBOutlet UIToolbar*						toolbar;
	IBOutlet UIBarButtonItem*				barTitle;
	IBOutlet UIBarButtonItem*				tabControl;
	IBOutlet FormattedTextView*				formattedTextView;						// never visible, only for layout purposes
	IBOutlet FormattedTextScrollView*		formattedTextScrollView;
	IBOutlet UISegmentedControl*			modeControl;
}

- (void)calculateTextViewBounds;
- (void)openPaper;
- (void)saveActivePaper;
- (IBAction)handleTogglePlainFormattedButton:(id)sender;
- (IBAction)handleExportPDFButton:(id)sender;
- (void)pasteReferenceText:(NSString *)referenceText;
- (void)paste:(id)sender;
@property (unsafe_unretained, nonatomic, readonly) NSString *content;
@property (nonatomic, strong) UIPopoverController *citationReferenceListPopoverController;

@end


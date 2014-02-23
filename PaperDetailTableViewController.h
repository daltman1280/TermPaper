//
//  PaperInfoTableViewController.h
//  TermPaper
//
//  Created by daltman on 6/27/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermPaperModel.h"
#import "PaperFontsTableViewController.h"
#import "CitationListTableViewController.h"
#import "AbstractViewController.h"

typedef enum {
	infoEnumMLA = 0x10,
	infoEnumAPA = 0x20
} infoEnum;

//	defines row positions in Info section

typedef enum {
	rowAPAFormat = infoEnumAPA,
	rowAPATitle,
	rowAPAAuthor,
	rowAPAShortTitle,
	rowAPAInstitution,
	rowAPAAbstract,
	rowAPAKeywords,
	rowAPAWordCount,
	rowMLAFormat = infoEnumMLA,
	rowMLATitle,
	rowMLAAuthor,
	rowMLAInstructor,
	rowMLACourse,
	rowMLADate,
	rowMLAHeaderTitle,
	rowMLAWordCount
} infoRowEnum;

typedef enum {
	optionEnumMLA = 0x40,
	optionEnumAPA = 0x80
} optionEnum;

//	defines row positions in Options section

typedef enum {
	rowMLAFont = optionEnumMLA,
	rowMLAHeaderOnFirst,
	rowAPAInsertDoubleSpaces = optionEnumAPA
} optionRowEnum;

@interface PaperDetailTableViewController : UITableViewController {
	// cells outlets
	IBOutlet UITableViewCell*	formatCell;
	UISegmentedControl*			formatControl;
	IBOutlet UITableViewCell*	titleCell;
	IBOutlet UITableViewCell*	shortTitleCell;
	IBOutlet UITableViewCell*	authorCell;
	IBOutlet UITableViewCell*	instructorCell;
	IBOutlet UITableViewCell*	courseCell;
	IBOutlet UITableViewCell*	institutionCell;
	IBOutlet UITableViewCell*	keywordsCell;
	IBOutlet UITableViewCell*	dateCell;
	IBOutlet UITableViewCell*	headerTitleCell;
	IBOutlet UITableViewCell*	abstractCell;
	IBOutlet UITableViewCell*	wordCountCell;

	IBOutlet UITableViewCell*	headerOnFirstCell;
	IBOutlet UITableViewCell*	fontCell;
	IBOutlet UITableViewCell*	insertDoubleSpacesCell;

	IBOutlet UITableViewCell*	contentPagesCell;
	IBOutlet UITableViewCell*	citationPagesCell;

	NSString*							paperName;
	TermPaperModel*						mTermPaper;
	PaperFontsTableViewController*		fontsTableController;
	CitationListTableViewController*	citationTableController;
	IBOutlet FormattedTextView*			textView;
	IBOutlet AbstractViewController*	abstractViewController;
	
	BOOL								bypassFormatControlTarget;
}

- (void)loadViews;
- (IBAction)handleOutputToggle:(id)sender;
- (IBAction)handleFormatControl:(id)sender;

@property (nonatomic, strong) IBOutlet UITableViewCell* titleCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* shortTitleCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* authorCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* instructorCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* courseCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* institutionCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* keywordsCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* dateCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* headerTitleCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* abstractCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* wordCountCell;

@property (nonatomic, strong) IBOutlet UITableViewCell* headerOnFirstCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* fontCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* insertDoubleSpacesCell;

@property (nonatomic, strong) IBOutlet UITableViewCell* contentPagesCell;
@property (nonatomic, strong) IBOutlet UITableViewCell* citationPagesCell;

@property (nonatomic, strong) NSString *paperName;
@property (nonatomic, strong) TermPaperModel *mTermPaper;
@property (nonatomic, strong) IBOutlet PaperFontsTableViewController *fontsTableController;
@property (nonatomic, strong) IBOutlet CitationListTableViewController *citationTableController;
@end


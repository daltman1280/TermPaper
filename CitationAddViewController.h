//
//  CitationAddViewController.h
//  TermPaper
//
//  Created by daltman on 6/29/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitationDetailTableViewController.h"
#import "TermPaperModel.h"
#import "CitationModel.h"

@interface CitationAddViewController : UIViewController {
	IBOutlet UIPickerView*							citationTypePicker;
	int												column0Selection, column1Selection;
	IBOutlet CitationDetailTableViewController*		citationDetailController;
	NSString*										paperName;
	TermPaperModel*									mTermPaper;
}

- (IBAction)handleAddCitation:(id)sender;

@property (nonatomic, strong) IBOutlet UIPickerView *citationTypePicker;
@property (nonatomic) int column0Selection, column1Selection;
@property (nonatomic, strong) IBOutlet CitationDetailTableViewController *citationDetailController;
@property (nonatomic, strong) NSString *paperName;
@property (nonatomic, strong) TermPaperModel *mTermPaper;
@end


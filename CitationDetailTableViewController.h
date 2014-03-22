//
//  CitationDetailTableViewController.h
//  TermPaper
//
//  Created by daltman on 6/30/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermPaperModel.h"
#import "CitationModel.h"

@interface CitationDetailTableViewController : UITableViewController {
	CitationModel*						citation;
	NSString*							paperName;
	TermPaperModel*						mTermPaper;
	IBOutlet UITableViewCell*			templateCell;
	NSInteger							citationListIndex;
	IBOutlet UIView*					accessoryView;
	IBOutlet UIButton*					nextButton;
	IBOutlet UIButton*					prevButton;
	IBOutlet UIButton*					removeButton;
}

- (IBAction)selectNextResponder:(id)sender;
- (IBAction)selectPrevResponder:(id)sender;
- (IBAction)handleRemoveText:(id)sender;

@property (nonatomic, strong) CitationModel *citation;
@property (nonatomic, strong) NSString *paperName;
@property (nonatomic, strong) TermPaperModel *mTermPaper;
@property (nonatomic, strong) IBOutlet UITableViewCell *templateCell;
@property (nonatomic) NSInteger citationListIndex;									// specifies which citation we're managing (-1 denotes a new citation)
@end

@interface SelectableTextField : UITextField
{
	NSIndexPath*						nextIndex;
	NSIndexPath*						prevIndex;
}

@property (nonatomic, strong) NSIndexPath *nextIndex;
@property (nonatomic, strong) NSIndexPath *prevIndex;
@end


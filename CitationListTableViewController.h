//
//  CitationListTableViewController.h
//  TermPaper
//
//  Created by daltman on 6/29/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermPaperModel.h"
#import "CitationAddViewController.h"

@interface CitationListTableViewController : UITableViewController {
	NSString*										paperName;
	TermPaperModel*									mTermPaper;
	IBOutlet UIBarButtonItem*						addButton;
	IBOutlet CitationAddViewController*				citationAddController;
	IBOutlet CitationDetailTableViewController*		citationDetailController;
}

@property (nonatomic, strong) NSString *paperName;
@property (nonatomic, strong) TermPaperModel *mTermPaper;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, strong) IBOutlet CitationAddViewController *citationAddController;
@property (nonatomic, strong) IBOutlet CitationDetailTableViewController *citationDetailController;
@end


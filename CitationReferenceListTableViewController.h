//
//  CitationReferenceListTableViewController.h
//  TermPaper
//
//  Created by daltman on 7/25/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermPaperModel.h"
#import "TermPaperTextViewController.h"

@interface CitationReferenceListTableViewController : UITableViewController {
	TermPaperModel*									mTermPaper;
	IBOutlet TermPaperTextViewController*			textViewController;
	IBOutlet id										appDelegate;
}

@property (nonatomic, strong) TermPaperModel *mTermPaper;

@end
//
//  PaperFontsTableViewController.h
//  TermPaper
//
//  Created by daltman on 6/29/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermPaperModel.h"
#import "FormattedTextView.h"

@interface PaperFontsTableViewController : UITableViewController {
	TermPaperModel*					mTermPaper;
	IBOutlet FormattedTextView*		textView;
}

@property (nonatomic, strong) TermPaperModel *mTermPaper;
@property (nonatomic, strong) IBOutlet FormattedTextView *textView;
@end


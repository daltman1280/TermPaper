//
//  AbstractViewController.h
//  TermPaper
//
//  Created by daltman on 9/16/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermPaperModel.h"

@interface AbstractViewController : UIViewController {
	IBOutlet UITextView*				textView;
	IBOutlet UILabel*					wordCountLabel;
	
	TermPaperModel*						mTermPaper;
}

- (void)updateWordCount;

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) TermPaperModel *mTermPaper;
@end

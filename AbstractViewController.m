//
//  AbstractViewController.m
//  TermPaper
//
//  Created by daltman on 9/16/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "AbstractViewController.h"


@implementation AbstractViewController

@synthesize textView, mTermPaper;

- (void)viewWillAppear:(BOOL)animated {
#if 1
	textView.text = mTermPaper.abstract;
	[self updateWordCount];
#else
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:mTermPaper.abstract];
	[string setAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:kSystemFontSizeForPlainText] } range:NSMakeRange(0, string.length)];
	textView.attributedText = string;
	textView.allowsEditingTextAttributes = YES;
	[self updateWordCount];
#endif
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	mTermPaper.abstract = textView.text;
}

#pragma mark UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)aTextView
{
	[self updateWordCount];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)updateWordCount
{
	NSArray *words = [textView.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSUInteger count = words.count;
	if (((NSString *)[words objectAtIndex:0]).length == 0) --count;
	if (count > 0 && ((NSString *)[words lastObject]).length == 0) --count;
	wordCountLabel.text = [NSString stringWithFormat:@"Word count: %lu (recommended 150-250)", (unsigned long)count];
}

@end


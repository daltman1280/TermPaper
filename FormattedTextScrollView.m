//
//  FormattedTextScrollView.m
//  TermPaper
//
//  Created by daltman on 7/15/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "FormattedTextScrollView.h"

@implementation FormattedTextScrollView


//	Responsible for managing the three instances of FormattedTextTileView, modifying their frames, visibility, pageNumberToDraw. The objective is to
//	insure that their are always the appropriately positioned FormattedTextTileView to make the UIScrollView's visible content area up to date.

- (void)layoutSubviews {
    [super layoutSubviews];
	if (self.contentSize.height == 0) return;																						// no pages to display
	int firstNeededPageNumber = MAX((self.bounds.origin.y / (PAPER_HEIGHT + PAPER_SPACING)) + 1, 1);
	int lastNeededPageNumber = MIN(((self.bounds.origin.y+self.bounds.size.height) / (PAPER_HEIGHT + PAPER_SPACING)) + 1, (self.contentSize.height / (PAPER_HEIGHT + PAPER_SPACING)) + 1);
	// if there are any missing tiles, re-use a tile that's not currently visible
	for (int i=firstNeededPageNumber; i<=lastNeededPageNumber; ++i) {							// check every needed tile position
		if (tileView0.pageNumberToDraw != i && tileView1.pageNumberToDraw != i && tileView2.pageNumberToDraw != i) {				// none of the tiles is the current row
			if (tileView0.pageNumberToDraw < firstNeededPageNumber || tileView0.pageNumberToDraw > lastNeededPageNumber) {			// is this tile visible? No? Then use it
				tileView0.mode = singlePageMode;
				tileView0.pageNumberToDraw = i;
				tileView0.frame = CGRectMake(0, (i-1)*(PAPER_HEIGHT+PAPER_SPACING), tileView0.frame.size.width, tileView0.frame.size.height);
				tileView0.hidden = NO;
				[tileView0 setNeedsDisplay];
			} else if (tileView1.pageNumberToDraw < firstNeededPageNumber || tileView1.pageNumberToDraw > lastNeededPageNumber) {
				tileView1.mode = singlePageMode;
				tileView1.pageNumberToDraw = i;
				tileView1.frame = CGRectMake(0, (i-1)*(PAPER_HEIGHT+PAPER_SPACING), tileView1.frame.size.width, tileView1.frame.size.height);
				tileView1.hidden = NO;
				[tileView1 setNeedsDisplay];
			} else if (tileView2.pageNumberToDraw < firstNeededPageNumber || tileView2.pageNumberToDraw > lastNeededPageNumber) {
				tileView2.mode = singlePageMode;
				tileView2.pageNumberToDraw = i;
				tileView2.frame = CGRectMake(0, (i-1)*(PAPER_HEIGHT+PAPER_SPACING), tileView2.frame.size.width, tileView2.frame.size.height);
				tileView2.hidden = NO;
				[tileView2 setNeedsDisplay];
			} else
				NSAssert(NO, @"Error in FormattedTextScrollView tiling.");
		}
	}
}

- (void)setContentSize:(CGSize)size
{
    [tileContainerView setFrame:CGRectMake(0, 0, size.width, size.height)];
	[super setContentSize:size];
    [self setNeedsLayout];
}

- (void)invalidate
{
	tileView0.pageNumberToDraw = -1;
	tileView1.pageNumberToDraw = -1;
	tileView2.pageNumberToDraw = -1;
	tileView0.hidden = YES;															// might not use a given file, for short documents
	tileView1.hidden = YES;
	tileView2.hidden = YES;
}

@end


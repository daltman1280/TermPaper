//
//  PlainPaperScrollView.m
//  TermPaper
//
//  Created by daltman on 7/14/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "PlainTextScrollView.h"

//	Responsible for scrolling the plain text UIScrollView, and for managing the tiling of BackgroundPaperTileView

@implementation PlainTextScrollView

- (void)setContentSize:(CGSize)size
{
    [tileContainerView setFrame:CGRectMake(0, 0, size.width, size.height)];
	[super setContentSize:size];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
	// paperView0 and paperView1 are fixed at the top of the scrolling view
	// reposition paperView2 and paperView3, which tile the remainder of the scrollview, as needed
	if (self.bounds.origin.y > TILE_SIZE) {
		int row = self.bounds.origin.y / TILE_SIZE;										// specifies the vertical row of the first tile
		paperView2.frame = CGRectMake(0, row * TILE_SIZE, TILE_SIZE, TILE_SIZE);
		paperView3.frame = CGRectMake(0, (row+1) * TILE_SIZE, TILE_SIZE, TILE_SIZE);	// second tile below first
	}
}


@end


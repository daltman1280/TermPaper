//
//  FormattedTextTileView.m
//  TermPaper
//
//  Created by daltman on 7/15/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "FormattedTextTileView.h"


@implementation FormattedTextTileView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	if (delegate.numberOfPages > 0) {
		if (pageNumberToDraw <= delegate.numberOfPages)
			delegate.pageNumberToDraw = pageNumberToDraw;
		else
			NSAssert1(NO, @"Illegal page number to draw: %d", pageNumberToDraw);
		[delegate drawPage];
	}
}


@end


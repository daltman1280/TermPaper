//
//  PaperView.m
//  TermPaper
//
//  Created by daltman on 6/16/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "BackgroundPaperTileView.h"
#import "TermPaperAppDelegate.h"

#define verticalPaperOffset 6
#define verticalBounce 1024

@implementation BackgroundPaperTileView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	// paper background
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, NO);
	// yellow
	CGContextSetFillColorWithColor(context, [UIColor colorWithRed:241./256. green:238./256. blue:185./256. alpha:1.0].CGColor);
	CGContextFillRect(context, rect);
	CGContextTranslateCTM(context, 0, -self.frame.origin.y);				// to account for position of tile
	// horizontal rules
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:205./256. green:205./256. blue:143./256. alpha:1.0].CGColor);
	for (int i=64; i<self.frame.origin.y+self.frame.size.height; i+=22) {
		CGContextMoveToPoint(context, 0, i+verticalPaperOffset);
		CGContextAddLineToPoint(context, self.frame.size.width, i+verticalPaperOffset);
		CGContextStrokePath(context);
	}
	// vertical rules
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:183./256. green:153./256. blue:112./256. alpha:1.0].CGColor);
	for (int i=64; i<=66; i+=2) {
		CGContextMoveToPoint(context, i, -verticalBounce);
		CGContextAddLineToPoint(context, i, self.frame.origin.y+self.frame.size.height);
		CGContextStrokePath(context);
	}
}


@end


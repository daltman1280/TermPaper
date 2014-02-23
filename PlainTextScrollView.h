//
//  PlainPaperScrollView.h
//  TermPaper
//
//  Created by daltman on 7/14/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackgroundPaperTileView.h"

@interface PlainTextScrollView : UIScrollView {
	IBOutlet BackgroundPaperTileView*	paperView0;
	IBOutlet BackgroundPaperTileView*	paperView1;
	IBOutlet BackgroundPaperTileView*	paperView2;
	IBOutlet BackgroundPaperTileView*	paperView3;
	
	IBOutlet UIView*					tileContainerView;
}

@end


//
//  FormattedTextScrollView.h
//  TermPaper
//
//  Created by daltman on 7/15/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormattedTextTileView.h"

@interface FormattedTextScrollView : UIScrollView {
	IBOutlet UIView*					tileContainerView;
	IBOutlet FormattedTextTileView*		tileView0;
	IBOutlet FormattedTextTileView*		tileView1;
	IBOutlet FormattedTextTileView*		tileView2;
}

- (void)invalidate;

@end


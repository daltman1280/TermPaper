//
//  FormattedTextTileView.h
//  TermPaper
//
//  Created by daltman on 7/15/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormattedTextView.h"

#define PAGE_TILE_HEIGHT 

@interface FormattedTextTileView : FormattedTextView {
	IBOutlet FormattedTextView*						delegate;
}

@property (nonatomic, strong) FormattedTextView *delegate;

@end


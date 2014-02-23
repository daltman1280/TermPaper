//
//  FormattedTextView.h
//  TermPaper
//
//  Created by daltman on 6/25/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TermPaperModel.h"
#import "CitationFormatter.h"
#import <CoreText/CoreText.h>

#define PAPER_HEIGHT 11*72
#define PAPER_SPACING 15

static NSString *kDWPDFCompleteNotificationName = @"DWPDFCompleteNotificationName";
static NSString *kDWFormattedViewCompleteNotificationName = @"DWFormattedViewCompleteNotificationName";

#pragma unused (kDWPDFCompleteNotificationName, kDWFormattedViewCompleteNotificationName)

typedef enum {
	leftJust,
	rightJust,
	centerJust,
	firstIndent,
	firstHanging
} stylePresetEnum;

typedef enum {
	uninitializedMode,
	singlePageMode,															// draw a single page, using ivars from multiPageMode
	multiPageMode,															// draw entire document, save info in ivars
	PDFMode																	// draw entire document in PDF context
} drawRectMode;

@interface FormattedTextView : UIView {
	drawRectMode					mode;									// must be initialized
	//	these are all initialized in multiPageMode
	float							calculatedHeight;
	TermPaperModel*					model;
	int								numberOfPages;							// in entire paper
	NSMutableArray*					frameForPage;							// cached frame for each page
	//	for use with singlePageMode
	int								pageNumberToDraw;						// draw a single page
}

- (void)assignParagraphAttributesToString:(CFMutableAttributedStringRef)attrString stylePreset:(stylePresetEnum)stylePreset;
- (void)initializeStringWithContent:(CFMutableAttributedStringRef)attrString;
- (void)drawPage;

@property (nonatomic) float calculatedHeight;
@property (nonatomic) int numberOfPages, pageNumberToDraw;
@property (nonatomic) drawRectMode mode;

@end


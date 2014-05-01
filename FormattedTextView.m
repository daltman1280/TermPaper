//
//  FormattedTextView.m
//  TermPaper
//
//  Created by daltman on 6/25/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "FormattedTextView.h"
#import <CoreText/CoreText.h>
#import <Crashlytics/Crashlytics.h>

#define FONT_SIZE [model.fontSize isEqualToString:@"Large"] ? 14 : [model.fontSize isEqualToString:@"Medium"] ? 12 : 10

typedef enum {
	processingAPATitle,
	processingAPAAbstract,
	processingContent,
	processingCitations
}	processingModeEnum;

@implementation FormattedTextView

@synthesize calculatedHeight;
@synthesize numberOfPages, pageNumberToDraw;
@synthesize mode;

- (CTFontRef)createDefaultFont
{
	if ([model.format isEqualToString:@"APA"])
		return CTFontCreateWithName((CFStringRef) @"TimesNewRomanPSMT", 12, NULL);
	else
		return  CTFontCreateWithName((__bridge CFStringRef) ([model.fontName isEqualToString:@"Times New Roman"] ? @"TimesNewRomanPSMT" : model.fontName), FONT_SIZE, NULL);
}

typedef enum {
	kPlain,
	kBold,
	kItalic
} fontStyleEnum;

/*
 Create a font with the requested traits (bold, italic), in the correct font (name and size).
 */

- (UIFont *)createStyledFont:(fontStyleEnum)style
{
	float fontSize = ([model.format isEqualToString:@"APA"]) ? 12 : FONT_SIZE;
	UIFontDescriptorSymbolicTraits trait = (style == kBold) ? UIFontDescriptorTraitBold : (style == kItalic) ? UIFontDescriptorTraitItalic : 0;
	UIFontDescriptor *fontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:@{ UIFontDescriptorFamilyAttribute : model.fontName, UIFontDescriptorTraitsAttribute : @{UIFontSymbolicTrait: @(trait)} }];
	UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:fontSize];
	return font;
}

- (void)replaceStringWithAPATitlePage:(CFMutableAttributedStringRef)attrString
{
	CFAttributedStringReplaceString(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), (CFStringRef) model.title);
	CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), (CFStringRef) @"\n\n\n\n\n\n");
	NSString *author = model.author.length > 0 ? model.author : @"<author>";
	NSString *institution = (model.institution && model.institution.length > 0) ? model.institution : @"<institution>";
	CFAttributedStringReplaceString(attrString, CFRangeMake(CFAttributedStringGetLength(attrString), 0), (CFStringRef) [NSString stringWithFormat:@"\n%@\n%@", author, institution]);
	CTFontRef font = [self createDefaultFont];
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, font);
	[self assignParagraphAttributesToString:attrString stylePreset:centerJust withLineSpacing:NO];
	CFRelease(font);
}

- (void)replaceStringWithAPAAbstract:(CFMutableAttributedStringRef)attrString
{
	CFAttributedStringReplaceString(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), (CFStringRef) @"Abstract\n");
	[self assignParagraphAttributesToString:attrString stylePreset:centerJust withLineSpacing:NO];
	CFMutableAttributedStringRef abstractString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	CFAttributedStringReplaceString(abstractString, CFRangeMake(0, 0), ([model.format isEqualToString:@"APA"] && model.insertDoubleSpaces) ? (__bridge CFStringRef) [model.abstract insertDoubleSpaces] : (__bridge CFStringRef) model.abstract);
	[self assignParagraphAttributesToString:abstractString stylePreset:leftJust withLineSpacing:NO];
	CFAttributedStringReplaceAttributedString(attrString, CFRangeMake(CFAttributedStringGetLength(attrString), 0), abstractString);
	CTFontRef font = [self createDefaultFont];
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, font);
	if (model.keywords && model.keywords.length > 0) {
		CFMutableAttributedStringRef keywordTitleString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		CFAttributedStringReplaceString(keywordTitleString, CFRangeMake(0, 0), (CFStringRef) @"\nKeywords: ");
		CFAttributedStringReplaceString(keywordTitleString, CFRangeMake(CFAttributedStringGetLength(keywordTitleString), 0), (CFStringRef) model.keywords);
		CFAttributedStringSetAttribute(keywordTitleString, CFRangeMake(0, CFAttributedStringGetLength(keywordTitleString)), kCTFontAttributeName, font);
		[self assignParagraphAttributesToString:keywordTitleString stylePreset:firstIndent withLineSpacing:NO];
		CTFontRef fontItalic = CTFontCreateWithName((CFStringRef) @"TimesNewRomanPS-ItalicMT", 12, NULL);
		CFAttributedStringSetAttribute(keywordTitleString, CFRangeMake(0, CFStringGetLength((CFStringRef) @"\nKeywords: ")), kCTFontAttributeName, fontItalic);
		CFAttributedStringReplaceAttributedString(attrString, CFRangeMake(CFAttributedStringGetLength(attrString), 0), keywordTitleString);
		CFRelease(fontItalic);
		CFRelease(keywordTitleString);
	}
	CFRelease(font);
	CFRelease(abstractString);
}

- (void)replaceWithCitationsText:(CFMutableAttributedStringRef)attrContentString
{
	CFMutableAttributedStringRef citationsAttrString = [[CitationFormatter sharedFormatter] attributedString];		// get attributed string of citations
	// make a centered title, with correct font
	CFMutableAttributedStringRef attrTitleString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	CFAttributedStringReplaceString(attrTitleString, CFRangeMake(0, 0), ([model.format isEqualToString:@"MLA"]) ? (CFStringRef) @"Works Cited\n" : (CFStringRef) @"References\n");
	CTFontRef font = [self createDefaultFont];
	CFAttributedStringSetAttribute(attrTitleString, CFRangeMake(0, CFAttributedStringGetLength(attrTitleString)), kCTFontAttributeName, font);
	[self assignParagraphAttributesToString:attrTitleString stylePreset:centerJust withLineSpacing:NO];
	// make citations hanging indents
	[self assignParagraphAttributesToString:citationsAttrString stylePreset:firstHanging withLineSpacing:NO];
	// replace with contents of citations
	CFAttributedStringReplaceAttributedString(attrContentString, CFRangeMake(0, CFAttributedStringGetLength(attrContentString)), (CFMutableAttributedStringRef)citationsAttrString);
	// insert title at beginning of citation text
	CFAttributedStringReplaceAttributedString(attrContentString, CFRangeMake(0, 0), (CFMutableAttributedStringRef)attrTitleString);
	CFRelease(attrTitleString);
	CFRelease(font);
}

- (void)assignParagraphAttributesToString:(CFMutableAttributedStringRef)attrString stylePreset:(stylePresetEnum)stylePreset withLineSpacing:(BOOL)withLineSpacing
{
	CTParagraphStyleSetting setting[3];
	CTTextAlignment align;
	CGFloat indent = 33.0;															// in points, for indentation
	switch (stylePreset) {
		case leftJust:
			align = kCTLeftTextAlignment;
			setting[0].spec = kCTParagraphStyleSpecifierAlignment;
			setting[0].valueSize = sizeof(CTTextAlignment);
			setting[0].value = (void *) &align;
			break;
		case centerJust:
			align = kCTCenterTextAlignment;
			setting[0].spec = kCTParagraphStyleSpecifierAlignment;
			setting[0].valueSize = sizeof(CTTextAlignment);
			setting[0].value = (void *) &align;
			break;
		case rightJust:
			align = kCTRightTextAlignment;
			setting[0].spec = kCTParagraphStyleSpecifierAlignment;
			setting[0].valueSize = sizeof(CTTextAlignment);
			setting[0].value = (void *) &align;
			break;
		case firstIndent:
			setting[0].spec = kCTParagraphStyleSpecifierFirstLineHeadIndent;		// paragraph indentation
			setting[0].valueSize = sizeof(CGFloat);
			setting[0].value = (void *) &indent;
			break;
		case firstHanging:
			setting[0].spec = kCTParagraphStyleSpecifierHeadIndent;					// paragraph hanging indentation
			setting[0].valueSize = sizeof(CGFloat);
			setting[0].value = (void *) &indent;
			break;
	}
	// always set the line spacing
	CGFloat lineHeightMultiple = ([model.format isEqualToString:@"APA"] && model.insertDoubleSpaces && withLineSpacing) ? 3.0 : 2.0;
	setting[1].spec = kCTParagraphStyleSpecifierLineHeightMultiple;					// line spacing
	setting[1].valueSize = sizeof(CGFloat);
	setting[1].value = (void *) &lineHeightMultiple;
	// add a tab setting to the paragraph, right aligned, at the right margin, for use with APA-style headings
	CTTextTabRef textTab = CTTextTabCreate(kCTRightTextAlignment, 72 * 6.5, NULL);
	CFArrayRef array = CFArrayCreate(NULL, (void *) &textTab, 1, NULL);
	CTTextTabGetAlignment(textTab);
	setting[2].spec = kCTParagraphStyleSpecifierTabStops;
	setting[2].valueSize = sizeof(CFArrayRef);
	setting[2].value = (void *) &array;
	CTParagraphStyleRef style = CTParagraphStyleCreate(setting, 3);
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTParagraphStyleAttributeName, style);
	CFRelease(style);
	CFRelease(array);
}

- (CFAttributedStringRef)allocHeader:(int)pageNumber
{
	if ([model.format isEqualToString:@"MLA"]) {									// MLA format
		CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		NSString *headerTitle = model.headerTitle.length > 0 ? model.headerTitle : @"<header title>";
		CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), (CFStringRef) [NSString stringWithFormat:@"%@ %d\n", headerTitle, pageNumber]);
		[self assignParagraphAttributesToString:attrString stylePreset:rightJust withLineSpacing:NO];
		// create a font and add it as an attribute to the string
		CTFontRef font = [self createDefaultFont];
		CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, font);
		CFRelease(font);
		return attrString;
	} else {																		// APA format
		CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		NSString *headerTitle = (model.shortTitle.length > 0) ? [model.shortTitle uppercaseString] : [model.title uppercaseString];
		CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), (CFStringRef) [NSString stringWithFormat:@"Running head: %@\t%d\n", headerTitle, pageNumber]);
		[self assignParagraphAttributesToString:attrString stylePreset:leftJust withLineSpacing:NO];
		// create a font and add it as an attribute to the string
		CTFontRef font = [self createDefaultFont];
		CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, font);
		CFRelease(font);
		return attrString;
	}
}

//	Inserts the paper's block heading text (author, title, etc.) into the content (MLA only)

- (void)insertPaperInfoText:(CFMutableAttributedStringRef)attrContentString
{
	NSString *author = model.author.length > 0 ? model.author : @"<author>";
	NSString *instructor = model.instructor.length > 0 ? model.instructor : @"<instructor>";
	NSString *course = model.course.length > 0 ? model.course : @"<course>";
	NSString *date = model.date.length > 0 ? model.date : @"<date>";
	NSString *title = model.title.length > 0 ? model.title : @"<title>";
	CFMutableAttributedStringRef attrHeadingString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	NSString *blockHeading = [author stringByAppendingFormat:@"\n%@\n%@\n%@\n", instructor, course, date];
	CFAttributedStringReplaceString(attrHeadingString, CFRangeMake(0, 0), (CFStringRef) blockHeading);
	[self assignParagraphAttributesToString:attrHeadingString stylePreset:leftJust withLineSpacing:NO];
	// make the title centered
	CFMutableAttributedStringRef attrTitleString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	CFAttributedStringReplaceString(attrTitleString, CFRangeMake(0, 0), (CFStringRef) [NSString stringWithFormat:@"%@\n", title]);
	[self assignParagraphAttributesToString:attrTitleString stylePreset:centerJust withLineSpacing:NO];
	// insert the title into attrTitleString
	CFAttributedStringReplaceAttributedString(attrTitleString, CFRangeMake(0, 0), attrHeadingString);
	// create a font and add it as an attribute to the string
	CTFontRef font = [self createDefaultFont];
	CFAttributedStringSetAttribute(attrTitleString, CFRangeMake(0, CFAttributedStringGetLength(attrTitleString)), kCTFontAttributeName, font);
	// insert result into content
	CFAttributedStringReplaceAttributedString(attrContentString, CFRangeMake(0, 0), attrTitleString);
	CFRelease(attrTitleString);
	CFRelease(attrHeadingString);
	CFRelease(font);
}

- (void)initializeStringWithContent:(CFMutableAttributedStringRef)attrString
{
	CFAttributedStringReplaceAttributedString(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), (CFAttributedStringRef) model.attributedContent);
	// paragraph style
	[self assignParagraphAttributesToString:attrString stylePreset:firstIndent withLineSpacing:YES];
	// create a font and add it as an attribute to the string
	CTFontRef font = [self createDefaultFont];												// based on the document setting
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, font);
	[self applyFontTraitsFromDocument:attrString];
	// in APA, title goes on first content page
	if ([model.format isEqualToString:@"APA"]) {
		NSString *title = model.title.length > 0 ? model.title : @"<title>";
		NSString *titleLine = [title stringByAppendingString:@"\n"];
		CFMutableAttributedStringRef attrTitleString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		CFAttributedStringReplaceString(attrTitleString, CFRangeMake(0, 0), (CFStringRef) titleLine);
		[self assignParagraphAttributesToString:attrTitleString stylePreset:centerJust withLineSpacing:NO];
		CFAttributedStringReplaceAttributedString(attrString, CFRangeMake(0, 0), attrTitleString);
		CFRelease(attrTitleString);
	}
	CFRelease(font);
}

/*
 Apply the symbolic traits (bold, italic) from model.attributedContent to attrString.
 
 Important: this assumes that the underlying strings are in sync, so this must be called before modifying the string contents of attrString, or the font settings will be offset.
 */

- (void)applyFontTraitsFromDocument:(CFMutableAttributedStringRef)attrString
{
	UIFont *boldFont = [self createStyledFont:kBold];
	UIFont *italicFont = [self createStyledFont:kItalic];
	NSAttributedString *string = model.attributedContent;
	NSMutableAttributedString *contentString = (__bridge NSMutableAttributedString *) attrString;
	NSUInteger length = string.length;
	NSRange effectiveRange = NSMakeRange(0, 0);
	id attributeValue;
	while (NSMaxRange(effectiveRange) < length) {
		attributeValue = [string attribute:NSFontAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
		UIFont *font = (UIFont *) attributeValue;
		UIFontDescriptor *descriptor = font.fontDescriptor;
		if (descriptor.symbolicTraits & UIFontDescriptorTraitItalic)
			[contentString addAttribute:NSFontAttributeName value:italicFont range:effectiveRange];
		else if (descriptor.symbolicTraits & UIFontDescriptorTraitBold)
			[contentString addAttribute:NSFontAttributeName value:boldFont range:effectiveRange];
	}
}

//	Draws a single page, indicated by pageNumberToDraw. Uses cached CTFrameRef, prepared in drawRect.
//	The FormattedTextView instances that are owned by FormattedTextTileView instances, have this method called to draw their page.

- (void)drawPage
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	// iPhoneOS graphics context is flipped. Graphics assumes lower left origin.
	CGContextScaleCTM(context, 1, -1);
	CGContextTranslateCTM(context, 0, -PAPER_HEIGHT);									// move origin down for next page
	// for text
	CGContextSetShouldAntialias(context, YES);
	// create a rectangle for the text body
	CGRect pageRect = CGRectMake(72, 72, 72*6.5, 72*9);									// for 8.5 * 11 with 1" margins
	// create a rectangle for the header
	CGFloat leading = [UIFont fontWithName:[model.fontName isEqualToString:@"Times New Roman"] ? @"TimesNewRomanPSMT" : model.fontName size:FONT_SIZE].leading;		// TODO: why does CTFontGetLeading() return zero?
	CGMutablePathRef headerPathRef = CGPathCreateMutable();
	CGRect headerRect = CGRectMake(72, 72+pageRect.size.height, 72*6.5, 2 * leading);	// header rect sits on top of pageRect, height is 2 lines of text
	CGPathAddRect(headerPathRef, NULL, headerRect);
	// draw the page background
	UIBezierPath *pageBackground = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 72*8.5, 72*11)];
	CGContextSetGrayFillColor(context, 1, 1);
	[pageBackground fill];
	// draw the header
	CFAttributedStringRef header = [self allocHeader:pageNumberToDraw];
	CTFramesetterRef headerFramesetter = CTFramesetterCreateWithAttributedString(header);
	CFRelease(header);
	CTFrameRef headerFrame = CTFramesetterCreateFrame(headerFramesetter, CFRangeMake(0, 0), (CGPathRef) headerPathRef, NULL);
	CFRelease(headerPathRef);
	if (pageNumberToDraw > 1 || model.headerOnFirst)
		CTFrameDraw(headerFrame, context);
	CFRelease(headerFrame);
	CFRelease(headerFramesetter);
	// Get the cached frame for the formatted text and draw it into the graphics context
	if (pageNumberToDraw <= frameForPage.count && pageNumberToDraw > 0) {
		CTFrameRef frame = [[frameForPage objectAtIndex:pageNumberToDraw-1] pointerValue];
		CTFrameDraw(frame, context);
	} else
		CLSLog(@"Illegal pageNumberToDraw = %d", pageNumberToDraw);
}

//	Does the text imaging for all pages in the document, both for Core Text and PDF. For Core Text layout, caches the CTFrameRef for each
//	page, so it can be efficiently drawn as requested by FormattedTextTileView instances.
//	Executed by the singleton, owned by the root controller, as needed.

- (void)drawRect:(CGRect)rect {
	NSAssert(mode, @"Uninitialized mode");
	if (mode == singlePageMode) {
		[self drawPage];
		return;
	}
	// initialization
	model = [TermPaperModel activeTermPaper];
    // Drawing code
	if (!model || !model.content) return;
	if ([self isHidden] && mode != PDFMode) return;
	if (mode == PDFMode) {
		NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *pdfFile = [documentsFolder stringByAppendingFormat:@"/%@.pdf", model.name];
		BOOL success = UIGraphicsBeginPDFContextToFile(pdfFile, CGRectZero, nil);
		CLSLog(@"success = %d, file = %@", success, pdfFile);
	}
	CGContextRef context = UIGraphicsGetCurrentContext();
	// iPhoneOS graphics context is flipped. Graphics assumes lower left origin.
	CGContextScaleCTM(context, 1, -1);
	// for text
	CGContextSetShouldAntialias(context, YES);
	// create a rectangle for the text body
	CGMutablePathRef textFrame = CGPathCreateMutable();
	CGRect pageRect = CGRectMake(72, 72, 72*6.5, 72*9);									// for 8.5 * 11 with 1" margins
	CGPathAddRect(textFrame, NULL, pageRect);
	// create a rectangle for the header
	CGFloat leading = [UIFont fontWithName:[model.fontName isEqualToString:@"Times New Roman"] ? @"TimesNewRomanPSMT" : model.fontName size:FONT_SIZE].leading;		// TODO: why does CTFontGetLeading() return zero?
	CGMutablePathRef headerFrame = CGPathCreateMutable();
	CGRect headerRect = CGRectMake(72, 72+pageRect.size.height, 72*6.5, 2 * leading);	// header rect sits on top of pageRect, height is 2 lines of text
	CGPathAddRect(headerFrame, NULL, headerRect);
	// Initialize an attributed string.
	CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	if (frameForPage) {
		for (NSValue *value in frameForPage)
			CFRelease([value pointerValue]);
	}
	frameForPage = [[NSMutableArray alloc] init];
	
	calculatedHeight = 0;
	int pageNum = 1;
	processingModeEnum processingSection;
	for (processingSection = processingAPATitle; processingSection<=processingCitations; ++processingSection) {
		int startIndex = 0;															// current index in attributed string to be formatted
		if (processingSection == processingCitations) {								// processing citations, replace content text with citation text
			if (model.citations.count == 0 || model.citationPages == NO)
				break;																// no citations to format, don't make a page
			[CitationFormatter sharedFormatter].model = model;
			[CitationFormatter sharedFormatter].outputMode = modeAttributedText;
			[[CitationFormatter sharedFormatter] formatCitations];
			[self replaceWithCitationsText:attrString];
			if (model.contentPages) {
				// insert a paper break following content, before citations page(s)
				CGContextTranslateCTM(context, 0, -PAPER_SPACING);
				calculatedHeight += PAPER_SPACING;
			}
		} else if (processingSection == processingContent) {
			[self initializeStringWithContent:attrString];
			// insert paper title text in beginning of content text
			if ([model.format isEqualToString:@"MLA"])
				[self insertPaperInfoText:attrString];
			if (model.contentPages == NO)
				continue;
		} else if (processingSection == processingAPATitle) {
			if ([model.format isEqualToString:@"APA"] && model.contentPages == YES)
				[self replaceStringWithAPATitlePage:attrString];
			else
				continue;
		} else if (processingSection == processingAPAAbstract) {
			if ([model.format isEqualToString:@"APA"] && model.contentPages == YES)
				[self replaceStringWithAPAAbstract:attrString];
			else
				continue;
		}
		// Create the framesetter with the attributed string.
		CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
		for (; pageNum<=999; ++pageNum) {
			numberOfPages = pageNum;
			CGContextTranslateCTM(context, 0, -PAPER_HEIGHT);							// move origin down for next page
			calculatedHeight += PAPER_HEIGHT;
			// draw the page background
			UIBezierPath *pageBackground = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 72*8.5, 72*11)];
			CGContextSetGrayFillColor(context, 1, 1);
			if (mode != PDFMode)
				[pageBackground fill];
			if (mode == PDFMode)
				UIGraphicsBeginPDFPage();
			// draw the header
			CFAttributedStringRef header = [self allocHeader:pageNum];
			CTFramesetterRef headerframesetter = CTFramesetterCreateWithAttributedString(header);
			CFRelease(header);
			CTFrameRef headerFrameRef = CTFramesetterCreateFrame(headerframesetter, CFRangeMake(0, 0), (CGPathRef) headerFrame, NULL);
			if (pageNum > 1 || model.headerOnFirst) {
				if (mode == PDFMode) {
					CGContextSaveGState(context);
					CGContextTranslateCTM(context, 0, pageRect.origin.y); 
					CGContextScaleCTM(context, 1, -1); 
					CGContextTranslateCTM(context, 0, -(pageRect.origin.y + pageRect.size.height)); 
					CTFrameDraw(headerFrameRef, context);
					CGContextRestoreGState(context); 
				} else
					CTFrameDraw(headerFrameRef, context);
			}
			CFRelease(headerFrameRef);
			CFRelease(headerframesetter);
			// Create the frame for the formatted text and draw it into the graphics context
			CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(startIndex, 0), (CGPathRef) textFrame, NULL);
			if (mode == PDFMode) {
				CGContextSaveGState(context);
				CGContextTranslateCTM(context, 0, pageRect.origin.y); 
				CGContextScaleCTM(context, 1, -1); 
				CGContextTranslateCTM(context, 0, -(pageRect.origin.y + pageRect.size.height)); 
				CTFrameDraw(frame, context);
				CGContextRestoreGState(context); 
			} else
				CTFrameDraw(frame, context);
			CFRange visibleRange = CTFrameGetVisibleStringRange(frame);
			[frameForPage addObject:[NSValue valueWithPointer:frame]];
			startIndex += visibleRange.length;
			if (visibleRange.location + visibleRange.length >= CFAttributedStringGetLength(attrString)) {	// we're finished with this section
				++pageNum;																					// since it's not being incremented by the for loop
				break;
			}
			CGContextTranslateCTM(context, 0, -PAPER_SPACING);
			calculatedHeight += PAPER_SPACING;
		}
		CFRelease(framesetter);
	}
	if (mode == PDFMode) {
		UIGraphicsEndPDFContext();
		[[NSNotificationCenter defaultCenter] postNotificationName:kDWPDFCompleteNotificationName object:nil];
		mode = uninitializedMode;
	} else
		[[NSNotificationCenter defaultCenter] postNotificationName:kDWFormattedViewCompleteNotificationName object:nil];
	CFRelease(textFrame);
	CFRelease(headerFrame);
	CFRelease(attrString);
	if (!model.contentPages && !model.citationPages)
		self.numberOfPages = 0;
}


@end


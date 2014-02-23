//
//  DocXFormatter.m
//  TermPaper
//
//  Created by daltman on 11/12/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "TermPaperModel.h"
#import "CitationFormatter.h"
#import "DocXFormatter.h"

#define FONT_SIZE [model.fontSize isEqualToString:@"Large"] ? 14 : [model.fontSize isEqualToString:@"Medium"] ? 12 : 10

@implementation DocXFormatter

+ (DocXFormatter *)sharedFormatter
{
	static DocXFormatter *sharedFormatter = nil;
	if (sharedFormatter == nil) {
		sharedFormatter = [[DocXFormatter alloc] init];
	}
	return sharedFormatter;
}

- (NSMutableString *)formattedDocument
{
	xmlString = [[NSMutableString alloc] init];
	model = [TermPaperModel activeTermPaper];
	fontSize = FONT_SIZE;
	fontSize *= 2;
	newPage = NO;
	[self document];
	return xmlString;
}

- (void)document
{
	[xmlString appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n<w:document xmlns:ve=\"http://schemas.openxmlformats.org/markup-compatibility/2006\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" xmlns:w10=\"urn:schemas-microsoft-com:office:word\" xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\">"];
	[self body];
	[xmlString appendString:@"</w:document>"];
}

- (void)body
{
	[xmlString appendString:@"<w:body>"];
	if ([model.format isEqualToString:@"APA"])
		[self APAPreamble];
	else
		[self MLAPreamble];
	[self title];
	[self content];
	if (model.citations.count != 0 && model.citationPages == YES) {
		[self page];
		if ([model.format isEqualToString:@"APA"])
			[self paragraph:@"References" alignment:@"center" indent:indentNone];
		else
			[self paragraph:@"Works Cited" alignment:@"center" indent:indentNone];
		[CitationFormatter sharedFormatter].model = model;
		[CitationFormatter sharedFormatter].outputMode = modeXML;
		[[CitationFormatter sharedFormatter] formatCitations];
		[xmlString appendString:[CitationFormatter sharedFormatter].xmlString];
	}
	[xmlString appendString:@"</w:body>"];
}

- (void)APAPreamble
{
	[self paragraph:nil alignment:@"center" indent:indentNone];
	[self paragraph:nil alignment:@"center" indent:indentNone];
	[self paragraph:nil alignment:@"center" indent:indentNone];
	[self paragraph:nil alignment:@"center" indent:indentNone];
	[self paragraph:nil alignment:@"center" indent:indentNone];
	[self paragraph:nil alignment:@"center" indent:indentNone];
	[self paragraph:model.title.length ? model.title : @"<title>" alignment:@"center" indent:indentNone];
	NSString *author = model.author.length > 0 ? model.author : @"<author>";
	NSString *institution = (model.institution && model.institution.length > 0) ? model.institution : @"<institution>";
	[self paragraph:author alignment:@"center" indent:indentNone];
	[self paragraph:institution alignment:@"center" indent:indentNone];
	[self page];
	[self paragraph:@"Abstract" alignment:@"center" indent:indentNone];
	[self paragraph:([model.format isEqualToString:@"APA"] && model.insertDoubleSpaces) ? [model.abstract insertDoubleSpaces] : model.abstract alignment:nil indent:indentNone];
	[self paragraphStart:nil indent:indentStandard];
	[self text:@"Keywords: " style:@"italic"];
	[self text:model.keywords style:nil];
	[self paragraphEnd];
	[self page];
}

- (void)MLAPreamble
{
	NSString *author = model.author.length > 0 ? model.author : @"<author>";
	NSString *instructor = model.instructor.length > 0 ? model.instructor : @"<instructor>";
	NSString *course = model.course.length > 0 ? model.course : @"<course>";
	NSString *date = model.date.length > 0 ? model.date : @"<date>";
	[self paragraph:author alignment:nil indent:indentNone];
	[self paragraph:instructor alignment:nil indent:indentNone];
	[self paragraph:course alignment:nil indent:indentNone];
	[self paragraph:date alignment:nil indent:indentNone];
}

- (void)title
{
	NSString *title = model.title.length > 0 ? model.title : @"<title>";
	[self paragraph:title alignment:@"center" indent:indentNone];
}

- (void)content
{
	NSArray *paragraphs = [([model.format isEqualToString:@"APA"] && model.insertDoubleSpaces) ? [model.content insertDoubleSpaces]: model.content componentsSeparatedByString:@"\n"];
	for (NSString *paragraph in paragraphs)
		[self paragraph:paragraph alignment:nil indent:indentStandard];
}

- (void)paragraph:(NSString *)content alignment:(NSString *)alignment indent:(indentEnum)indent
{
	[self paragraphStart:alignment indent:indent];
	[self text:content style:nil];
	[self paragraphEnd];
}

- (void)paragraphStart:(NSString *)alignment indent:(indentEnum)indent
{
	[xmlString appendString:@"<w:p>"];
	if (alignment && alignment.length > 0) {
		[xmlString appendString:@"<w:pPr><w:spacing w:after=\"0\" w:line=\"360\" w:lineRule=\"auto\"/>"];
		[xmlString appendFormat:@"<w:jc w:val=\"%@\"/>", alignment];
		[xmlString appendString:@"</w:pPr>"];
	} else if (indent == indentStandard) {
		[xmlString appendString:@"<w:pPr><w:spacing w:after=\"0\" w:line=\"360\" w:lineRule=\"auto\"/>"];
		[xmlString appendFormat:@"<w:ind w:firstLine=\"720\"/>"];
		[xmlString appendString:@"</w:pPr>"];
	} else if (indent == indentHanging) {
		[xmlString appendString:@"<w:pPr>"];
		[xmlString appendString:@"<w:spacing w:after=\"0\" w:line=\"360\" w:lineRule=\"auto\"/>"];
		[xmlString appendFormat:@"<w:ind w:left=\"720\" w:hanging=\"720\"/>"];
		[xmlString appendString:@"</w:pPr>"];
	} else {
		[xmlString appendString:@"<w:pPr><w:spacing w:after=\"0\" w:line=\"360\" w:lineRule=\"auto\"/>"];
		[xmlString appendFormat:@"<w:ind w:firstLine=\"0\"/>"];
		[xmlString appendString:@"</w:pPr>"];
	}
}

- (void)paragraphEnd
{
	[xmlString appendString:@"</w:p>"];
}

- (void)page
{
	newPage = YES;
}

- (void)text:(NSString *)content style:(NSString *)style
{
	[xmlString appendString:@"<w:r>"];
	[xmlString appendString:@"<w:rPr>"];
	[xmlString appendFormat:@"<w:rFonts w:ascii=\"%@\" w:hAnsi=\"%@\" w:cs=\"%@\"/>", model.fontName, model.fontName, model.fontName];
	[xmlString appendFormat:@"<w:sz w:val=\"%d\"/>", fontSize];
	[xmlString appendFormat:@"<w:sz-cs w:val=\"%d\"/>", fontSize];
	if ([style isEqualToString:@"italic"])
		[xmlString appendString:@"<w:i/>"];
	[xmlString appendString:@"</w:rPr>"];
	if (newPage) {
		[xmlString appendString:@"<w:br w:type=\"page\"/>"];
		newPage = NO;
	}
	if (content && content.length > 0) {
		[xmlString appendString:@"<w:t xml:space=\"preserve\">"];
		NSString *editedString = [content stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];	// XML predeclared character references
		editedString = [editedString stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
		editedString = [editedString stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
		editedString = [editedString stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
		editedString = [editedString stringByReplacingOccurrencesOfString:@"\'" withString:@"&apos;"];
		[xmlString appendFormat:@"%s</w:t>", [editedString UTF8String]];					// all character codes beyond basic latin replaced with UTF-8 escape sequences
	} else
		[xmlString appendString:@"<w:t xml:space=\"preserve\"/>"];
	[xmlString appendString:@"</w:r>"];
}

@end


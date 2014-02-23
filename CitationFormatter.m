//
//  CitationFormatter.m
//  TermPaper
//
//  Created by daltman on 7/5/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "CitationFormatter.h"
#import "DocXFormatter.h"
#import <CoreText/CoreText.h>
#import <objc/runtime.h>

#define FONT_SIZE [model.fontSize isEqualToString:@"Large"] ? 14 : [model.fontSize isEqualToString:@"Medium"] ? 12 : 10

#pragma mark TODO: fix this

static CitationFormatter *gSharedFormatter = [[CitationFormatter alloc] init];

@implementation CitationFormatter

@synthesize model, citation, previousAuthor, outputMode, xmlString;

- (id)init
{
	if (self = [super init]) {
		if (gSharedFormatter == 0)
			gSharedFormatter = self;
		attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		xmlString = [[NSMutableString alloc] init];
		return self;
	}
	return nil;
}

+ (CitationFormatter *)sharedFormatter
{
	return gSharedFormatter;
}

#pragma mark Output functions
#pragma mark -

//	Just apply the current font setting

- (void)plainText:(NSString *)input
{
	if (outputMode == modeAttributedText) {
		CFMutableAttributedStringRef tmpAttrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		CFAttributedStringReplaceString(tmpAttrString, CFRangeMake(0, 0), (CFStringRef)input);
		CTFontRef font;
		if ([model.format isEqualToString:@"MLA"])
			font = CTFontCreateWithName((__bridge CFStringRef) ([model.fontName isEqualToString:@"Times New Roman"] ? @"TimesNewRomanPSMT" : model.fontName), FONT_SIZE, NULL);
		else
			font = CTFontCreateWithName((CFStringRef) @"TimesNewRomanPSMT", 12, NULL);
		CFAttributedStringSetAttribute(tmpAttrString, CFRangeMake(0, CFAttributedStringGetLength(tmpAttrString)), kCTFontAttributeName, font);
		CFAttributedStringReplaceAttributedString(attrString, CFRangeMake(CFAttributedStringGetLength(attrString), 0), (CFMutableAttributedStringRef)tmpAttrString);
		CFRelease(tmpAttrString);
		CFRelease(font);
	} else {
		[[DocXFormatter sharedFormatter] text:input style:nil];
	}
}

//	Append a period/space to text

- (void)plainTextPeriod:(NSString *)input
{
	if ([[NSCharacterSet punctuationCharacterSet] characterIsMember:[input characterAtIndex:input.length-1]])
		[self plainText:[input stringByAppendingString:@" "]];
	else
		[self plainText:[input stringByAppendingString:@". "]];
}

//	Italicize after appending period/space

- (void)italicizedTitle:(NSString *)input
{
	if ([[NSCharacterSet punctuationCharacterSet] characterIsMember:[input characterAtIndex:input.length-1]])
		[self italicizedText:[input stringByAppendingString:@" "]];
	else
		[self italicizedText:[input stringByAppendingString:@". "]];
}

//	Just apply italics and font setting

- (void)italicizedText:(NSString *)input
{
	if (outputMode == modeAttributedText) {
		CFMutableAttributedStringRef tmpAttrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		CFAttributedStringReplaceString(tmpAttrString, CFRangeMake(0, 0), (CFStringRef)input);
		NSString *italicFontname = [NSString stringWithFormat:@"%@%@", [model.fontName isEqualToString:@"Times New Roman"] ? @"TimesNewRomanPS-ItalicMT" : model.fontName, [model.fontName isEqualToString:@"Helvetica"] ? @" Oblique" : ![model.fontName isEqualToString:@"Times New Roman"] ? @" Italic" : @""];
		CTFontRef font;
		if ([model.format isEqualToString:@"MLA"])
			font = CTFontCreateWithName((__bridge CFStringRef) italicFontname, FONT_SIZE, NULL);
		else
			font = CTFontCreateWithName((CFStringRef) @"TimesNewRomanPS-ItalicMT", 12, NULL);
		CFAttributedStringSetAttribute(tmpAttrString, CFRangeMake(0, CFAttributedStringGetLength(tmpAttrString)), kCTFontAttributeName, font);
		CFAttributedStringReplaceAttributedString(attrString, CFRangeMake(CFAttributedStringGetLength(attrString), 0), (CFMutableAttributedStringRef)tmpAttrString);
		CFRelease(tmpAttrString);
		CFRelease(font);
	} else {
		[[DocXFormatter sharedFormatter] text:input style:@"italic"];
	}
}

//	Apply quotes to input with appended period, then append space

- (void)quotedTitle:(NSString *)input
{
	if ([[NSCharacterSet punctuationCharacterSet] characterIsMember:[input characterAtIndex:input.length-1]])
		[self plainText:[NSString stringWithFormat:@"\"%@\" ", input]];
	else
		[self plainText:[NSString stringWithFormat:@"\"%@.\" ", input]];
}

//	Just append newline character

- (void)newline
{
	[self plainText:@"\n"];
}

#pragma mark -

/*
 Entries which are repeats of author's name of previous entries should have their names converted.
 */

- (NSString *)checkPreviousAuthor:(NSString *)currentAuthor
{
	if ([currentAuthor isEqualToString:previousAuthor])
		currentAuthor = @"---.";
	self.previousAuthor = currentAuthor;
	return currentAuthor;
}

- (void)formatCitations
{
	if (outputMode == modeAttributedText)
		CFAttributedStringReplaceString(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), (CFStringRef)@"");
	// TODO: citations title
	NSArray *citations = model.citations;
	for (citation in citations) {
		[self initializeProperties];
		NSString *typeID = [citation objectForKey:@"TypeID"];
		if (outputMode == modeXML)
			[[DocXFormatter sharedFormatter] paragraphStart:nil indent:indentHanging];
		SEL selector = NSSelectorFromString(typeID);
		if (selector) [self performSelector:selector];
		if (outputMode == modeXML)
			[[DocXFormatter sharedFormatter] paragraphEnd];
		else
			[self newline];
	}
}

//	Iterate through the properties in the dictionary. Initialize matching instance variables (by name) with the property value.

- (void)initializeProperties
{
	Class cls = [self class];
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
	for (unsigned int ivarIndex = 0; ivarIndex < ivarCount; ivarIndex++) {
		if ([[NSString stringWithCString:ivar_getTypeEncoding(ivars[ivarIndex]) encoding:NSASCIIStringEncoding] isEqualToString:@"@\"NSString\""])
			object_setIvar(self, ivars[ivarIndex], @"");
	}
	NSArray *properties = [citation objectForKey:@"Properties"];
	for (NSDictionary *property in properties) {
		NSString *dictPropName = [property objectForKey:@"PropertyID"];
		for (unsigned int ivarIndex = 0; ivarIndex < ivarCount; ivarIndex++) {
			Ivar ivar = ivars[ivarIndex];
			NSString *propertyName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
			if ([propertyName isEqualToString:dictPropName])
				object_setIvar(self, ivar, [property objectForKey:@"Value"]);
		}
	}
	free(ivars);
}

#pragma mark -
#pragma mark citation TypeID selectors

//	The following selectors get their names from the TypeID key of the citation dictionary

- (void)singleAuthor {
	author = [self checkPreviousAuthor:author];
	[self plainTextPeriod:author];
	[self italicizedTitle:title];
	[self plainText:[NSString stringWithFormat:@"%@: %@, %@. Print.", placeOfPub, publisher, yearOfPub]];
}

- (void)multipleAuthors {
	author1 = [self checkPreviousAuthor:author1];
	NSString *authorList;
	if (author3 && author3.length > 0)
		authorList = [NSString stringWithFormat:@"%@, %@, and %@. ", author1, author2, author3];
	else
		authorList = [NSString stringWithFormat:@"%@, and %@. ", author1, author2];
	[self plainText:authorList];
	[self italicizedTitle:title];
	[self plainText:[NSString stringWithFormat:@"%@: %@, %@. Print.", placeOfPub, publisher, yearOfPub]];
}

- (void)corporate {
	[self plainText:[NSString stringWithFormat:@"%@. ", orgName]];
	[self italicizedTitle:title];
	[self plainText:[NSString stringWithFormat:@"%@: %@, %@. Print.", placeOfPub, publisher, yearOfPub]];
}

- (void)noAuthor {
	[self italicizedTitle:title];
	[self plainText:[NSString stringWithFormat:@"%@: %@, %@. Print.", placeOfPub, publisher, yearOfPub]];
}

- (void)translated {
	author = [self checkPreviousAuthor:author];
	[self plainTextPeriod:author];
	[self italicizedTitle:title];
	[self plainText:[NSString stringWithFormat:@"Trans. %@. ", translator]];
	[self plainText:[NSString stringWithFormat:@"%@: %@, %@. Print.", placeOfPub, publisher, yearOfPub]];
}

- (void)anthology {
	[self plainText:[editor stringByAppendingString:@", ed. "]];
	[self italicizedTitle:title];
	[self plainText:[NSString stringWithFormat:@"%@: %@, %@. Print.", placeOfPub, publisher, yearOfPub]];
}

- (void)articleInReference {
	author = [self checkPreviousAuthor:author];
	[self plainTextPeriod:author];
	[self quotedTitle:title];
	[self italicizedTitle:titleOfCollection];
	[self plainText:[NSString stringWithFormat:@" Ed. %@. %@: %@, %@. %@. Print.", editor, placeOfPub, publisher, yearOfPub, pageRange]];
}

- (void)introduction {
	authorOfIntro = [self checkPreviousAuthor:authorOfIntro];
	[self plainText:[NSString stringWithFormat:@"%@. %@. ", authorOfIntro, type]];
	[self italicizedTitle:title];
	if (author && author.length > 0)
		[self plainText:[NSString stringWithFormat:@"By %@. %@: %@, %@. %@. Print.", author, placeOfPub, publisher, yearOfPub, pageRange]];
	else
		[self plainText:[NSString stringWithFormat:@"%@: %@, %@. %@. Print.", placeOfPub, publisher, yearOfPub, pageRange]];
}

- (void)bible {
	[self italicizedTitle:specEd];
	[self plainText:[NSString stringWithFormat:@"Ed. %@. %@: %@, %@. Print.", editor, placeOfPub, publisher, yearOfPub]];
}

- (void)govPub {
	if (author && author.length > 0) {
		author = [self checkPreviousAuthor:author];
		[self plainTextPeriod:author];
	}
	[self plainText:[NSString stringWithFormat:@"%@. %@. ", entity, agency]];
	[self italicizedTitle:[NSString stringWithFormat:@"%@. ", title]];
	[self plainText:[NSString stringWithFormat:@"%@: %@, %@. Print.", placeOfPub, publisher, yearOfPub]];
}

- (void)pamphlet {
	if (author && author.length > 0) {
		author = [self checkPreviousAuthor:author];
		[self plainTextPeriod:author];
	}
	[self italicizedTitle:title];
	[self plainText:[NSString stringWithFormat:@"%@: %@, %@. Print.", placeOfPub, orgName, yearOfPub]];
}

- (void)thesis {
	author = [self checkPreviousAuthor:author];
	[self plainTextPeriod:author];
	[self italicizedTitle:title];
	[self plainText:[NSString stringWithFormat:@"%@. %@, %@. %@: %@, %@. Print.", type, institution, yearOfGrant, placeOfPub, publisher, yearOfPub]];
}

- (void)thesisUnpub {
	author = [self checkPreviousAuthor:author];
	[self plainTextPeriod:author];
	[self quotedTitle:title];
	[self plainText:[NSString stringWithFormat:@"%@ %@, %@. Print.", type, institution, yearOfGrant]];
}

- (void)magazineArticle {
	author = [self checkPreviousAuthor:author];
	[self plainTextPeriod:author];
	[self quotedTitle:titleOfArticle];
	[self italicizedText:titleOfPer];
	[self plainText:[NSString stringWithFormat:@" %@: %@. Print.", date, pageRange]];
}

- (void)newspaperArticle {
	author = [self checkPreviousAuthor:author];
	[self plainTextPeriod:author];
	[self quotedTitle:title];
	[self italicizedText:paperName];
	[self plainText:@" "];
	if (placeOfPub && placeOfPub.length > 0)
		[self plainText:[NSString stringWithFormat:@"[%@] ", placeOfPub]];
	[self plainText:[NSString stringWithFormat:@"%@: %@. Print.", date, pageRange]];
}

- (void)review {
	reviewAuthor = [self checkPreviousAuthor:reviewAuthor];
	[self plainTextPeriod:reviewAuthor];
	if (reviewTitle and reviewTitle.length > 0)
		[self quotedTitle:reviewTitle];
	[self plainText:@"Rev. of "];
	[self italicizedText:reviewedTitle];												// TODO: use quotes for articles, poems, and short stories
	[self plainText:[NSString stringWithFormat:@", by %@. %@ %@: %@. Print.", reviewedAuthor, titleOfPer, date, pageRange]];
}

- (void)editorial {
	if (author && author.length > 0) {
		author = [self checkPreviousAuthor:author];
		[self plainTextPeriod:author];
	}
	if (title && title.length > 0)
		[self quotedTitle:title];
	[self plainTextPeriod:type];
	[self italicizedTitle:paperName];
	[self plainText:[NSString stringWithFormat:@"%@: %@. Print.", date, pageRange]];
}

- (void)anonymous {
	[self quotedTitle:title];
	[self italicizedText:titleOfPer];
	[self plainText:[NSString stringWithFormat:@" %@: %@. Print.", date, pageRange]];
}

- (void)journal {
	author = [self checkPreviousAuthor:author];
	[self plainTextPeriod:author];
	[self quotedTitle:titleOfArticle];
	[self italicizedTitle:titleOfJournal];
	[self plainText:[NSString stringWithFormat:@" %@ (%@): %@. Print.", volume, yearOfPub, pageRange]];
}

- (void)journalSpecial {
	author = [self checkPreviousAuthor:author];
	[self plainTextPeriod:author];
	[self quotedTitle:titleOfArticle];
	[self italicizedText:nameOfSpecIssue];
	[self plainText:@" Spec. issue of "];
	[self italicizedText:titleOfJournal];
	[self plainText:[NSString stringWithFormat:@" %@ (%@): %@. Print.", volume, yearOfPub, pageRange]];
}

- (void)webSite {
	if (author && author.length > 0) {
		author = [self checkPreviousAuthor:author];
		[self plainTextPeriod:author];
	}
	[self italicizedTitle:nameOfSite];
	[self plainText:[NSString stringWithFormat:@"%@. %@, ", version, orgName]];
	if (dateCreation && dateCreation.length > 0)
		[self plainTextPeriod:dateCreation];
	else
		[self plainText:@"n.d."];
	[self plainText:[NSString stringWithFormat:@" Web. %@.", dateAccess]];
}

- (void)departmentWebSite {
	if (instructor && instructor.length > 0)
		[self plainTextPeriod:instructor];
	[self italicizedTitle:courseName];
	[self italicizedTitle:deptName];
	[self plainTextPeriod:institution];
	if (dateCreation && dateCreation.length > 0)
		[self plainTextPeriod:dateCreation];
	else
		[self plainText:@"n.d."];
	[self plainText:[NSString stringWithFormat:@" Web. %@.", dateAccess]];
}

- (void)webPage {
	[self quotedTitle:titleOfArticle];
	if (author && author.length > 0)
		[self plainTextPeriod:author];
	[self italicizedTitle:nameOfSite];
	[self plainText:[NSString stringWithFormat:@"%@. %@, ", version, orgName]];
	if (dateCreation && dateCreation.length > 0)
		[self plainTextPeriod:dateCreation];
	else
		[self plainText:@"n.d. "];
	[self plainText:[NSString stringWithFormat:@"Web. %@.", dateAccess]];
	
}

- (void)image {
	artist = [self checkPreviousAuthor:artist];
	[self plainTextPeriod:artist];
	[self italicizedTitle:work];
	[self plainText:[NSString stringWithFormat:@"%@. %@. ", dateCreation, institution]];
	[self italicizedTitle:nameOfSite];
	[self plainText:[NSString stringWithFormat:@" Web. %@.", dateAccess]];
}

- (void)webMagazine {
	author = [self checkPreviousAuthor:author];
	[self plainTextPeriod:author];
	[self quotedTitle:titleOfArticle];
	[self italicizedTitle:titleOfPer];
	if (publisher && publisher.length > 0)
		[self plainText:[publisher stringByAppendingString:@", "]];
	else
		[self plainText:@"n.p., "];
	if (pubDate && pubDate.length > 0)
		[self plainTextPeriod:pubDate];
	else
		[self plainText:@"n.d. "];
	[self plainText:[NSString stringWithFormat:@"Web. %@.", dateAccess]];
}

- (void)onlineScholarlyJournalArticle {
	author = [self checkPreviousAuthor:author];
	[self plainTextPeriod:author];
	[self quotedTitle:titleOfArticle];
	[self italicizedTitle:titleOfJournal];
	[self plainText:[NSString stringWithFormat:@"%@ (%@): ", volume, yearOfPub]];
	if (pageRange && pageRange.length > 0)
		[self plainText:[NSString stringWithFormat:@" %@. Web. %@.", pageRange, dateAccess]];
	else
		[self plainText:[NSString stringWithFormat:@" n. pag. Web. %@.", dateAccess]];
}

- (void)onlineDatabase {
	author = [self checkPreviousAuthor:author];
	[self plainTextPeriod:author];
	[self quotedTitle:titleOfArticle];
	[self italicizedTitle:titleOfJournal];
	[self plainText:[NSString stringWithFormat:@"%@ (%@): ", volume, yearOfPub]];
	if (pageRange && pageRange.length > 0)
		[self plainText:[NSString stringWithFormat:@" %@. %@. Web. %@.", pageRange, titleOfDB, dateAccess]];
	else
		[self plainText:[NSString stringWithFormat:@" n. pag. %@. Web. %@.", titleOfDB, dateAccess]];
}

- (void)email {
	author = [self checkPreviousAuthor:author];
	[self plainTextPeriod:author];
	[self quotedTitle:subject];
	if (recipient && recipient.length > 0)
		[self plainText:[NSString stringWithFormat:@"Message to %@. ", recipient]];
	else
		[self plainText:@" Message to the author. "];
	[self plainText:[messageDate stringByAppendingString:@". E-mail."]];
}

- (void)listserv {
	if (author && author.length > 0) {
		author = [self checkPreviousAuthor:author];
		[self plainTextPeriod:author];
	}
	[self quotedTitle:title];
	[self italicizedTitle:nameOfSite];
	if (orgName && orgName.length > 0)
		[self plainText:[NSString stringWithFormat:@"%@, %@. Web. %@.", orgName, dateCreation, dateAccess]];
	else
		[self plainText:[NSString stringWithFormat:@"n.p., %@. Web. %@.", dateCreation, dateAccess]];
}

- (void)interview {
	[self plainText:[NSString stringWithFormat:@"%@. Personal interview. %@.", interviewee, date]];
}

- (void)publishedInterview {														// TODO: the format of the citation should be determined by the media type
	[self plainText:interviewee];
	if (title && title.length > 0) {
		if (containingWork && containingWork.length > 0) {
			[self plainText:@". "];
			[self quotedTitle:title];
		} else
			[self italicizedTitle:title];
	}
	[self plainText:@" Interview. "];
	if (containingWork && containingWork.length > 0)
		[self italicizedTitle:containingWork];
	if (author && author.length > 0)
		[self plainText:[NSString stringWithFormat:@"By %@. ", author]];
	[self plainTextPeriod:medium];
}

- (void)onlineOnlyPublishedInterview {
	if (interviewTitle && interviewTitle.length > 0) {
		[self plainTextPeriod:interviewee];
		[self quotedTitle:interviewTitle];
	} else
		[self plainText:[NSString stringWithFormat:@"%@ Interview. ", interviewee]];
	[self quotedTitle:titleOfArticle];
	[self italicizedTitle:nameOfSite];
	if (publisher && publisher.length > 0)
		[self plainTextPeriod:publisher];
	else
		[self plainText:@"n.p., "];
	if (dateCreation && dateCreation.length > 0)
		[self plainTextPeriod:dateCreation];
	else
		[self plainText:@"n.d."];
	[self plainText:[NSString stringWithFormat:@" Web. %@.", dateAccess]];
}

- (void)oral {
	[self plainTextPeriod:speaker];
	if (title && title.length > 0)
		[self quotedTitle:title];
	[self italicizedTitle:meetingName];
	[self plainText:[NSString stringWithFormat:@"%@. %@. ", orgName, meetingLoc]];
	if (presentationDate && presentationDate.length > 0)
		[self plainTextPeriod:presentationDate];
	else
		[self plainTextPeriod:@"n.d"];
	[self plainTextPeriod:type];
}

- (void)publishedConference {
	if (presenter && presenter.length > 0) {
		[self plainTextPeriod:presenter];
		[self quotedTitle:titleOfArticle];
		// reverse the order of these for citing presentation
		[self italicizedText:title];
		[self plainText:@". "];
		[self plainText:editor];
		[self plainText:@", ed. "];
	} else {
		[self plainText:editor];
		[self plainText:@", ed. "];
		[self italicizedText:title];
		[self plainText:@". "];
	}
	[self plainText:[NSString stringWithFormat:@"%@, %@. %@: %@, %@. Print.", confDate, confLocation, placeOfPub, publisher, yearOfPub]];
}

- (void)painting {
	artist = [self checkPreviousAuthor:artist];
	[self plainTextPeriod:artist];
	[self italicizedTitle:work];
	[self plainTextPeriod:dateCreation.length > 0 ? dateCreation : @"n.d"];
	[self italicizedText:[institution stringByAppendingString:@", "]];
	[self plainTextPeriod:institutionLoc];
}

- (void)artworkRepro {
	artist = [self checkPreviousAuthor:artist];
	[self plainTextPeriod:artist];
	[self italicizedTitle:work];
	[self plainTextPeriod:dateCreation.length > 0 ? dateCreation : @"n.d"];
	[self italicizedText:[institution stringByAppendingString:@", "]];
	[self plainTextPeriod:institutionLoc];
	[self italicizedTitle:title];
	[self plainTextPeriod:[@"By " stringByAppendingString:author]];
	[self plainText:[NSString stringWithFormat:@"%@: %@. %@. Print.", placeOfPub, publisher, pageRange]];
}

- (void)currentFilm {
	[self italicizedTitle:title];
	[self plainTextPeriod:[@"Dir. " stringByAppendingString:director]];
	if (performers.length > 0)
		[self plainTextPeriod:[@"Perf. " stringByAppendingString:performers]];
	[self plainText:[NSString stringWithFormat:@"%@, %@. Film.", studio, dateCreation]];
}

- (void)recordedFilm {
	[self italicizedTitle:title];
	[self plainTextPeriod:[@"Dir. " stringByAppendingString:director]];
	if (performers.length > 0)
		[self plainTextPeriod:[@"Perf. " stringByAppendingString:performers]];
	[self plainText:[NSString stringWithFormat:@"%@, %@. %@.", studio, dateCreation, medium]];
}

- (void)broadcastTV {
	[self quotedTitle:episodeTitle];
	[self italicizedTitle:seriesTitle];
	[self plainTextPeriod:network];
	[self plainText:[NSString stringWithFormat:@"%@, %@. %@. %@.", station, city, date, medium]];
}

- (void)recordedTV {
	[self quotedTitle:episodeTitle];
	[self italicizedTitle:seriesTitle];
	if (collectionTitle && collectionTitle.length > 0)
		[self italicizedTitle:collectionTitle];
	if (composer.length)
		[self plainTextPeriod:[NSString stringWithFormat:@"Writ. %@", composer]];
	if (director.length)
		[self plainTextPeriod:[NSString stringWithFormat:@"Dir. %@", director]];
	if (performers.length)
		[self plainTextPeriod:[NSString stringWithFormat:@"Perf. %@", performers]];
	if (producer.length)
		[self plainTextPeriod:[NSString stringWithFormat:@"Prod. %@", producer]];
	[self plainText:[NSString stringWithFormat:@"%@, %@. %@.", studio, dateCreation, medium]];
}

- (void)album {
	artist = [self checkPreviousAuthor:artist];
	[self plainTextPeriod:artist];
	if (songTitle.length > 0)
		[self quotedTitle:songTitle];
	[self italicizedTitle:albumTitle];
	if (composer.length > 0)
		[self plainTextPeriod:[@"Comp. " stringByAppendingString:composer]];
	if (performers.length > 0)
		[self plainTextPeriod:[@"Perf. " stringByAppendingString:performers]];
	[self plainText:[NSString stringWithFormat:@"%@, %@. %@.", manufacturer, dateCreation, medium]];
}

#pragma mark -
#pragma mark accessors

- (CFMutableAttributedStringRef)attributedString
{
	return attrString;
}

@end


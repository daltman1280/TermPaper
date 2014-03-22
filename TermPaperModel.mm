//
//  TermPaperModel.mm
//  TermPaper
//
//  Created by daltman on 6/21/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

//	Implements access to persistent representation of term paper

#import "TermPaperModel.h"
#import "CitationModel.h"
#import "DocXFormatter.h"
#import "zip.h"
#import <Crashlytics/Crashlytics.h>

static TermPaperModel*			gTermPaper = [[TermPaperModel alloc] init];		// static initializer, to make sure init is called on startup. This is not the active term paper!
static TermPaperModel*			gActiveTermPaper;								// this is the active TermPaper
static NSString*				gDocumentsFolder;								// documents folder for application, initialized in init static initializer
static NSMutableArray*			gTermPapersList;								// NSString* to TermPaper plists
static NSString*				gPapersFolder;

@implementation TermPaperModel

@synthesize mDictionary, mPlistFilepath;

- (void)exportDocxFile
{
	NSString *filepath = [NSString stringWithFormat:@"%@/%@.docx", gDocumentsFolder, self.name];
	zipFile zipFileHandle = zipOpen([filepath cStringUsingEncoding:NSUTF8StringEncoding], APPEND_STATUS_CREATE);
	zip_fileinfo zipfi;
	zipfi.tmz_date.tm_min = zipfi.tmz_date.tm_mon = zipfi.tmz_date.tm_sec = zipfi.tmz_date.tm_hour = zipfi.tmz_date.tm_mday = zipfi.tmz_date.tm_year = 0;
	// _rels/
	int status = zipOpenNewFileInZip(zipFileHandle, "_rels/.rels", &zipfi, NULL, 0, NULL, 0, "comment", Z_DEFLATED, Z_DEFAULT_COMPRESSION);
	CLSLog(@"status = %d", status);
	NSString *relsString = [[NSBundle mainBundle] pathForResource:@".rels" ofType:@""];
	NSData *relsData = [NSData dataWithContentsOfFile:relsString];
	status = zipWriteInFileInZip(zipFileHandle, [relsData bytes], (int) [relsData length]);
	CLSLog(@"status = %d", status);
	status = zipCloseFileInZip(zipFileHandle);
	CLSLog(@"status = %d", status);
	// [Content_Types].xml
	status = zipOpenNewFileInZip(zipFileHandle, "[Content_Types].xml", &zipfi, NULL, 0, NULL, 0, "comment", Z_DEFLATED, Z_DEFAULT_COMPRESSION);
	CLSLog(@"status = %d", status);
	NSString *contentTypesString = [[NSBundle mainBundle] pathForResource:@"[Content_Types]" ofType:@"xml"];
	NSData *contentTypesData = [NSData dataWithContentsOfFile:contentTypesString];
	status = zipWriteInFileInZip(zipFileHandle, [contentTypesData bytes], (int) [contentTypesData length]);
	CLSLog(@"status = %d", status);
	status = zipCloseFileInZip(zipFileHandle);
	CLSLog(@"status = %d", status);
	// app.xml
	status = zipOpenNewFileInZip(zipFileHandle, "docProps/app.xml", &zipfi, NULL, 0, NULL, 0, "comment", Z_DEFLATED, Z_DEFAULT_COMPRESSION);
	CLSLog(@"status = %d", status);
	NSString *appString = [[NSBundle mainBundle] pathForResource:@"app" ofType:@"xml"];
	NSData *appData = [NSData dataWithContentsOfFile:appString];
	status = zipWriteInFileInZip(zipFileHandle, [appData bytes], (int) [appData length]);
	CLSLog(@"status = %d", status);
	status = zipCloseFileInZip(zipFileHandle);
	CLSLog(@"status = %d", status);
	// core.xml
	status = zipOpenNewFileInZip(zipFileHandle, "docProps/core.xml", &zipfi, NULL, 0, NULL, 0, "comment", Z_DEFLATED, Z_DEFAULT_COMPRESSION);
	CLSLog(@"status = %d", status);
	NSString *coreString = [[NSBundle mainBundle] pathForResource:@"core" ofType:@"xml"];
	NSData *coreData = [NSData dataWithContentsOfFile:coreString];
	status = zipWriteInFileInZip(zipFileHandle, [coreData bytes], (int) [coreData length]);
	CLSLog(@"status = %d", status);
	status = zipCloseFileInZip(zipFileHandle);
	CLSLog(@"status = %d", status);
	// meta.xml
	status = zipOpenNewFileInZip(zipFileHandle, "docProps/meta.xml", &zipfi, NULL, 0, NULL, 0, "comment", Z_DEFLATED, Z_DEFAULT_COMPRESSION);
	CLSLog(@"status = %d", status);
	NSString *metaString = [[NSBundle mainBundle] pathForResource:@"meta" ofType:@"xml"];
	NSData *metaData = [NSData dataWithContentsOfFile:metaString];
	status = zipWriteInFileInZip(zipFileHandle, [metaData bytes], (int) [metaData length]);
	CLSLog(@"status = %d", status);
	status = zipCloseFileInZip(zipFileHandle);
	CLSLog(@"status = %d", status);
	// document.xml.rels
	status = zipOpenNewFileInZip(zipFileHandle, "word/_rels/document.xml.rels", &zipfi, NULL, 0, NULL, 0, "comment", Z_DEFLATED, Z_DEFAULT_COMPRESSION);
	CLSLog(@"status = %d", status);
	NSString *rels2String = [[NSBundle mainBundle] pathForResource:@"document.xml" ofType:@"rels"];
	NSData *rels2Data = [NSData dataWithContentsOfFile:rels2String];
	status = zipWriteInFileInZip(zipFileHandle, [rels2Data bytes], (int) [rels2Data length]);
	CLSLog(@"status = %d", status);
	status = zipCloseFileInZip(zipFileHandle);
	CLSLog(@"status = %d", status);
	// document.xml
	status = zipOpenNewFileInZip(zipFileHandle, "word/document.xml", &zipfi, NULL, 0, NULL, 0, "comment", Z_DEFLATED, Z_DEFAULT_COMPRESSION);
	CLSLog(@"status = %d", status);
//	NSString *docString = [[NSBundle mainBundle] pathForResource:@"document" ofType:@"xml"];
//	NSData *docData = [NSData dataWithContentsOfFile:docString];
	NSString *docxString = [[DocXFormatter sharedFormatter] formattedDocument];
//	CLSLog(@"docxString = %@", docxString);
	const char *string = [docxString cStringUsingEncoding:NSMacOSRomanStringEncoding];
	status = zipWriteInFileInZip(zipFileHandle, string, (int) docxString.length);
	CLSLog(@"status = %d", status);
	status = zipCloseFileInZip(zipFileHandle);
	CLSLog(@"status = %d", status);

	// header1.xml
	status = zipOpenNewFileInZip(zipFileHandle, "word/header1.xml", &zipfi, NULL, 0, NULL, 0, "comment", Z_DEFLATED, Z_DEFAULT_COMPRESSION);
	CLSLog(@"status = %d", status);
	NSString *header1String = [[NSBundle mainBundle] pathForResource:@"header1" ofType:@"xml"];
	NSData *header1Data = [NSData dataWithContentsOfFile:header1String];
	status = zipWriteInFileInZip(zipFileHandle, [header1Data bytes], (int) [header1Data length]);
	CLSLog(@"status = %d", status);
	status = zipCloseFileInZip(zipFileHandle);
	CLSLog(@"status = %d", status);

	// header2.xml
	status = zipOpenNewFileInZip(zipFileHandle, "word/header2.xml", &zipfi, NULL, 0, NULL, 0, "comment", Z_DEFLATED, Z_DEFAULT_COMPRESSION);
	CLSLog(@"status = %d", status);
	NSString *header2String = [[NSBundle mainBundle] pathForResource:@"header2" ofType:@"xml"];
	NSData *header2Data = [NSData dataWithContentsOfFile:header2String];
	status = zipWriteInFileInZip(zipFileHandle, [header2Data bytes], (int) [header2Data length]);
	CLSLog(@"status = %d", status);
	status = zipCloseFileInZip(zipFileHandle);
	CLSLog(@"status = %d", status);
	
#if 0
	// styles.xml
	status = zipOpenNewFileInZip(zipFileHandle, "word/styles.xml", &zipfi, NULL, 0, NULL, 0, "comment", Z_DEFLATED, Z_DEFAULT_COMPRESSION);
	NSString *stylesString = [[NSBundle mainBundle] pathForResource:@"styles" ofType:@"xml"];
	NSData *stylesData = [NSData dataWithContentsOfFile:stylesString];
	status = zipWriteInFileInZip(zipFileHandle, [stylesData bytes], [stylesData length]);
	status = zipCloseFileInZip(zipFileHandle);
#endif
	
	// theme1.xml
	status = zipOpenNewFileInZip(zipFileHandle, "word/theme/theme1.xml", &zipfi, NULL, 0, NULL, 0, "comment", Z_DEFLATED, Z_DEFAULT_COMPRESSION);
	CLSLog(@"status = %d", status);
	NSString *themeString = [[NSBundle mainBundle] pathForResource:@"theme1" ofType:@"xml"];
	NSData *themeData = [NSData dataWithContentsOfFile:themeString];
	status = zipWriteInFileInZip(zipFileHandle, [themeData bytes], (int) [themeData length]);
	CLSLog(@"status = %d", status);
	status = zipCloseFileInZip(zipFileHandle);
	CLSLog(@"status = %d", status);
	
	status = zipClose(zipFileHandle, "comment");
	CLSLog(@"status = %d", status);
}

//	return TermPaperModel * to active paper

+ (TermPaperModel *)activeTermPaper
{
	return gActiveTermPaper;
}

- (BOOL)rename:(NSString *)newName
{
	BOOL success = NO;
	[gTermPapersList removeObject:gActiveTermPaper.name];
	self.name = newName;
	NSString *oldFilepath = [NSString stringWithString:mPlistFilepath];
	NSString *newFilepath = [[[[oldFilepath stringByDeletingLastPathComponent] stringByAppendingString:@"/"] stringByAppendingString:newName] stringByAppendingString:@".TermPaper"];
	if (![newFilepath isEqualToString:oldFilepath])
		success = [[NSFileManager defaultManager] moveItemAtPath:oldFilepath toPath:newFilepath error:nil];
	[gTermPapersList addObject:newName];
	[gTermPapersList sortUsingSelector:@selector(caseInsensitiveCompare:)];
	self.mPlistFilepath = newFilepath;
	return success;
}

//	return the name of the duplicated paper

- (NSString *)duplicate
{
	// find an unused name formed from the selected name
	NSString *dupName;
	NSString *baseName;																		// if the name is of the form <name> copy [nn], we will extract <name>
	NSRange range = [self.name rangeOfString:@" copy ?[0-9]*" options:NSRegularExpressionSearch | NSBackwardsSearch];
	if (range.location + range.length == [self.name length])
		baseName = [self.name substringToIndex:range.location];
	else
		baseName = self.name;
	if (![gTermPapersList containsObject:[baseName stringByAppendingString:@" copy"]]) {
		dupName = [baseName stringByAppendingString:@" copy"];
	} else {
		for (int i =1; i<=99; ++i) {
			if (![gTermPapersList containsObject:[NSString stringWithFormat:@"%@ copy %d", baseName, i]]) {
				dupName = [NSString stringWithFormat:@"%@ copy %d", baseName, i];
				break;
			}
		}
	}
	[self save];
	TermPaperModel *duplicatePaper = [[TermPaperModel alloc] initWithName:dupName];
	duplicatePaper.mDictionary = [NSMutableDictionary dictionaryWithDictionary:mDictionary];
	duplicatePaper.name = dupName;
	[duplicatePaper save];
	[gTermPapersList addObject:dupName];
	[gTermPapersList sortUsingSelector:@selector(caseInsensitiveCompare:)];
	return duplicatePaper.name;
}

//	make the paper whose name is selectedPaperName active

+ (BOOL)makeActive:(NSString *)selectedPaperName
{
	gActiveTermPaper = [[TermPaperModel alloc] initWithName:selectedPaperName];
	BOOL success = [gActiveTermPaper termPaperFromContentsOfFile];
	return success;
}

//	returns a list of term paper names

+ (NSArray *)termPapers
{
	if (!gTermPapersList) {
		gTermPapersList = [[NSMutableArray alloc] init];
		NSArray *paperPlists = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:gPapersFolder error:NULL];
		for (NSString *filename in paperPlists) {
			if ([[filename pathExtension] isEqualToString:@"TermPaper"]) {
				[gTermPapersList addObject:[filename stringByDeletingPathExtension]];
			}
		}
		[gTermPapersList sortUsingSelector:@selector(caseInsensitiveCompare:)];
	}
	return gTermPapersList;
}

//	In addition to being called by initWithName, is called from static initializer, to do some housekeeping

- (TermPaperModel *)init
{
	@autoreleasepool {					// may be called before application has created its autorelease pool
		if (self = [super init]) {
			gDocumentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
			gPapersFolder = [gDocumentsFolder stringByAppendingPathComponent:@"Papers"];
			NSError* myError;
			// initialize the papers folder the first time the app is run
			if (![[NSFileManager defaultManager] fileExistsAtPath:gPapersFolder]) {
				[[NSFileManager defaultManager] createDirectoryAtPath:gPapersFolder withIntermediateDirectories:NO attributes:nil error:&myError];
				// TODO: copy sample paper to here from bundle resources
			}
		}
		return self;
	}
}

//	designated initializer

- (TermPaperModel *)initWithName:(NSString *)name
{
	if (self = [self init]) {
		self.mPlistFilepath = [[gPapersFolder stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"TermPaper"];
		self.mDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultTermPaper" ofType:@"TermPaper"]];
		self.name = name;
	}
	return self;
}

- (void)upgradeToCurrentVersion
{
	float documentVersionNumber = [[mDictionary objectForKey:kDWPaperTagVersion] floatValue];
	if (documentVersionNumber < 1.1) {
		self.format = @"MLA";
		self.abstract = @"";
		self.shortTitle = @"";
		self.keywords = @"";
		self.institution = @"";
	}
	if (documentVersionNumber < 1.2) {
		self.insertDoubleSpaces = NO;
	}
}

//	Read the contents from file-system

- (BOOL)termPaperFromContentsOfFile
{
	gActiveTermPaper = self;
	self.mDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:mPlistFilepath];
	if (!self.mDictionary) return NO;
	[self upgradeToCurrentVersion];
	return YES;
}

//	Create a new paper, with default settings, return its name

+ (NSString *)newPaper
{
	for (int i=1; i<99; ++i) {														// look for unused paper names
		if (![gTermPapersList containsObject:[NSString stringWithFormat:@"Untitled paper %d", i]]) {
			TermPaperModel *newPaper = [[TermPaperModel alloc] initWithName:[NSString stringWithFormat:@"Untitled paper %d", i]];
			[newPaper save];
			[gTermPapersList addObject:newPaper.name];
			[gTermPapersList sortUsingSelector:@selector(caseInsensitiveCompare:)];
			return newPaper.name;
		}
	}
	return nil;
}

//	Save the contents to file-system

- (void)save
{
	[mDictionary setObject:@"1.3" forKey:kDWPaperTagVersion];
	[mDictionary writeToFile:mPlistFilepath atomically:YES];
}

//	Remove it from memory and file-storage

- (void)remove
{
	[[NSFileManager defaultManager] removeItemAtPath:mPlistFilepath error:nil];
	[gTermPapersList removeObject:self.name];
	gActiveTermPaper = nil;
}

#pragma mark -
#pragma mark Utility
#pragma mark -

+ (void)importExternalDocuments
{
	// look for new documents to import
	NSArray *documents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:gDocumentsFolder error:NULL];
	for (NSString *filename in documents) {
		BOOL isDirectory;
		[[NSFileManager defaultManager] fileExistsAtPath:[gDocumentsFolder stringByAppendingPathComponent:filename] isDirectory:&isDirectory];
		if (!isDirectory && [[filename pathExtension] isEqualToString:@"txt"])									// import all files with txt extension
			[TermPaperModel importTextIfNewer:filename];
		else if (!isDirectory && [[filename pathExtension] isEqualToString:@"TermPaper"])
			[TermPaperModel importPaperIfNewer:filename];
		else
			CLSLog(@"extraneous document = %@, ignored", filename);												// not a txt file (could be a folder)
	}
	//	Copy the Sample Paper from the application bundle, just the first time the app is launched
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"copiedSamplePaper"]) {
		[[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"Sample Paper" ofType:@"TermPaper"] toPath:[gPapersFolder stringByAppendingString:@"/Sample Paper.TermPaper"] error:nil];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"copiedSamplePaper"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

//	process plain text file and generate plist file, if the plain text file is newer than the plist file

+ (void)importTextIfNewer:(NSString *)filename
{
	NSString *plainTextFilePath = [gDocumentsFolder stringByAppendingPathComponent:filename];
	NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:plainTextFilePath error:NULL];
	NSDate *dateOfPlainText = [dict objectForKey:NSFileModificationDate];
	NSString *paperFilepath = [[[gPapersFolder stringByAppendingPathComponent:filename] stringByDeletingPathExtension] stringByAppendingPathExtension:@"TermPaper"];
	if ([[NSFileManager defaultManager] fileExistsAtPath:paperFilepath]) {
		NSDate *dateOfPaper = [[[NSFileManager defaultManager] attributesOfItemAtPath:paperFilepath error:NULL] objectForKey:NSFileModificationDate];
		if ([dateOfPlainText compare:dateOfPaper] != NSOrderedDescending)
			return;
	}
	CLSLog(@"Importing %@", paperFilepath);
	NSMutableDictionary *paperDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultTermPaper" ofType:@"TermPaper"]];
	NSStringEncoding encoding;
	NSString *text = [NSString stringWithContentsOfFile:[gDocumentsFolder stringByAppendingPathComponent:filename] usedEncoding:&encoding error:NULL];
	[paperDict setObject:text forKey:kDWPaperTagContent];
	[paperDict setObject:[filename stringByDeletingPathExtension] forKey:kDWPaperTagName];
	[paperDict writeToFile:paperFilepath atomically:YES];
}

//	process paper file and move into Papers folder, if it's newer than any existing file of the same name

+ (void)importPaperIfNewer:(NSString *)filename
{
	NSString *externalPaperFilePath = [gDocumentsFolder stringByAppendingPathComponent:filename];
	NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:externalPaperFilePath error:NULL];
	NSDate *dateOfExternalPaper = [dict objectForKey:NSFileModificationDate];
	NSString *paperFilepath = [gPapersFolder stringByAppendingPathComponent:filename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:paperFilepath]) {
		NSDate *dateOfPaper = [[[NSFileManager defaultManager] attributesOfItemAtPath:paperFilepath error:NULL] objectForKey:NSFileModificationDate];
		if ([dateOfExternalPaper compare:dateOfPaper] != NSOrderedDescending)
			return;
	}
	CLSLog(@"Importing %@", paperFilepath);
	[[NSFileManager defaultManager] removeItemAtPath:paperFilepath error:nil];
	[[NSFileManager defaultManager] moveItemAtPath:externalPaperFilePath toPath:paperFilepath error:nil];
}

#pragma mark -
#pragma mark accessors
#pragma mark -

- (NSString *)content
{
	NSString *string = [mDictionary objectForKey:kDWPaperTagContent];
	return string;
}

- (void)setContent:(NSString *)content
{
	[mDictionary setObject:content forKey:kDWPaperTagContent];
}

// represented in NSDictionary as NSData

- (NSAttributedString *)attributedContent
{
	NSData *data = [mDictionary objectForKey:kDWPaperTagAttributedContent];
	if (!data) return nil;
	NSAttributedString *string = [[NSAttributedString alloc] initWithData:data options:nil documentAttributes:nil error:nil];
	return string;
}

// must convert to NSData before populating NSMutableDictionary

- (void)setAttributedContent:(NSAttributedString *)attributedContent
{
	NSData *data = [attributedContent dataFromRange:NSMakeRange(0, attributedContent.length) documentAttributes:@{ NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType } error:nil];
	[mDictionary setObject:data forKey:kDWPaperTagAttributedContent];
}

- (NSString *)abstract
{
	NSString *string = [mDictionary objectForKey:kDWPaperTagAbstract];
	return string;
}

- (void)setAbstract:(NSString *)abstract
{
	[mDictionary setObject:abstract forKey:kDWPaperTagAbstract];
}

- (NSString *)name
{
	return [mDictionary objectForKey:kDWPaperTagName];
}

- (void)setName:(NSString *)name
{
	[mDictionary setObject:name forKey:kDWPaperTagName];
}

- (NSString *)title
{
	return [mDictionary objectForKey:kDWPaperTagTitle];
}

- (void)setTitle:(NSString *)title
{
	[mDictionary setObject:title forKey:kDWPaperTagTitle];
}

- (NSString *)shortTitle
{
	return [mDictionary objectForKey:kDWPaperTagShortTitle];
}

- (void)setShortTitle:(NSString *)shortTitle
{
	[mDictionary setObject:shortTitle forKey:kDWPaperTagShortTitle];
}

- (NSString *)author
{
	return [mDictionary objectForKey:kDWPaperTagAuthor];
}

- (void)setAuthor:(NSString *)author
{
	[mDictionary setObject:author forKey:kDWPaperTagAuthor];
}

- (NSString *)instructor
{
	return [mDictionary objectForKey:kDWPaperTagInstructor];
}

- (void)setInstructor:(NSString *)instructor
{
	[mDictionary setObject:instructor forKey:kDWPaperTagInstructor];
}

- (NSString *)course
{
	return [mDictionary objectForKey:kDWPaperTagCourse];
}

- (void)setCourse:(NSString *)course
{
	[mDictionary setObject:course forKey:kDWPaperTagCourse];
}

- (NSString *)institution
{
	return [mDictionary objectForKey:kDWPaperTagInstitution];
}

- (void)setInstitution:(NSString *)institution
{
	[mDictionary setObject:institution forKey:kDWPaperTagInstitution];
}

- (NSString *)keywords
{
	return [mDictionary objectForKey:kDWPaperTagKeywords];
}

- (void)setKeywords:(NSString *)keywords
{
	[mDictionary setObject:keywords forKey:kDWPaperTagKeywords];
}

- (NSString *)date
{
	return [mDictionary objectForKey:kDWPaperTagDate];
}

- (void)setDate:(NSString *)date
{
	[mDictionary setObject:date forKey:kDWPaperTagDate];
}

- (NSString *)headerTitle
{
	return [mDictionary objectForKey:kDWPaperTagHeaderTitle];
}

- (void)setHeaderTitle:(NSString *)headerTitle
{
	[mDictionary setObject:headerTitle forKey:kDWPaperTagHeaderTitle];
}

- (BOOL)headerOnFirst
{
	return [[mDictionary objectForKey:kDWPaperTagHeaderOnFirst] boolValue];
}

- (void)setHeaderOnFirst:(BOOL)headerOnFirst
{
	[mDictionary setObject:[NSNumber numberWithBool:headerOnFirst] forKey:kDWPaperTagHeaderOnFirst];
}

- (BOOL)citationPages
{
	return [[mDictionary objectForKey:kDWPaperTagCitationPages] boolValue];
}

- (void)setCitationPages:(BOOL)citationPages
{
	[mDictionary setObject:[NSNumber numberWithBool:citationPages] forKey:kDWPaperTagCitationPages];
}

- (BOOL)contentPages
{
	return [[mDictionary objectForKey:kDWPaperTagContentPages] boolValue];
}

- (void)setContentPages:(BOOL)contentPages
{
	[mDictionary setObject:[NSNumber numberWithBool:contentPages] forKey:kDWPaperTagContentPages];
}

- (BOOL)insertDoubleSpaces
{
	return [[mDictionary objectForKey:kDWPaperTagInsertDoubleSpaces] boolValue];
}

- (void)setInsertDoubleSpaces:(BOOL)insertDoubleSpaces
{
	[mDictionary setObject:[NSNumber numberWithBool:insertDoubleSpaces] forKey:kDWPaperTagInsertDoubleSpaces];
}

- (NSString *)fontName
{
	return [mDictionary objectForKey:kDWPaperTagFontName];
}

- (void)setFontName:(NSString *)fontName
{
	[mDictionary setObject:fontName forKey:kDWPaperTagFontName];
}

- (NSString *)fontSize
{
	return [mDictionary objectForKey:kDWPaperTagFontSize];
}

- (void)setFontSize:(NSString *)fontSize
{
	[mDictionary setObject:fontSize forKey:kDWPaperTagFontSize];
}

- (NSArray *)citations
{
	return [mDictionary objectForKey:kDWPaperTagCitations];
}

- (void)setCitations:(NSArray *)citations
{
	[mDictionary setObject:[citations sortedArrayUsingSelector:@selector(compareCitations:)] forKey:kDWPaperTagCitations];
}

- (NSString *)format
{
	return [mDictionary objectForKey:kDWPaperTagFormat];
}

- (void)setFormat:(NSString *)format
{
	[mDictionary setObject:format forKey:kDWPaperTagFormat];
}

#pragma mark -


@end

@implementation NSString (APAHelper)

- (NSString *)insertDoubleSpaces
{
	NSMutableString *contentString = [NSMutableString stringWithString:self];
	NSUInteger index = 0;
	do {
		NSRange range = [contentString rangeOfString:@"[\\.!?\\\"]+ [ABCDEFGHIJKLMNOPQRSTUVWXYZ\\\"]" options:NSRegularExpressionSearch range:NSMakeRange(index, contentString.length-index)];
		index = range.location;
		if (index == NSNotFound)
			break;
		[contentString insertString:@" " atIndex:index+1];
	} while (TRUE);
	return contentString;
}

@end


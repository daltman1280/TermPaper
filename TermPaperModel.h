//
//  TermPaperModel.h
//  TermPaper
//
//  Created by daltman on 6/21/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <Foundation/Foundation.h>

const static NSString *kDWPaperTagContent = @"Contents";										// plain text content
const static NSString *kDWPaperTagAbstract = @"Abstract";										// plain text abstract (for APA only)
const static NSString *kDWPaperTagName = @"Name";												// should be same as model file name
const static NSString *kDWPaperTagTitle = @"Title";												// 
const static NSString *kDWPaperTagShortTitle = @"ShortTitle";									// APA-only
const static NSString *kDWPaperTagAuthor = @"Author";											// 
const static NSString *kDWPaperTagInstructor = @"Instructor";									// 
const static NSString *kDWPaperTagCourse = @"Course";											// 
const static NSString *kDWPaperTagInstitution = @"Institution";									// APA-only
const static NSString *kDWPaperTagKeywords = @"Keywords";										// APA-only
const static NSString *kDWPaperTagInsertDoubleSpaces = @"InsertDoubleSpaces";					// APA-only
const static NSString *kDWPaperTagDate = @"Date";												// 
const static NSString *kDWPaperTagHeaderTitle = @"HeaderTitle";									// 
const static NSString *kDWPaperTagHeaderOnFirst = @"HeaderOnFirst";								// 
const static NSString *kDWPaperTagContentPages = @"ContentPages";								// 
const static NSString *kDWPaperTagCitationPages = @"CitationPages";								// 
const static NSString *kDWPaperTagFontName = @"FontName";										// 
const static NSString *kDWPaperTagFontSize = @"FontSize";										// small, medium, or large
const static NSString *kDWPaperTagCitations = @"Citations";										// 
const static NSString *kDWPaperTagFormat = @"Format";											// MLA/APA
const static NSString *kDWPaperTagVersion = @"ApplicationVersion";								// 

#pragma unused (kDWPaperTagContent, kDWPaperTagName, kDWPaperTagTitle, kDWPaperTagAuthor, kDWPaperTagInstructor, kDWPaperTagCourse, kDWPaperTagDate)
#pragma unused (kDWPaperTagHeaderTitle, kDWPaperTagHeaderOnFirst, kDWPaperTagContentPages, kDWPaperTagCitationPages, kDWPaperTagFontName, kDWPaperTagFontSize, kDWPaperTagCitations)
#pragma unused (kDWPaperTagFormat, kDWPaperTagVersion, kDWPaperTagAbstract, kDWPaperTagShortTitle, kDWPaperTagInstitution, kDWPaperTagKeywords, kDWPaperTagInsertDoubleSpaces)

@interface TermPaperModel : NSObject {
	NSString*				mPlistFilepath;							// for this paper
	NSMutableDictionary*	mDictionary;
}

- (BOOL)rename:(NSString *)newName;
- (NSString *)duplicate;
+ (void)makeActive:(NSString *)selectedPaperName;
+ (TermPaperModel *)activeTermPaper;
+ (NSArray *)termPapers;
+ (void)importExternalDocuments;
+ (void)importTextIfNewer:(NSString *)fullpath;
+ (void)importPaperIfNewer:(NSString *)filename;
- (TermPaperModel *)initWithName:(NSString *)name;
- (void)save;
+ (NSString *)newPaper;
- (void)termPaperFromContentsOfFile;
- (void)remove;
- (NSString *)format;
- (void)setFormat:(NSString *)format;
- (void)exportDocxFile;

@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) NSString* abstract;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *shortTitle;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *instructor;
@property (nonatomic, strong) NSString *course;
@property (nonatomic, strong) NSString *institution;
@property (nonatomic, strong) NSString *keywords;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *headerTitle;
@property (nonatomic) BOOL headerOnFirst;
@property (nonatomic) BOOL contentPages;
@property (nonatomic) BOOL citationPages;
@property (nonatomic) BOOL insertDoubleSpaces;
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, strong) NSString *fontSize;
@property (nonatomic, strong) NSArray *citations;
@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSMutableDictionary *mDictionary;;
@property (nonatomic, strong) NSString *mPlistFilepath;
@end

@interface NSString (APAHelper)

- (NSString *)insertDoubleSpaces;

@end


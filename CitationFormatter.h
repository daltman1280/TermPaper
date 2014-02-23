//
//  CitationFormatter.h
//  TermPaper
//
//  Created by daltman on 7/5/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TermPaperModel.h"
#import "CitationModel.h"

typedef enum {
	modeAttributedText,
	modeXML
}	citationOutputModeEnum;

@interface CitationFormatter : NSObject {
	//	all ivars of type NSString will be initialized to @"" in initializeProperties
	NSString*			author;
	NSString*			author1;
	NSString*			author2;
	NSString*			author3;
	NSString*			paperName;
	NSString*			date;
	NSString*			pageRange;
	NSString*			subject;
	NSString*			recipient;
	NSString*			messageDate;
	NSString*			title;
	NSString*			placeOfPub;
	NSString*			publisher;
	NSString*			yearOfPub;
	NSString*			yearOfGrant;
	NSString*			orgName;
	NSString*			translator;
	NSString*			titleOfCollection;
	NSString*			editor;
	NSString*			titleOfRef;
	NSString*			authorOfIntro;
	NSString*			specEd;
	NSString*			entity;
	NSString*			agency;
	NSString*			type;
	NSString*			titleOfArticle;
	NSString*			titleOfPer;
	NSString*			reviewAuthor;
	NSString*			reviewTitle;
	NSString*			reviewedTitle;
	NSString*			reviewedAuthor;
	NSString*			titleOfJournal;
	NSString*			volume;
	NSString*			nameOfSpecIssue;
	NSString*			nameOfSite;
	NSString*			version;
	NSString*			dateCreation;
	NSString*			dateAccess;
	NSString*			instructor;
	NSString*			siteName;
	NSString*			artist;
	NSString*			work;
	NSString*			institution;
	NSString*			pubDate;
	NSString*			titleOfDB;
	NSString*			interviewee;
	NSString*			containingWork;
	NSString*			medium;
	NSString*			interviewTitle;
	NSString*			speaker;
	NSString*			meetingName;
	NSString*			meetingLoc;
	NSString*			presentationDate;
	NSString*			presenter;
	NSString*			confDate;
	NSString*			confLocation;
	NSString*			institutionLoc;
	NSString*			director;
	NSString*			producer;
	NSString*			studio;
	NSString*			performers;
	NSString*			episodeTitle;
	NSString*			seriesTitle;
	NSString*			network;
	NSString*			station;
	NSString*			city;
	NSString*			collectionTitle;
	NSString*			composer;
	NSString*			albumTitle;
	NSString*			songTitle;
	NSString*			manufacturer;
	NSString*			courseName;
	NSString*			deptName;
	
	CFMutableAttributedStringRef attrString;
	NSMutableString*	xmlString;

	TermPaperModel*		model;
	NSDictionary*		citation;
	NSMutableString*	previousAuthor;
	citationOutputModeEnum	outputMode;
}

+ (CitationFormatter *)sharedFormatter;
- (void)initializeProperties;
- (void)formatCitations;
- (void)quotedTitle:(NSString *)input;
- (void)italicizedText:(NSString *)input;
- (void)italicizedTitle:(NSString *)input;
- (void)plainText:(NSString *)input;
- (CFMutableAttributedStringRef)attributedString;

@property (nonatomic, strong) TermPaperModel *model;
@property (nonatomic, strong) NSDictionary *citation;
@property (nonatomic, strong) NSString *previousAuthor;
@property (nonatomic) citationOutputModeEnum outputMode;
@property (nonatomic, strong) NSString *xmlString;
@end


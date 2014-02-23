//
//  DocXFormatter.h
//  TermPaper
//
//  Created by daltman on 11/12/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

//#import <Cocoa/Cocoa.h>

typedef enum {
	indentNone,
	indentStandard,
	indentHanging
}	indentEnum;

@interface DocXFormatter : NSObject {
	NSMutableString*				xmlString;
	TermPaperModel*					model;
	int								fontSize;
	BOOL							newPage;
}

+ (DocXFormatter *)sharedFormatter;
- (NSMutableString *)formattedDocument;
- (void)document;
- (void)body;
- (void)APAPreamble;
- (void)MLAPreamble;
- (void)title;
- (void)content;
- (void)paragraph:(NSString *)content alignment:(NSString *)alignment indent:(indentEnum)indent;
- (void)paragraphStart:(NSString *)alignment indent:(indentEnum)indent;
- (void)paragraphEnd;
- (void)page;
- (void)text:(NSString *)content style:(NSString *)style;

@end


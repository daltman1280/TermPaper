//
//  CitationModel.h
//  TermPaper
//
//  Created by daltman on 6/30/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Sorting)

- (NSComparisonResult)compareCitations:(NSMutableDictionary *)operand;

@end

@interface CitationModel : NSObject {
	NSDictionary*								propertySchemaDict;
	NSMutableArray*								properties;
	NSString*									citationType;
	NSString*									name;
}

- (id)initWithTypeIndex:(NSInteger)typeIndex subTypeIndex:(NSInteger)subTypeIndex;
- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)loadCitationTypes;
+ (NSArray *)citationTypes;
- (NSMutableDictionary *)dictionaryFromInstance;

@property (nonatomic, strong) NSDictionary *propertySchemaDict;									// schema
@property (nonatomic, strong) NSMutableArray *properties;										// array of CitationProperty
@property (unsafe_unretained, nonatomic, readonly) NSString *citationType;
@property (nonatomic, strong) NSString *name;
@end

@interface CitationProperty : NSObject {
	NSString*									value;
	id											mSchema;
}

- (id)initWithSchema:(id)schema value:(NSString *)value;
- (NSString *)title;
- (NSString *)placeholder;
- (NSString *)identifier;
- (NSMutableDictionary *)dictionaryFromInstance;

@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) id mSchema;														// item from properties array in schema
@end


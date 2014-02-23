//
//  CitationModel.m
//  TermPaper
//
//  Created by daltman on 6/30/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "CitationModel.h"

#pragma mark TODO: fix this

static NSArray *CitationTypes;// = [CitationModel loadCitationTypes];									// static initializer

@implementation CitationModel

@synthesize propertySchemaDict, properties, name;

//	create a new citation with empty values

- (id)initWithTypeIndex:(int)typeIndex subTypeIndex:(int)subTypeIndex
{
	if (self = [super init]) {
		properties = [[NSMutableArray alloc] init];
		propertySchemaDict = [[[CitationTypes objectAtIndex:typeIndex] objectForKey:@"SubCats"] objectAtIndex:subTypeIndex];
		NSAssert(propertySchemaDict != nil, @"null property dictionary for citation");
		NSArray *propertiesArray = [propertySchemaDict objectForKey:@"Properties"];
		for (id item in propertiesArray) {
			CitationProperty *property = [[CitationProperty alloc] initWithSchema:item value:[[NSString alloc] init]];
			[properties addObject:property];
		}
		return self;
	}
	return nil;
}

//	create it with dictionary obtained from paper

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	if (self = [super init]) {
		NSString *typeID = [dictionary objectForKey:@"TypeID"];
		NSAssert(typeID, @"TypeID not found in citation schema definitions");
		// look for the TypeID in the schema definition, so that we can extract the schema definition for the citation type
		BOOL found = NO;
		int typeIndex = 0;
		int subTypeIndex = 0;
		for (NSDictionary *category in CitationTypes) {
			subTypeIndex = 0;
			NSArray *subcats = [category objectForKey:@"SubCats"];
			for (NSDictionary *subcat in subcats) {
				if ([[subcat objectForKey:@"TypeID"] isEqualToString:typeID]) {
					found = YES;
					break;
				}
				++subTypeIndex;
			}
			if (found)
				break;
			++typeIndex;
		}
		self = [self initWithTypeIndex:typeIndex subTypeIndex:subTypeIndex];
		name = [dictionary objectForKey:@"Name"];
		// initialize the properties from the dictionary
		for (CitationProperty *property in properties) {
			NSString *propertyID = [property.mSchema objectForKey:@"PropertyID"];
			// scan dictionary for property with matching ID, and extract its value
			NSArray *dictProperties = [dictionary objectForKey:@"Properties"];
			for (NSDictionary *propertyDict in dictProperties) {
				if ([[propertyDict objectForKey:@"PropertyID"] isEqualToString:propertyID]) {
					property.value = [propertyDict objectForKey:@"Value"];
					break;
				}
			}
		}
		return self;
	}
	return nil;
}

+ (NSArray *)loadCitationTypes
{
	@autoreleasepool {
		// load the category/subcategory names
		NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CitationTypes" ofType:@"plist"]];
		return [dict objectForKey:@"CitationTypes"];
	}
}

+ (NSArray *)citationTypes
{
	return CitationTypes;
}

- (NSString *)citationType
{
	return [propertySchemaDict objectForKey:@"Name"];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<CitationModel: <Name: %@> <Type: %@> <Properties: %@>>", name, self.citationType, properties];
}

//	Serialize the instance into dictionary representation, so that it can be inserted in the paper dictionary
//	We include the type/property IDs, since they are immutable (which is not the case for other attributes, such as property order, titles, etc.)
//	This serialization should survive revisions to the citation schema over time.

- (NSMutableDictionary *)dictionaryFromInstance
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (CitationProperty *property in properties)
		[array addObject:[property dictionaryFromInstance]];
	[dict setObject:array forKey:@"Properties"];
	[dict setObject:[propertySchemaDict objectForKey:@"TypeID"] forKey:@"TypeID"];
	[dict setObject:name forKey:@"Name"];
	return dict;
}


@end

@implementation CitationProperty

@synthesize mSchema, value;

- (id)initWithSchema:(id)schema value:(NSString *)valueParam
{
	if (self = [super init]) {
		self.mSchema = schema;
		self.value = valueParam;
		return self;
	}
	return nil;
}

- (NSString *)title
{
	// it's either a string or a dictionary
	if ([mSchema isKindOfClass:[NSString class]])
		return mSchema;
	else
		return [mSchema objectForKey:@"PropertyTitle"];
}

- (NSString *)placeholder
{
	// it's either a string or a dictionary
	if ([mSchema isKindOfClass:[NSString class]] || ![mSchema objectForKey:@"Placeholder"])
		return @"";																						// simple string, no placeholder
	return [NSString stringWithFormat:@"<%@>", [mSchema objectForKey:@"Placeholder"]];
}

- (NSString *)identifier
{
	return [mSchema objectForKey:@"PropertyID"];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<Property: <Value: %@>>", value];
}

- (NSMutableDictionary *)dictionaryFromInstance
{
	return [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:value, @"Value", [mSchema objectForKey:@"PropertyID"], @"PropertyID", nil]];
}


@end

//	Subclassed from NSDictionary, to make it sortable

@implementation NSMutableDictionary (Sorting)

- (NSComparisonResult)compareCitations:(NSMutableDictionary *)operand
{
//	NSLog(@"name1 = %@, name2 = %@, result = %d", [self objectForKey:@"Name"], [operand objectForKey:@"Name"], [(NSString *)[self objectForKey:@"Name"] compare:(NSString *)[self objectForKey:@"Name"]]);
//	NSLog(@"classname = %s", object_getClassName([self objectForKey:@"Name"]));
	return [[self objectForKey:@"Name"] caseInsensitiveCompare:[operand objectForKey:@"Name"]];
}

@end


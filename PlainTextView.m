//
//  PlainTextView.m
//  TermPaper
//
//  Created by daltman on 4/30/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

/*
 Overrides the built in paste method. Converts formatted text to correct font and size for draft view
 */

#import "PlainTextView.h"
#import "TermPaperTextViewController.h"

@implementation PlainTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)paste:(id)sender
{
	NSLog(@"types = %@", [[UIPasteboard generalPasteboard] pasteboardTypes]);
	if ([[[UIPasteboard generalPasteboard] pasteboardTypes] containsObject:@"public.rtf"]) {						// styled text
		NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"public.rtf"];
		NSError *error;
		self.pastedString = [[NSAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType} documentAttributes:nil error:&error];
		NSAssert1(!error.description, @"Error accessing attributed text in paste method, error = %@", error.description);
		[(TermPaperTextViewController *) self.delegate paste:sender];
	} else if ([[[UIPasteboard generalPasteboard] pasteboardTypes] containsObject:@"com.apple.rtfd"]) {						// styled text
		NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"com.apple.rtfd"];
		NSError *error;
		self.pastedString = [[NSAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType} documentAttributes:nil error:&error];
		NSAssert1(!error.description, @"Error accessing attributed text in paste method, error = %@", error.description);
		[(TermPaperTextViewController *) self.delegate paste:sender];
	} else if ([[[UIPasteboard generalPasteboard] pasteboardTypes] containsObject:@"public.plain"]) {								// plain text
		NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"public.plain"];
		NSError *error;
		self.pastedString = [[NSAttributedString alloc] initWithData:data options:nil documentAttributes:nil error:&error];
		NSAssert1(!error.description, @"Error accessing attributed text in paste method, error = %@", error.description);
		[(TermPaperTextViewController *) self.delegate paste:sender];
	} else if ([[[UIPasteboard generalPasteboard] pasteboardTypes] containsObject:@"public.plain-text"]) {					// plain text
		NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"public.plain-text"];
		NSError *error;
		self.pastedString = [[NSAttributedString alloc] initWithData:data options:nil documentAttributes:nil error:&error];
		NSAssert1(!error.description, @"Error accessing attributed text in paste method, error = %@", error.description);
		[(TermPaperTextViewController *) self.delegate paste:sender];
	}
	// don't paste anything other than text (e.g., images)!
}

@end

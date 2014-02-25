//
//  PaperListTableViewController.h
//  TermPaper
//
//  Created by daltman on 6/23/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "TermPaperModel.h"
#import "PaperDetailTableViewController.h"
#import "CitationListTableViewController.h"
#import "TermPaperTextViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface RenameViewController : UIViewController {

}

@end

@interface PaperListTableViewController : UITableViewController <UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, DBRestClientDelegate> {
//	IBOutlet TermPaperTextViewController*		viewController;
	NSArray*									paperNames;					// paper name strings
	IBOutlet PaperDetailTableViewController*	paperDetailTableController;	// TODO: initialize
	IBOutlet CitationListTableViewController*	citationTableController;	// TODO: initialize
	UIPopoverController*						popoverViewController;		// TODO: initialize

	IBOutlet UIBarButtonItem*					addPaper;
	IBOutlet UIBarButtonItem*					deletePaper;
	IBOutlet UIBarButtonItem*					renamePaper;
	IBOutlet UIBarButtonItem*					duplicatePaper;
	IBOutlet UIBarButtonItem*					actionPaper;

	UIActionSheet*								deletePaperActionSheet;
	UIActionSheet*								exportPaperActionSheet;
	BOOL										exportPaperActionSheetVisible;
	
	IBOutlet UIToolbar*							toolbar;

	DBRestClient*								_restClient;
}

- (void)setDeleteButtonEnabled;
- (IBAction)handleAddPaper:(id)sender;
- (IBAction)handleDeletePaper:(id)sender;
- (IBAction)handleRenamePaper:(id)sender;
- (IBAction)handleDuplicatePaper:(id)sender;
- (IBAction)handleActionPaper:(id)sender;
- (IBAction)handleEmailFeedbackButton:(id)sender;
- (IBAction)handleExportPDFButton:(id)sender;
- (IBAction)handleEmailPDFButton:(id)sender;
- (IBAction)handleExportDOCXButton:(id)sender;
- (IBAction)handleEmailDOCXButton:(id)sender;
- (IBAction)handlePaperPick:(NSString *)selectedPaperName;

// following properties are initialized by the owner after instantiation
@property (nonatomic, strong) NSArray* paperNames;
@property (nonatomic, strong) UIPopoverController *popoverViewController;
@property (nonatomic) BOOL exportPaperActionSheetVisible;
@property (nonatomic, strong) TermPaperTextViewController*		viewController;
@property (nonatomic, readonly) DBRestClient*			restClient;							// Dropbox
@end


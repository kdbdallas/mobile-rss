#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UITable.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UITransitionView.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UINavBarButton.h>
#import <UIKit/UIProgressIndicator.h>
#import "EyeCandy.h"
#import "Settings.h"
#import "FMDatabase/FMDatabase.h"
#import "ThreadProcesses.h"

@protocol feedViewDelegateProto
	- (NSString*) fontForInt: (int)index;
	- (NSString*) getSettingsPath;
	- (void) hideFeed;
	- (UIWindow*) getWindow;
	- (NSString*) getSettingsDIR;
	- (void) showItem:(int)row fromView:(NSString*)fView feed:(int)feedsID;
	- (id) getFeedView;
@end

@interface FeedView : UIView {
	id<feedViewDelegateProto> _delegate;
	int _feedsID;
	EyeCandy *_eyeCandy;
	UITransitionView *transitionView;
	Settings *_settingsView;
	UINavigationBar *navBar;
	UITable *_viewTable;
	UITableColumn *_viewTableCol;
	NSString *_font;
	float _fontSize;
	FMDatabase *db;
	NSString *_appLibraryPath;
	BOOL DBExists;
	UINavigationBar *botNavBar;
	UIProgressIndicator *_spinner;
	UITextLabel *_spinnerLabel;
	NSString *__title;
	UIAlertSheet *alertSheetMarkAll;
}

- (id) initWithFrame: (struct CGRect)rect withFeed:(int)feedID withTitle:(NSString*)title;
- (void) setDelegate: (id)delegate;
- (void) dealloc;
- (void) clearAll;
- (void) markAll;
- (void) markAllRead;
- (void) markAllUnread;
- (void) clearAllQ;
- (int) getFeedsID;
- (void) clearSpinner;
- (void) clearRead;
- (void) startRefresh;
- (void) reloadTableData;
- (void) processPlistWithPath:(id)param;
- (void) finishLoad:(id)param;

@end
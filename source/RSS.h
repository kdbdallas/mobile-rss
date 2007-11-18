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
#import <UIKit/UIProgressHUD.h>
#import <UIKit/UIAlertSheet.h>
#import <UIKit/UIProgressIndicator.h>
#import "Feeds.h"
#import "FeedView.h"
#import "Settings.h"
#import "ItemView.h"
#import "EyeCandy.h"
#import "FMDatabase/FMDatabase.h"
#include <unistd.h>
#include <sys/sysctl.h>
#import "ThreadProcesses.h"

@interface MobileRSS : UIApplication {
	UIWindow *window;
	UIView *mainView;
	UINavigationBar *navBar;
	UINavigationBar *botNavBar;
	UITable *_viewTable;
	UITableColumn *_viewTableCol;
	UITransitionView *transitionView;
	NSString *settingsPath;
	Settings *_settingsView;
	EyeCandy *_eyeCandy;
	Feeds *_feeds;
	UIProgressHUD *progress;
	NSMutableArray *_content;
	ItemView *_itemViewView;
	NSString *_appLibraryPath;
	BOOL DBExists;
	FMDatabase *db;
	NSString *_font;
	float _fontSize;
	int _numFeeds;
	NSMutableArray *feedInfo;
	int totalUnread;
	FeedView *_feedView;
	UIProgressIndicator *_spinner;
	UITextLabel *_spinnerLabel;
	UIAlertSheet *alertSheetMarkAll;
	UITextLabel *_title;
}

- (void) processPlistWithPath:(id)param;
- (pid_t) FindPID;
- (NSString*) getSettingsDIR;
- (NSString*) getSettingsPath;
- (UIWindow*) getWindow;
- (void) showSettings;
- (void) hideSettingsView;
- (void) markAllRead;
- (void) clearAllQ;
- (void) clearAll;
- (void) clearRead;
- (void) reloadTable;
- (void) clearSpinner;
- (void) markAllUnread;
- (void) showFeed: (int)row;
- (void) hideFeed;
- (void) startAllRefresh;
- (FeedView*) getFeedView;
- (void) dealloc;
- (void) showItem:(int)row fromView:(NSString*)fView feed:(int)feedsID;
- (void) hideItemView;
- (void) updateAppBadge:(NSString*)value;
- (void) clearAppBadge;
- (NSString*) fontForInt: (int)index;
- (void)applicationWillTerminate;

@end
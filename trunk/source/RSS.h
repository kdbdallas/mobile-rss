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
#import "Feeds.h"
#import "ItemView.h"
#import "SettingsView.h"
#import "EyeCandy.h"
#import "toolBar.h"

@interface MobileRSS : UIApplication {
	UIWindow *window;
	UIView *mainView;
	UINavigationBar *navBar;
	UITable *_viewTable;
	UITableColumn *_viewTableCol;
	UITransitionView *transitionView;
	NSMutableDictionary *feedsAndItems;
	NSString *settingsPath;
	SettingsView *_settingsView;
	EyeCandy *_eyeCandy;
	Feeds *_feeds;
	UIProgressHUD *progress;
	NSMutableArray *_content;
	ItemView *_itemViewView;
}

- (void) processPlistWithPath:(id)param;
- (NSString*) getSettingsPath;
- (UIWindow*) getWindow;
- (void) showSettings;
- (void) dealloc;
- (void) addItem:(NSMutableDictionary *)item;
- (void) showItem:(int)row fromView:(NSString*)fView;
- (void) hideItemView;

@end
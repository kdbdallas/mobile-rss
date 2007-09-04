#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIView.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import "EyeCandy.h"

@interface SettingsView : UIView {
	UIPreferencesTable *_prefsTable;
	UIPreferencesTableCell *_prefsHeader;
	NSDictionary *plistDict;
	NSMutableArray *feedInputs;
	NSString *_settingsPath;
	id _delegate;
	int _rowSelected;
	int _editingRow;
}

- (id) initWithFrame: (struct CGRect)rect withSettingsPath: (NSString*)settingsPath;
- (NSDictionary*) loadSettings: (NSString*)settingsPath;
- (void) readSettings: (NSString*)settingsPath;
- (void) writeSettings: (NSString*)settingsPath;
- (void) addFeed;
- (void) removeFeed;
- (void)setDelegate: (id)delegate;
- (void) dealloc;

@end
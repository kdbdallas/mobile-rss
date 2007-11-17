#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIView.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UISwitchControl.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UITransitionView.h>
#import <UIKit/UIPickerView.h>
#import <UIKit/UIPickerTable.h>
#import <UIKit/UIPickerTableCell.h>
#import "EyeCandy.h"
#import "FeedList.h"
#import "Import.h"

@protocol settingsDelegateProto
	- (void) hideSettingsView;
	- (NSString*) getSettingsDIR;
	- (UIWindow*) getWindow;
	- (void)openURL:(id)fp8;
@end

@interface Settings : UIView {
	UIPreferencesTable *_prefsTable;
	UIPreferencesTextTableCell *_keepForTitleCell;
	UIPreferencesTextTableCell *_keepForCell;
	UIPreferencesTextTableCell *_chooseFontCell;
	UIPreferencesTextTableCell *_fontSizeCell;
	UIPreferencesTextTableCell *_refreshEveryCell;
	id<settingsDelegateProto> _delegate;
	UISliderControl *_keepForSlider;
	UISliderControl *_fontSizeSlider;
	UINavigationBar *navBar;
	UIPreferencesTextTableCell *_manageFeeds;
	UIPreferencesTextTableCell *_importFeeds;
	UITransitionView *transitionView;
	FeedList *_FeedListView;
	NSString *_settingsPath;
	Import *_ImportView;
	UIPickerView *fontChooser;
	UIPickerView *refreshPicker;
	UITableColumn *_pickerCol;
	UIPickerTable *_table;
	BOOL _isSelecting;
	int storedRefresh;
	int storedFont;
	NSDictionary *plistDict;
}

- (id) initWithFrame: (struct CGRect)rect withSettingsPath: (NSString*)settingsPath;
- (void)setDelegate: (id)delegate;
- (void) dealloc;
- (NSString*) getSettingsDIR;
- (UIWindow*) getWindow;
- (void) setFontSize: (int)value;
- (void) setKeepFor: (int)value;
- (void) hideFeedList;
- (void) hideImport;
- (void) saveSettings;
- (NSDictionary*) loadSettings: (NSString*)path;
- (void) readSettings: (NSString*)path;

@end
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
#import <UIKit/UITextField.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITextLabel.h>
#import <WebCore/WebFontCache.h>
#import <GraphicsServices/GraphicsServices.h>
#import "FMDatabase/FMDatabase.h"
#import "EditorKeyboard.h"
#import "UIView-Color.h"
#import "FeedTextField.h"
#import "FeedTable.h"
#import "FeedTableCell.h"
#import "QuickAdd.h"
#import "EyeCandy.h"

@protocol feedListDelegateProto
	- (NSString*) getSettingsDIR;
	- (UIWindow*) getWindow;
	- (void) hideFeedList;
@end

@interface FeedList : UIView {
	NSString *_settingsPath;
	UINavigationBar *navBar;
	UINavigationBar *bottomNavBar;
	FeedTable *_viewTable;
	UITableColumn *_viewTableCol;
	UITransitionView *transitionView;
	id<feedListDelegateProto> _delegate;
	int _movedRow;
	int _prevSelected;
	int _prevSuggestedRow;
	int _currSelectedRow;
	NSMutableDictionary *feeds;
	NSMutableArray *feedArray;
	NSMutableArray *feedCellArray;
	NSMutableArray *feedEditors;
	UIImageAndTextTableCell *cell;
	EditorKeyboard *_keyboard;
	UITextView *custom_field_editor;
	BOOL _isEditing;
	BOOL _isDeleting;
	QuickAdd *_QuickAddView;
	int deletingRow;
	EyeCandy *_eyeCandy;
}

- (id) initWithFrame: (struct CGRect)rect withSettingsPath: (NSString*)settingsPath;
- (void)setDelegate: (id)delegate;
- (void) addNewTextField;
- (void) dealloc;
- (void) loadSettings;
- (void) makeEditable;
- (void) makeSortable;
- (void) disableCellReordering;
- (void) makeRemovable;
- (void) showQuickAdd;
- (void) removeRow: (int)row;
- (BOOL) getIsDeleting;
- (void) setDeletingRow: (int)row;
- (int) getDeletingRow;
- (void) saveFeeds:(id)param;

@end
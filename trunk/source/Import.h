#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <WebCore/WebFontCache.h>
#import <GraphicsServices/GraphicsServices.h>
#import <UIKit/UITextLabel.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIView.h>
#import <UIKit/UINavBarButton.h>
#import <UIKit/UITransitionView.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UISwitchControl.h>
#import "EyeCandy.h"
#import "UIView-Color.h"
#import "FMDatabase/FMDatabase.h"

@protocol importDelegateProto
	- (NSXMLNode*)attributeForName:(NSString*)name;
	- (void) hideImport;
	- (UIWindow*) getWindow;
@end

@interface Import : UIView {
	id<importDelegateProto> _delegate;
	UITransitionView *transitionView;
	UIPreferencesTable *_Table;
	UINavigationBar *navBar;
	UIPreferencesTableCell *_infoTitle;
	UIPreferencesTableCell *_infoText;
	UIPreferencesTableCell *_overwriteCell;
	UISwitchControl *_overwriteSwitch;
	UINavBarButton *_backBtn;
	UITable *importTable;
	UITableColumn *_importTableCol;
	NSMutableArray *files;
	NSFileManager *NSFm;
	NSXMLDocument *xmlDoc;
	EyeCandy *_eyeCandy;
}

- (id) initWithFrame: (struct CGRect)rect;
- (void) lookForFiles;
- (void) import:(id)param;
- (void)setDelegate: (id)delegate;
- (void) dealloc;

@end
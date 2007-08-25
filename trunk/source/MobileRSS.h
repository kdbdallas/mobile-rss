#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UITable.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIAlertSheet.h>
#import <UIKit/UIProgressHUD.h>
#import <UIKit/UITransitionView.h>
#import <UIKit/UITextView.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UISwitchControl.h>
#import <UIKit/UIPushButton.h>
#import <WebCore/WebFontCache.h>
#import <UIKit/UINavBarButton.h>

@interface MobileRSS : UIApplication {
        UIWindow *window;
		UIView *mainView;
		UIView *itemView;
		UIView *settingsView;
		UINavigationBar *navBar;
		UITextLabel *title;
		NSMutableData *_responseData;
		UITable* _viewTable;
		UITableColumn* _viewTableCol;
		int _rowCount;
		id _delegate;
		NSMutableArray *_items;
		NSXMLDocument *xmlDoc;
		UIAlertSheet *alert;
		NSArray *alertButton;
		UIProgressHUD *progress;
		UITransitionView *transitionView;
		UITextView *textView;
		NSMutableArray *feedItemTitles;
		NSMutableArray *feedItemDesc;
		NSMutableArray *feedItemLinks;
		NSMutableArray *feedItemDates;
		NSString *_fromView;
		NSURLConnection *theConnection;
		int _clickedRow;
		UITransitionView *_transitionView;
		NSString *_settingsPath;
		UIPreferencesTable *_prefsTable;
		UIPreferencesTableCell *_prefsHeader;
		UIPreferencesTextTableCell *_prefsFeed;
		NSString *feedTitle;
}

- (void) handleError: (NSError*) err;
- (void)getFeed:(NSString *)URL;
- (NSString*)loadSettings;
- (void)setTitle;
- (void) parseXMLDocument:(NSXMLDocument *)document;
- (void) connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)reloadData;
- (void)setDelegate:(id)delegate;
- (int)numberOfRowsInTable:(UITable *)table;
- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col;
- (void)showProgressHUD:(NSString *)label withWindow:(UIWindow *)w withView:(UIView *)v withRect:(struct CGRect)rect;
- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button;
- (void) showSettings;
- (void) readSettings;
- (void) writeSettings;
- (void) closeSettings;
- (void) saveAndCloseSettings;
- (void) visitLink;
- (void)hideProgressHUD;

@end
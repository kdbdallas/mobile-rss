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
#import "ItemView.h"

@interface MobileRSS : UIApplication {
        UIWindow *window;
		UIView *mainView;
		UINavigationBar *navBar;
		NSString *URL;
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
		NSMutableArray *feedItemTitles;
		NSMutableArray *feedItemDesc;
}

- (void) handleError: (NSError*) err;
- (void) parseXMLDocument:(NSXMLDocument *)document;
- (void) connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)reloadData;
- (void)setDelegate:(id)delegate;
- (int)numberOfRowsInTable:(UITable *)table;
- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col;
- (void)showProgressHUD:(NSString *)label withWindow:(UIWindow *)w withView:(UIView *)v withRect:(struct CGRect)rect;
- (void)hideProgressHUD;

@end
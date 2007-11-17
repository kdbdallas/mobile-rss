#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIView.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UINavBarButton.h>
#import <UIKit/UITextView.h>
#import <UIKit/UISegmentedControl.h>
#import "EyeCandy.h"
#import "Settings.h"
#import "FMDatabase/FMDatabase.h"

@protocol itemViewDelegateProto
	- (void) hideItemView;
	- (void) showItem:(int)row fromView:(NSString*)fView feed:(int)feedsID;
	- (UIWindow*) getWindow;
	- (void)openURL:(id)fp8;
@end

@interface ItemView : UIView {
	id<itemViewDelegateProto> _delegate;
	UINavigationBar *navBar;
	UITextView *textView;
	int _row;
	int _feedItemsID;
	int _feedsID;
	NSDictionary *_item;
	EyeCandy *_eyeCandy;
	FMDatabase *db;
	NSString *_visitLink;
	UINavigationBar *botNavBar;
	UISegmentedControl *direcBtns;
}

- (id) initWithFrame: (struct CGRect)rect withRow:(int)row withFeed:(int)feedsID;
- (void) finishLoad:(id)param;
- (void) addTextView:(id)param;
- (void) setRow: (int)row;
- (void) visitLink;
- (void) setFeedsID: (int)feedsID;
- (void)setDelegate: (id)delegate;
- (void) deleteItemQ;
- (void) deleteItem;
- (void) prevItem;
- (void) nextItem;
- (void) dealloc;

@end
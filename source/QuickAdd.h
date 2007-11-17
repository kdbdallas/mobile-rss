#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIView.h>
#import <UIKit/UITransitionView.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UIImageView.h>
#import "EyeCandy.h"

@protocol quickAddDelegateProto
	- (void) hideQuickAdd;
	- (void) quickAdd: (NSString*)URL;
@end

@interface QuickAdd : UIView {
	id<quickAddDelegateProto> _delegate;
	UITransitionView *transitionView;
	UIPreferencesTable *_Table;
	UIPreferencesTableCell *_DiggFeed;
	UIPreferencesTableCell *_EngadgetFeed;
	UIPreferencesTableCell *_SlashdotFeed;
	UIPreferencesTableCell *_YahooFeed;
	UIPreferencesTableCell *_AppleFeed;
	UINavigationBar *navBar;
	NSMutableArray *quickAdds;
}

- (id) initWithFrame: (struct CGRect)rect;
- (void) reloadTable;
- (void)setDelegate: (id)delegate;
- (void) dealloc;

@end
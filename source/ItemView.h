#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UITransitionView.h>
#import <UIKit/UITextView.h>
#import <UIKit/UINavigationBar.h>

@interface ItemView : UIView
{
	UINavigationBar *navBar;
	UITextView *textView;
	NSArray *_feedItemTitles;
	NSArray *_feedItemDesc;
}

- (id)initWithFrame:(CGRect)frame;
- (void)dealloc;
- (void)fillWithData:(NSArray *)feedItemTitles withFeedItemDesc:(NSArray *)feedItemDesc;
- (void)showDataAtIndex:(int)row;

@end
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
#import "MobileRSS.h"

@interface ItemView : UIView
{
	UINavigationBar *navBar;
	UITextView *textView;
}

- (id)initWithFrame:(CGRect)frame atIndex:(int)row withFeedItemTitles:(NSArray *)feedItemTitles withFeedItemDesc:(NSArray *)feedItemDesc;
//- (void)dealloc;

@end
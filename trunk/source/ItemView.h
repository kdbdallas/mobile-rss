#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIView.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UINavBarButton.h>
#import <UIKit/UITextView.h>

@interface ItemView : UIView {
	id _delegate;
	UINavigationBar *navBar;
	UITextView *textView;
	int _row;
	NSDictionary *_item;
}

- (id) initWithFrame: (struct CGRect)rect withItem: (NSDictionary*)item withRow:(int)row;
- (void) setItem: (NSDictionary*)i;
- (void) setRow: (int)row;
- (void) visitLink;
- (void)setDelegate: (id)delegate;
- (void) dealloc;

@end
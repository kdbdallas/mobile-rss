#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIView.h>
#import <UIKit/UIBezierPath.h>

@interface toolBar : UIView {
	id _delegate;
	UIPushButton *_addButton;
	UIPushButton *_removeButton;
	UIPushButton *_saveButton;
}

- (void)setDelegate:(id)object;
- (id)delegate;

@end
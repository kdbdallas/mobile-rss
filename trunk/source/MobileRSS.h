#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UITextView.h>

@interface MobileRSS : UIApplication {
        UIWindow *window;
		UIView *mainView;
		UINavigationBar *_navBar;
		NSString *URL;
		UITextView  *textView;
		NSMutableData *_responseData;
}

- (void) handleError: (NSError*) err;
- (void) parseXMLDocument:(NSXMLDocument *)document;
- (void) connectionDidFinishLoading:(NSURLConnection *)connection;

@end
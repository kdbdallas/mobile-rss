#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EyeCandy.h"
#import "SettingsView.h"

@interface Feeds : UIApplication {
	NSURLConnection *theConnection;
	NSMutableData *_responseData;
	EyeCandy *_eyeCandy;
	NSXMLDocument *xmlDoc;
	NSArray *statusNodes;
	SettingsView *_settingsView;
	NSMutableArray *Items;
}

- (NSMutableArray*) pullFeedURL:(NSString*)FeedURL;
- (NSMutableArray*) processXML:(NSData*)data;
- (NSArray*) returnArray;
- (void) groupItems:(NSMutableDictionary*)content;
- (void) initArray;

@end
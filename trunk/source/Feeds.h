#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EyeCandy.h"
#import "Settings.h"

@protocol XMLClassProto
	- (NSXMLNode*)attributeForName:(NSString*)name;
@end

@interface Feeds : UIApplication {
	NSURLConnection *theConnection;
	NSMutableData *_responseData;
	EyeCandy *_eyeCandy;
	NSXMLDocument *xmlDoc;
	NSArray *statusNodes;
	Settings *_settingsView;
	NSMutableArray *Items;
	BOOL addedIt;
}

- (NSMutableArray*) pullFeedURL:(NSString*)FeedURL;
- (NSMutableArray*) processXML:(NSData*)data;
- (NSArray*) returnArray;
- (void) groupItems:(NSMutableDictionary*)content;
- (void) initArray;
- (void) dealloc;

@end
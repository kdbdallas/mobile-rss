#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EyeCandy.h"
#import "Settings.h"

@protocol XMLClassProto
	- (NSXMLNode*)attributeForName:(NSString*)name;
@end

@protocol FeedsDelegateProto
	- (void) showErrGetFeed: (NSString*)url;
	- (void)performSelectorOnMainThread:(SEL)fp8 withObject:(id)fp12 waitUntilDone:(BOOL)fp16;
@end

@interface Feeds : UIApplication {
	//NSURLConnection *theConnection;
	//NSMutableData *_responseData;
	EyeCandy *_eyeCandy;
	NSXMLDocument *xmlDoc;
	NSArray *statusNodes;
	Settings *_settingsView;
	NSMutableArray *Items;
	BOOL addedIt;
	NSString *_URL;
	id<FeedsDelegateProto> _delegate;
}

- (NSMutableArray*) pullFeedURL:(NSString*)FeedURL;
- (NSMutableArray*) processXML:(NSData*)data withURL:(NSString*)url;
- (NSArray*) returnArray;
- (void) groupItems:(NSMutableDictionary*)content;
- (void) initArray;
- (void)setDelegate: (id)delegate;
- (void) dealloc;

@end
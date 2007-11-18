#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Feeds : UIApplication {
	NSURLConnection *theConnection;
	NSMutableData *_responseData;
	NSXMLDocument *xmlDoc;
	NSArray *statusNodes;
	NSMutableArray *Items;
	BOOL addedIt;
}

- (void) pullFeedURL:(NSString*)FeedURL;
- (void) processXML:(NSData*)data;
- (NSArray*) returnArray;
- (void) groupItems:(NSMutableDictionary*)content;
- (void) initArray;
- (void) dealloc;

@end
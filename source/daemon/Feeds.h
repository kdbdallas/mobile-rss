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

- (NSMutableArray*) pullFeedURL:(NSString*)FeedURL;
- (NSMutableArray*) processXML:(NSData*)data;
- (NSArray*) returnArray;
- (void) groupItems:(NSMutableDictionary*)content;
- (void) initArray;
- (void) dealloc;

@end
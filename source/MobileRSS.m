#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import "MobileRSS.h"

@implementation MobileRSS

- (void) applicationDidFinishLaunching: (id) unused
{	
	window = [[UIWindow alloc] initWithContentRect:
		 [UIHardware fullScreenApplicationContentRect]
	];

	struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;

	mainView = [[UIView alloc] initWithFrame: rect];
	
	[window setContentView: mainView]; 
	[window orderFront: self];
	[window makeKey: self];
	[window _setHidden: NO];
	
	textView = [[UITextView alloc]
        initWithFrame: CGRectMake(0.0f, 40.0f, 320.0f, 245.0f - 40.0f)];
    [textView setEditable:YES];
    [textView setTextSize:14];

	[window setContentView: mainView];
    [mainView addSubview:textView];
	
	URL = @"http://digg.com/rss/index.xml";
	
    NSURL *rssurl = [NSURL URLWithString:URL];

	if (!rssurl)
	{
        NSLog(@"Can't create an URL from file %@.", URL);
        return;
    }
	
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:URL]
	                        cachePolicy:NSURLRequestUseProtocolCachePolicy
	                    timeoutInterval:60.0];
					NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];

	if (theConnection) {
	    // Create the NSMutableData that will hold the received data receivedData is declared as a method instance elsewhere
	    _responseData=[[NSMutableData data] retain];
	} else {
	    // inform the user that the download could not be made
		NSLog(@"so sorry");
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it has enough information to create the NSURLResponse
    // it can be called multiple times, for example in the case of a redirect, so each time we reset the data.
    [_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData receivedData is declared as a method instance elsewhere
    [_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];

    // receivedData is declared as a method instance elsewhere
    [_responseData release];
 
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSError *err = nil;
	
    NSLog(@"Succeeded! Received %d bytes of data",[_responseData length]);

	NSData *data = [_responseData retain];
	
	NSString *helperAppName = [[NSString alloc] initWithData:_responseData encoding:[NSString defaultCStringEncoding]];
	
	[textView setText: helperAppName];

	/* NOTE: This way of doing NSXMLDocument is to work around a problem with the
	ARM linker. For some reason, it does not see the NSXMLDocument symbol that is defined
	in the OfficeImport framework. So we resolve the symbol at runtime.
	Thanks to Lucas Newman for figuring out this workaround.*/
	NSXMLDocument *xmlDoc = [[[NSClassFromString(@"NSXMLDocument") alloc] initWithXMLString:helperAppName options:NSXMLNodeOptionsNone error:&err] autorelease];
	//NSXMLDocument *xmlDoc = [[[NSClassFromString(@"NSXMLDocument") alloc] initWithData:_responseData options:NSXMLNodeOptionsNone error:&err] autorelease];

	[self parseXMLDocument:xmlDoc];
	
	NSArray *statusNodes = [[[xmlDoc children] lastObject] children];
	
	NSLog([NSString stringWithFormat:@"%d", [statusNodes count]]);

    // release the connection, and the data object
    [connection release];
    [_responseData release];
	[data release];
}

- (void) parseXMLDocument:(NSXMLDocument *)document
{
	NSError *err=nil;
	NSXMLElement *thisCity;

	NSArray *nodes = [document nodesForXPath:@"/rss/channel/item" error:&err];

	if ([nodes count] > 0 ) {
	    thisCity = [nodes objectAtIndex:0];
		NSLog([thisCity stringValue]);
	}
	else
	{
		NSLog(@"Count less than 1");
	}

	if (err != nil) {
	    [self handleError:err];
	}
}

- (void) applicationWillSuspend
{
   //
}

- (void) handleError: (NSError*) err
{
	NSLog(@"Error: %@", [NSString stringWithFormat:@"%d", [err localizedFailureReason]]);
	exit(0);
}

@end
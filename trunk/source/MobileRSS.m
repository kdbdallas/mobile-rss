#import <UIKit/UISimpleTableCell.h>
#import "MobileRSS.h"
#import "ItemView.h"

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

	// Transition view
	transitionView = [[UITransitionView alloc] initWithFrame:rect];
	[mainView addSubview:transitionView];
	
	navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 70.0f)];
	[navBar showButtonsWithLeftTitle: @"Back" rightTitle: @"Home" leftBack: TRUE];
    [navBar setBarStyle: 3];
	[navBar setDelegate: self];
	[mainView addSubview: navBar];
	
	[navBar setPrompt: @"Digg RSS"];
	
	_viewTableCol = [[UITableColumn alloc]
		initWithTitle: @"Feed Items"
		identifier:@"items"
		width: rect.size.width
	];

	_viewTable = [[UITable alloc] initWithFrame: CGRectMake(0.0f, 70.0f, 320.0f, rect.size.height - 70.0f)];
	[_viewTable addTableColumn: _viewTableCol];
	[_viewTable setSeparatorStyle: 1];
	[_viewTable setDelegate: self];
	[_viewTable setDataSource: self];

	[window setContentView: mainView];
    [mainView addSubview:_viewTable];
	
	[self showProgressHUD:@"Loading..." withWindow:window withView:mainView withRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];

	_items = [[NSMutableArray alloc] init];
	_rowCount = 0;
	
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

- (void)showProgressHUD:(NSString *)label withWindow:(UIWindow *)w withView:(UIView *)v withRect:(struct CGRect)rect
{
	progress = [[UIProgressHUD alloc] initWithWindow: w];
	[progress setText: label];
	[progress drawRect: rect];
	[progress show: YES];
	
	[v addSubview:progress];
}

- (void)hideProgressHUD
{
	[progress show: NO];
	[progress removeFromSuperview];
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

	[self hideProgressHUD];

	alertButton = [NSArray arrayWithObjects:@"Close",nil];
	alert = [[UIAlertSheet alloc] initWithTitle:@"Error: Connection failed!" buttons:alertButton defaultButtonIndex:0 delegate:self context:nil];
	[alert setBodyText: [error localizedDescription]];
	[alert popupAlertAnimated: TRUE];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSError *err = nil;
	
	NSData *data = [_responseData retain];
	
    //NSLog(@"Succeeded! Received %d bytes of data",[data length]);

	/* NOTE: This way of doing NSXMLDocument is to work around a problem with the
	ARM linker. For some reason, it does not see the NSXMLDocument symbol that is defined
	in the OfficeImport framework. So we resolve the symbol at runtime.
	Thanks to Lucas Newman for figuring out this workaround.*/
	xmlDoc = [[[NSClassFromString(@"NSXMLDocument") alloc] initWithData:data options:NSXMLNodeOptionsNone error:&err] autorelease];

	[self parseXMLDocument:xmlDoc];

	[self hideProgressHUD];

    // release the connection, and the data object
    [connection release];
    [_responseData release];
	[data release];
}

- (void) parseXMLDocument:(NSXMLDocument *)document
{
	[_items removeAllObjects];
	
	_rowCount = 0;

	NSArray *statusNodes = [[[document children] lastObject] children];
	
	NSEnumerator *statusNodeEnumerator = [statusNodes objectEnumerator];
	NSEnumerator *childNodeEnum;
	NSEnumerator *itemEnum;
	NSXMLNode *statusNode = nil;
	NSXMLNode *childNode = nil;
	NSXMLNode *itemNode = nil;
	
	// create a dictionary where content from the status node will be collected
	//NSMutableDictionary *content = [[[NSMutableDictionary alloc] init] autorelease];

	//First should be channel
	while ((statusNode = [statusNodeEnumerator nextObject]))
	{
		if ([statusNode name] == @"title")
		{
			//NSLog([statusNode name]);
			//[content setValue:[statusNode name] forKey:@"feed"];
		}
		else if ([[statusNode children] count] > 0)
		{
			//Gives me all the items
			childNodeEnum = [[statusNode children] objectEnumerator];
			
			feedItemTitles = [[NSMutableArray alloc] initWithCapacity: [[statusNode children] count]];
			feedItemDesc = [[NSMutableArray alloc] initWithCapacity: [[statusNode children] count]];

			while((childNode = [childNodeEnum nextObject]))
			{
				itemEnum = [[childNode children] objectEnumerator];
				
				while((itemNode = [itemEnum nextObject]))
				{
					if ([[itemNode name] isEqualToString:@"title"])
					{
						//[content setValue:[itemNode stringValue] forKey:@"title"];
						[_items addObject: [itemNode stringValue]];
						[feedItemTitles addObject: [itemNode stringValue]];
					}
					else if ([[itemNode name] isEqualToString:@"description"])
					{
						//[content setValue:[itemNode stringValue] forKey:@"description"];
						[feedItemDesc addObject: [itemNode stringValue]];
					}
					else if ([[itemNode name] isEqualToString:@"pubDate"])
					{
						//[content setValue:[itemNode stringValue] forKey:@"pubDate"];
					}
				}
			}
		}
	}

	_rowCount = [_items count];
	[_viewTable reloadData];
}

- (void)reloadData {
	[self parseXMLDocument:xmlDoc];
}

- (void)setDelegate:(id)delegate {
	_delegate = delegate;
}

- (int)numberOfRowsInTable:(UITable *)table {
	return _rowCount;
}

- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col {
	UIImageAndTextTableCell *cell = [[UIImageAndTextTableCell alloc] init];
	[cell setTitle: [_items objectAtIndex: row]];
	[cell setImage: [UIImage imageAtPath:@"/Applications/RSS.app/bullet.png"]];
	
	return cell;
}

- (void) alertSheet: (UIAlertSheet*)sheet buttonClicked:(int)button
{
	[sheet dismissAnimated: TRUE];
}

- (void)tableSelectionDidChange:(int)row {
	

	//[transitionView transition:1 fromView:mainView toView:itemView];
	//[window setContentView: itemView]; 
}

- (BOOL)table:(UITable *)aTable canSelectRow:(int)row {
	//[self tableSelectionDidChange: row];
	ItemView *_itemView = [[ItemView alloc] initWithFrame:[UIHardware fullScreenApplicationContentRect] atIndex:row withFeedItemTitles:feedItemTitles withFeedItemDesc:feedItemDesc];
	[transitionView transition:1 fromView:mainView toView:_itemView];
	//[window setContentView: _itemView];
	return YES;
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

/*- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
 NSLog(@"Requested method for selector: %@", NSStringFromSelector(selector));
 return [super methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
NSLog(@"Request for selector: %@", NSStringFromSelector(aSelector));
return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
 NSLog(@"Called from: %@", NSStringFromSelector([anInvocation selector]));
[super forwardInvocation:anInvocation];
}*/

@end
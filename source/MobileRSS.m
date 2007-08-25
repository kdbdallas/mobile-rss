#import <UIKit/UISimpleTableCell.h>
#import "MobileRSS.h"

@implementation MobileRSS

- (void) applicationDidFinishLaunching: (id) unused
{
	window = [[UIWindow alloc] initWithContentRect:
		 [UIHardware fullScreenApplicationContentRect]
	];

	struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;
	
	if (_fromView == nil)
	{
		_fromView = [NSString stringWithString:@"mainView"];
	}

	mainView = [[UIView alloc] initWithFrame: rect];
	itemView = [[UIView alloc] initWithFrame: rect];
	settingsView = [[UIView alloc] initWithFrame: rect];
	
	[window setContentView: mainView]; 
	[window orderFront: self];
	[window makeKey: self];
	[window _setHidden: NO];
	
	//Setup settings info
	NSString *settingsPath = [[[[self userLibraryDirectory] 
		stringByAppendingPathComponent: @"Preferences"]
		stringByAppendingPathComponent: @"com.google.code.mobile-rss"]
		stringByAppendingPathExtension: @"plist"];

	_settingsPath = [[NSString alloc] initWithString: settingsPath];

	// Transition view
	transitionView = [[UITransitionView alloc] initWithFrame:rect];
	[mainView addSubview:transitionView];

	
	navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 30.0f)];
//	[navBar showButtonsWithLeftTitle: @"Back" rightTitle: @"Home" leftBack: TRUE];
    [navBar setBarStyle: 3];
	[navBar setDelegate: self];
	

	UIImage* btnImage = [UIImage applicationImageNamed:@"info_icon.png"];

	UIPushButton* pushButton = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
	[pushButton setFrame: CGRectMake(0.0, 0.0, 50.0, 30.0)];
	[pushButton setDrawsShadow: NO];
	[pushButton setEnabled:YES];
	[pushButton drawImageAtPoint: CGPointMake(20.0, 0) fraction: 0.0];
	[pushButton setStretchBackground:NO];
	[pushButton setBackground:btnImage forState:0];  //up state
	[pushButton addTarget: self action: @selector(showSettings) forEvents: 1];
	[navBar addSubview: pushButton];

	[mainView addSubview: navBar];
	
	_viewTableCol = [[UITableColumn alloc]
		initWithTitle: @"Feed Items"
		identifier:@"items"
		width: rect.size.width
	];

	_viewTable = [[UITable alloc] initWithFrame: CGRectMake(0.0f, 30.0f, 320.0f, rect.size.height - 30.0f)];
	[_viewTable addTableColumn: _viewTableCol];
	[_viewTable setSeparatorStyle: 1];
	[_viewTable setDelegate: self];
	[_viewTable setDataSource: self];
	[_viewTable setRowHeight: 36.0f];

	[window setContentView: mainView];
    [mainView addSubview:_viewTable];
	
	[self showProgressHUD:@"Loading..." withWindow:window withView:mainView withRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];
	
	if (![_fromView isEqualToString:@"itemView"])
	{		
		[self getFeed:[self loadSettings]];
	}
	else
	{
		//reset
		_fromView = [NSString stringWithString:@"mainView"];
		
		[_viewTable reloadData];
		[self hideProgressHUD];
	}
}

- (NSString*)loadSettings
{
	if ([[NSFileManager defaultManager] isReadableFileAtPath: _settingsPath])
	{
		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile: _settingsPath];
		NSEnumerator *enumerator = [settingsDict keyEnumerator];
		NSString *currKey;
		
		while (currKey = [enumerator nextObject]) 
		{
			if ([currKey isEqualToString: @"Feed"])
			{
				return [NSString stringWithString:[settingsDict valueForKey: currKey]];
			}
		}
	}
}

- (void)setTitle
{
	[navBar setPrompt: feedTitle];
}

- (void)getFeed:(NSString *)URL
{
	_items = [[NSMutableArray alloc] init];
	_rowCount = 0;
	
	NSURL *rssurl = [NSURL URLWithString:URL];

	if (!rssurl)
	{
        NSLog(@"Can't create an URL from file %@.", URL);
        return;
    }

	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:URL]
	                        cachePolicy:NSURLRequestUseProtocolCachePolicy
	                    timeoutInterval:60.0];
	
	theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];

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

	//First should be channel
	while ((statusNode = [statusNodeEnumerator nextObject]))
	{
		if ([[statusNode children] count] > 0)
		{
			//Gives me all the items
			childNodeEnum = [[statusNode children] objectEnumerator];
			
			feedItemTitles = [[NSMutableArray alloc] initWithCapacity: [[statusNode children] count]];
			feedItemDesc = [[NSMutableArray alloc] initWithCapacity: [[statusNode children] count]];
			feedItemLinks = [[NSMutableArray alloc] initWithCapacity: [[statusNode children] count]];
			feedItemDates = [[NSMutableArray alloc] initWithCapacity: [[statusNode children] count]];

			while((childNode = [childNodeEnum nextObject]))
			{
				if ([[childNode name] isEqualToString:@"title"])
				{
					feedTitle = [[NSString alloc] initWithString: [childNode stringValue]];
					[self setTitle];
				}
				
				itemEnum = [[childNode children] objectEnumerator];
				
				while((itemNode = [itemEnum nextObject]))
				{
					if ([[itemNode name] isEqualToString:@"title"])
					{
						[_items addObject: [itemNode stringValue]];
						[feedItemTitles addObject: [itemNode stringValue]];
					}
					else if ([[itemNode name] isEqualToString:@"description"])
					{
						[feedItemDesc addObject: [itemNode stringValue]];
					}
					else if ([[itemNode name] isEqualToString:@"pubDate"])
					{
						[feedItemDates addObject: [itemNode stringValue]];
					}
					else if ([[itemNode name] isEqualToString:@"link"])
					{
						[feedItemLinks addObject: [itemNode stringValue]];
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
	//[cell setImage: [UIImage applicationImageNamed:@"bullet.png"]];
	[cell setShowDisclosure: YES];
	[cell setDisclosureClickable: YES];
	
	return cell;
}

- (void) alertSheet: (UIAlertSheet*)sheet buttonClicked:(int)button
{
	[sheet dismissAnimated: TRUE];
}

- (void) visitLink
{
	[self openURL: [NSURL URLWithString:[[feedItemLinks objectAtIndex:_clickedRow] retain]]];
}

- (void)tableSelectionDidChange:(int)row {
	struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;
	
	navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 70.0f)];
	[navBar showButtonsWithLeftTitle: @"Back" rightTitle:@"Next >>" leftBack: TRUE];
    [navBar setBarStyle: 3];
	[navBar enableAnimation];
	[navBar setDelegate: self];

	UINavBarButton *_visitButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(110.0f, 37.0f, 80.0f, 32.0f)];
	[_visitButton setAutosizesToFit: FALSE];
	[_visitButton setTitle: @"Visit Link"];
	[_visitButton setNavBarButtonStyle:0];
	[_visitButton addTarget: self action: @selector(visitLink) forEvents: 1];
	[navBar addSubview: _visitButton];

	[self setTitle];

	[itemView addSubview: navBar];
	
	textView = [[UITextView alloc]
        initWithFrame: CGRectMake(0.0f, 70.0f, 320.0f, rect.size.height - 70.0f)];
    [textView setEditable:NO];
    [textView setTextSize:15];

	NSMutableString *fullText = [[NSMutableString alloc] initWithString: @"<b>"];
	[fullText appendString:[[feedItemTitles objectAtIndex:row] retain]];
	[fullText appendString:@"</b>"];
	[fullText appendString:@"<br/>"];
	[fullText appendString:@"<small>"];
	[fullText appendString:@"<i>"];
	[fullText appendString:[[feedItemDates objectAtIndex:row] retain]];
	[fullText appendString:@"</i>"];
	[fullText appendString:@"</small>"];
	[fullText appendString:@"<br/><br/>"];
	[fullText appendString:[[feedItemDesc objectAtIndex:row] retain]];

	[textView setHTML: fullText];
	
	[itemView addSubview: textView];

	if ([_fromView isEqualToString:@"itemView"])
	{
		[transitionView transition:7 fromView:mainView toView:itemView];
	}
	else
	{
		[transitionView transition:1 fromView:mainView toView:itemView];
	}
	
	[window setContentView: itemView];

	_clickedRow = row;
}

- (BOOL)table:(UITable *)aTable canSelectRow:(int)row {
	_fromView = [NSString stringWithString:@"mainView"];

	[self tableSelectionDidChange: row];
	return YES;
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;

	_fromView = [NSString stringWithString:@"itemView"];

	switch (button) 
	{
		case 0: //Next
			_clickedRow++;

			[self tableSelectionDidChange: _clickedRow];
		break;

		case 1:	//Back
			_transitionView = [[UITransitionView alloc] initWithFrame:rect];
			[itemView addSubview:_transitionView];

			[_transitionView transition:2 fromView:itemView toView:mainView];

			[self applicationDidFinishLaunching:nil];
		break;
	}
}

- (void) showSettings
{
	struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;

	_prefsTable = [[UIPreferencesTable alloc] initWithFrame: rect];
	[_prefsTable setDataSource: self];
    [_prefsTable setDelegate: self];
	[_prefsTable reloadData];
	
	_prefsHeader = [[UIPreferencesTableCell alloc] init];
	[_prefsHeader setTitle: @"RSS Settings"];
	[_prefsHeader setIcon: [UIImage applicationImageNamed: @"icon_small.png"]];
	
	_prefsFeed = [[UIPreferencesTextTableCell alloc] init];	
	[_prefsFeed setTitle: @"Feed"];
	
	[settingsView addSubview: _prefsTable];
	
	UIImage *btnImage = [UIImage applicationImageNamed:@"save.png"];
	UIImage *btnClickedImage = [UIImage applicationImageNamed:@"saveBtnClicked.png"];

	UIPushButton *pushButton = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
	[pushButton setFrame: CGRectMake(104.0, 150.0, 111.0, 33.0)];
	[pushButton setDrawsShadow: NO];
	[pushButton setEnabled:YES];
	[pushButton setDrawContentsCentered: TRUE];
	[pushButton setStretchBackground:NO];
	[pushButton setBackground:btnImage forState:0];  //up state
	[pushButton setBackground:btnClickedImage forState:1]; //down state
	[pushButton addTarget: self action: @selector(saveAndCloseSettings) forEvents: 1<<6];
	[settingsView addSubview: pushButton];

	[self readSettings];

	[mainView removeFromSuperview];
	[itemView removeFromSuperview];
	[mainView addSubview: settingsView];
	[window setContentView: settingsView];
}

- (void) readSettings
{
	//Set defaults
	[[_prefsFeed textField] setText: @"http://digg.com/rss/index.xml"];
	
	//Read in settings to replace defaults
	if ([[NSFileManager defaultManager] isReadableFileAtPath: _settingsPath])
	{
		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile: _settingsPath];
		NSEnumerator *enumerator = [settingsDict keyEnumerator];
		NSString *currKey;
		
		while (currKey = [enumerator nextObject]) 
		{
			if ([currKey isEqualToString: @"Feed"])
			{
				[[_prefsFeed textField] setText: [settingsDict valueForKey: currKey]];
			}
		}
	}
}

- (void) writeSettings
{
	NSString *error;

	NSString *feedURL = [[_prefsFeed textField] text];
	
	//Build settings dictionary
	NSDictionary *settingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
		feedURL, @"Feed",
		nil];
	
	//Seralize settings dictionary
	NSData *rawPList = [NSPropertyListSerialization dataFromPropertyList: settingsDict		
		format: NSPropertyListXMLFormat_v1_0
		errorDescription: &error];
	
	//Write settings plist file
	[rawPList writeToFile: _settingsPath atomically: YES];
}

- (void) closeSettings
{
	_fromView = [NSString stringWithString:@"settingsView"];

	[settingsView removeFromSuperview];
	[window setContentView: mainView];
	
	[self applicationDidFinishLaunching:nil];
}

- (void) saveAndCloseSettings
{
	[self writeSettings];
	[self closeSettings];
}

- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable*)table 
{
	return 2;
}

- (int) preferencesTable: (UIPreferencesTable*)table numberOfRowsInGroup: (int)group 
{
    switch (group) 
	{ 
        case 0: return 0;
		case 1: return 1;
		default: return 0;
    }
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForGroup: (int)group 
{
	switch (group)
	{
		case 0: return _prefsHeader;
		case 1: return _prefsHeader;
		default: return nil;
	}
}

- (BOOL) preferencesTable: (UIPreferencesTable*)table isLabelGroup: (int)group 
{
    switch (group)
	{
		case 0: return TRUE;
		case 1: return FALSE;
		default: return TRUE;
	}
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForRow: (int)row inGroup: (int)group 
{
	switch (group)
	{
		case 0: return _prefsHeader;
		case 1:
			switch (row)
			{
				case 0:	return _prefsFeed;
			}
		default: return nil;
	}
}

- (float) preferencesTable: (UIPreferencesTable*)table heightForRow: (int)row inGroup: (int)group withProposedHeight: (float)proposed 
{
	float groupLabelBuffer = 24.0f;
	
	switch (group)
	{
		case 0: return proposed + groupLabelBuffer;
		default: return proposed;
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
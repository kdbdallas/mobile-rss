#import "ItemView.h"

@implementation ItemView

- (id) initWithFrame: (struct CGRect)rect withRow:(int)row withFeed:(int)feedsID
{
	//Init view with frame rect
	[super initWithFrame: rect];

	[self setRow: row];
	[self setFeedsID: feedsID];
	
	mTransView = [[[UITransitionView alloc] initWithFrame: rect] autorelease];
	[self addSubview: mTransView];
	
	navBar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)] autorelease];
	//[navBar showButtonsWithLeftTitle: @"Back" rightTitle:@"Next >>" leftBack: TRUE];
	[navBar showButtonsWithLeftTitle: @"Back" rightTitle:nil leftBack: TRUE];
    [navBar setBarStyle: 3];
	[navBar enableAnimation];
	[navBar setDelegate: self];
	
	botNavBar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, rect.size.height - 44.0f, 320.0f, 44.0f)] autorelease];
    [botNavBar setBarStyle: 3];
	[botNavBar setDelegate: self];

	UIPushButton *pushButton = [[[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO] autorelease];
	[pushButton setFrame: CGRectMake(268.0, 0.0, 50.0, 44.0)];
	[pushButton setDrawsShadow: NO];
	[pushButton setEnabled:YES];
	[pushButton setStretchBackground:NO];
	[pushButton setBackground:[UIImage applicationImageNamed:@"internet.png"] forState:0];  //up state
	[pushButton addTarget: self action: @selector(visitLink) forEvents: (1<<6)];
	[navBar addSubview: pushButton];

	pushButton = [[[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO] autorelease];
	[pushButton setFrame: CGRectMake(0.0, 0.0, 50.0, 44.0)];
	[pushButton setDrawsShadow: YES];
	[pushButton setEnabled:YES];
	[pushButton setStretchBackground:NO];
	[pushButton setBackground:[UIImage applicationImageNamed:@"delete.png"] forState:0];  //up state
	[pushButton addTarget: self action: @selector(deleteItemQ) forEvents: (1<<6)];
	[botNavBar addSubview: pushButton];

	direcBtns = [[[UISegmentedControl alloc] initWithFrame:CGRectMake(220.0f, 8.0f, 88.0f, 30.0f) withStyle:2 withItems:NULL] autorelease];
	[direcBtns insertSegment:0 withImage:[UIImage applicationImageNamed:@"arrowup.png"] animated:FALSE];
	[direcBtns insertSegment:1 withImage:[UIImage applicationImageNamed:@"arrowdown.png"] animated:FALSE];
	[direcBtns setDelegate:self];
	[botNavBar addSubview:direcBtns];

	[self addSubview: botNavBar];
	
	scroller = [[[UIScroller alloc] initWithFrame: CGRectMake(0.0f, 22.0f, 320.0f, rect.size.height - 66.0f)] autorelease];
	[scroller setScrollingEnabled: YES];
	[scroller setAdjustForContentSizeChange: YES];
	[scroller setClipsSubviews: YES];
	[scroller setAllowsRubberBanding: YES];
	[scroller setDelegate: self];

	[self addSubview: scroller];
	
	web = [[[UIWebView alloc] initWithFrame: CGRectMake(0.0f, 22.0f, 320.0f, rect.size.height - 66.0f)] autorelease];
	[web setTilingEnabled: YES];
	[web setTileSize: CGSizeMake(320.f,1000)];
	[web setDelegate: self];
	[web setAutoresizes: YES];
	[web setEnabledGestures: 2];

	mCoreWebView = [web webView];
	[mCoreWebView setFrameLoadDelegate: self];
	mFrame = [mCoreWebView mainFrame];

	[mCoreWebView setPolicyDelegate: self];
	[mCoreWebView setUIDelegate: self];

	UITextLabel *_title = [[[UITextLabel alloc] initWithFrame: CGRectMake(65.0f, 10.0f, 220.0f, 25.0f)] autorelease];
	[_title setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:20]];
	[_title setCentersHorizontally: YES];
	[_title setBackgroundColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:0.0f]];
	[_title setColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:1.0f]];
	[_title setWrapsText: NO];

	/*textView = [[UITextView alloc] initWithFrame: CGRectMake(0.0f, 44.0f, 320.0f, rect.size.height - 88.0f)];
    [textView setEditable:NO];
    [textView setTextSize:15];*/

	NSProcessInfo *procInfo = [[NSProcessInfo alloc] init];
	firmwareVersion = [[procInfo operatingSystemVersionString] retain];

	BOOL isDir = YES;

	if ([firmwareVersion isEqualToString: @"Version 1.1.3 (Build 4A93)"])
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath: @"/var/mobile/Library/Preferences" isDirectory: &isDir])
		{
			libLocation = @"/var/mobile/Library/Preferences/";
		}
		else
		{
			libLocation = @"/var/root/Library/Preferences/";
		}
	}
	else
	{
		libLocation = @"/var/root/Library/Preferences/";
	}

	NSString *DBFile = [libLocation stringByAppendingString: @"MobileRSS/rss.db"];

	db = [FMDatabase databaseWithPath: DBFile];

	[db setLogsErrors: YES];
	[db setCrashOnErrors: YES];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	FMResultSet *rs = [db executeQuery:@"select feedItems.*, feeds.feed from feedItems inner join feeds on feedItems.feedsID=feeds.feedsID where feedItems.feedsID=? order by feedItems.itemDateConv desc, feedItems.feedItemsID asc limit ?,1", [NSString stringWithFormat:@"%d", feedsID], [NSString stringWithFormat:@"%d", row], nil];

	if (![rs next])
	{	
		[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(hideItemView:) userInfo:nil repeats:NO];

		return self;
	}
	
	[self addSubview: navBar];
	[self addSubview: _title];

	_feedItemsID = [rs intForColumn: @"feedItemsID"];

	NSString *_itemDateConv = [rs stringForColumn: @"itemDateConv"];

	[_title setText: [rs stringForColumn: @"feed"]];

	_visitLink = [[rs stringForColumn: @"itemLink"] retain];

	NSMutableString *fullText = [[[NSMutableString alloc] initWithString: @"<div style='width: 315px;'>"] autorelease];
	
	[fullText appendString:@"<b>"];

	if ([rs stringForColumn: @"itemTitle"] != nil)
	{
		[fullText appendString:[rs stringForColumn: @"itemTitle"]];
	}

	[fullText appendString:@"</b>"];
	
	if ([rs stringForColumn: @"itemDate"] != nil)
	{
		[fullText appendString:@"<br/>"];
		[fullText appendString:@"<small>"];
		[fullText appendString:@"<i>"];
		[fullText appendString:[rs stringForColumn: @"itemDate"]];
		[fullText appendString:@"</i>"];
		[fullText appendString:@"</small>"];
	}

	[fullText appendString:@"<br/><br/>"];
	
	if ([rs stringForColumn: @"itemDescrip"] != nil)
	{
		[fullText appendString:[rs stringForColumn: @"itemDescrip"]];
	}
	else
	{
		[fullText appendString:@"<i>The feed did not supply the text of this item. To view this item please click the Visit Link button above.</i>"];
	}
	
	[fullText appendString:@"</div>"];

	//[textView setHTML: fullText];
	[web loadHTMLString: fullText baseURL:nil];
	
	[rs close];

	//[db executeUpdate:@"update feedItems set hasViewed=1 where itemLink=? and feedsID=? and itemDateConv=?", _visitLink, [NSString stringWithFormat:@"%d", feedsID], _itemDateConv, nil];
	[db executeUpdate:@"update feedItems set hasViewed=1 where itemLink=? and feedsID=?", _visitLink, [NSString stringWithFormat:@"%d", feedsID], nil];

	//[self addSubview: textView];
	[scroller addSubview: web];
	
	[db close];
	
	// Setup Eye Candy View
	_eyeCandy = [[[EyeCandy alloc] init] retain];

	//[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(addTextView:) userInfo:nil repeats:NO];

	return self;
}

- (void) view: (id)v didDrawInRect: (CGRect)f duration: (float)d
{
	if (v == web)
	{
		[scroller setContentSize: CGSizeMake([web bounds].size.width,[web bounds].size.height+10.0f)];
	}
}

- (void) view: (UIView*)v didSetFrame: (CGRect)f
{
	if (v == web)
	{
		[scroller setContentSize: CGSizeMake(f.size.width,f.size.height+10.0f)];
	}
}

- (void)drawRect:(CGRect)rect
{
  // erase the background by drawing white
  float grey[4] = {0.2, 0.2, 0.2, 1.0};
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextSetFillColorWithColor(UICurrentContext(), CGColorCreate(colorSpace, grey));
  CGContextFillRect(UICurrentContext(), rect);
}

// Receive a progress update message from the browser
- (void) _progressChanged: (NSNotification*)n
{
	if (![[n object] isLoading])
	{
		[nc removeObserver: self];

		[mTransView transition: 6 toView: scroller];

		[mProgress dismissAnimated:YES];
	}
}

// Dismiss Javascript alerts and telephone confirms
/*- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if (button == 1)
	{
		[sheet setContext: nil];
	}

	[sheet dismiss];
}*/

// Javascript errors and logs
- (void) webView: (WebView*)webView addMessageToConsole: (NSDictionary*)dictionary
{
	NSLog(@"Javascript log: %@", dictionary);
}

// Javascript alerts
- (void) webView: (WebView*)webView runJavaScriptAlertPanelWithMessage: (NSString*) message initiatedByFrame: (WebFrame*) frame
{
	NSLog(@"Javascript Alert: %@", message);

	UIAlertSheet *alertSheet = [[UIAlertSheet alloc] init];
	[alertSheet setTitle: @"Javascript Alert"];
	[alertSheet addButtonWithTitle: @"OK"];
	[alertSheet setBodyText:message];
	[alertSheet setDelegate: self];
	[alertSheet setContext: self];
	[alertSheet popupAlertAnimated:YES];
}

- (void) segmentedControl:(UISegmentedControl *)segment selectedSegmentChanged:(int)seg
{
	switch(seg)
	{
		case 0:
			[self prevItem];
		break;

		case 1:
			[self nextItem];
		break;
	}
}

- (void) deleteItemQ
{
	// Alert sheet attached to bootom of Screen.
	UIAlertSheet *alertSheet = [[[UIAlertSheet alloc] initWithFrame:CGRectMake(0, 240, 320, 240)] autorelease];
	[alertSheet addButtonWithTitle:@"Delete Feed Item"];
	[alertSheet addButtonWithTitle:@"Cancel"];
	[alertSheet setDelegate:self];

	NSArray *btnArry = [alertSheet buttons];
	
	[alertSheet setDefaultButton: [btnArry objectAtIndex: 1]];

	[alertSheet setAlertSheetStyle: 1];
	[alertSheet presentSheetFromAboveView:botNavBar];
}

- (void) deleteItem
{
	NSProcessInfo *procInfo = [[[NSProcessInfo alloc] init] autorelease];
	firmwareVersion = [[procInfo operatingSystemVersionString] retain];
	
	BOOL isDir = YES;

	if ([firmwareVersion isEqualToString: @"Version 1.1.3 (Build 4A93)"])
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath: @"/var/mobile/Library/Preferences" isDirectory: &isDir])
		{
			libLocation = @"/var/mobile/Library/Preferences/";
		}
		else
		{
			libLocation = @"/var/root/Library/Preferences/";
		}
	}
	else
	{
		libLocation = @"/var/root/Library/Preferences/";
	}
	
	NSString *DBFile = [libLocation stringByAppendingString: @"MobileRSS/rss.db"];

	db = [FMDatabase databaseWithPath: DBFile];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	FMResultSet *rs = [db executeQuery:@"select feedsID, itemTitle from feedItems where feedItemsID=?", [NSString stringWithFormat:@"%d", _feedItemsID], nil];

	if ([rs next])
	{
		int feedsID = [rs intForColumn: @"feedsID"];
		NSString *itemTitle = [rs stringForColumn: @"itemTitle"];

		[rs close];

		[db executeUpdate:@"insert into deletedItems (feedsID, itemTitle) values(?, ?)", [NSString stringWithFormat:@"%d", feedsID], itemTitle, nil];
		[db executeUpdate:@"delete from feedItems where feedsID=? and itemTitle=?", [NSString stringWithFormat:@"%d", feedsID], itemTitle, nil];
	}
	else
	{
		[rs close];
	}

	[db close];

	[self nextItem];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if (button == 1)
	{
		[self deleteItem];
	}

	[sheet dismiss];
}

- (void) hideItemView:(id)param
{
	[_delegate hideItemView];
}

- (void) finishLoad:(id)param
{
	[_eyeCandy showProgressHUD:@"Loading..." withWindow:[_delegate getWindow] withView:self withRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(addTextView:) userInfo:nil repeats:NO];
}

- (void) addTextView:(id)param
{
	[textView removeFromSuperview];
	[self addSubview: textView];
	
	//[_eyeCandy hideProgressHUD];
}

- (void) visitLink
{
	[_delegate openURL: [NSURL URLWithString:[_visitLink retain]]];
}

- (void) prevItem
{
	if (_row == 0)
	{
		[self hideItemView:nil];
	}
	else
	{
		int rowMinusOne = _row - 1;

		[self setRow: rowMinusOne];
		[_delegate showItem:rowMinusOne fromView:@"itemView" feed:_feedsID];
	}
}

- (void) nextItem
{
	int rowPlusOne = _row + 1;

	[self setRow: rowPlusOne];
	[_delegate showItem:rowPlusOne fromView:@"itemView" feed:_feedsID];
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{	
	[_delegate hideItemView];
}

- (void) setRow: (int)row
{
	_row = row;
}

- (void) setFeedsID: (int)feedsID
{
	_feedsID = feedsID;
}

- (void)setDelegate: (id)delegate
{
    _delegate = delegate;
}

- (void) dealloc
{
	//[navBar release];
	//[textView release];
	[super dealloc];
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
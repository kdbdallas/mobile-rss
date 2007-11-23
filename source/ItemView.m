#import "ItemView.h"

@implementation ItemView

- (id) initWithFrame: (struct CGRect)rect withRow:(int)row withFeed:(int)feedsID
{
	//Init view with frame rect
	[super initWithFrame: rect];

	[self setRow: row];
	[self setFeedsID: feedsID];
	
	navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	//[navBar showButtonsWithLeftTitle: @"Back" rightTitle:@"Next >>" leftBack: TRUE];
	[navBar showButtonsWithLeftTitle: @"Back" rightTitle:nil leftBack: TRUE];
    [navBar setBarStyle: 3];
	[navBar enableAnimation];
	[navBar setDelegate: self];
	
	botNavBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, rect.size.height - 44.0f, 320.0f, 44.0f)];
    [botNavBar setBarStyle: 3];
	[botNavBar setDelegate: self];

	UIImage *btnImage = [UIImage applicationImageNamed:@"internet.png"];
	UIPushButton *pushButton = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
	[pushButton setFrame: CGRectMake(268.0, 0.0, 50.0, 44.0)];
	[pushButton setDrawsShadow: NO];
	[pushButton setEnabled:YES];
	[pushButton setStretchBackground:NO];
	[pushButton setBackground:btnImage forState:0];  //up state
	[pushButton addTarget: self action: @selector(visitLink) forEvents: (1<<6)];
	[navBar addSubview: pushButton];

	btnImage = [UIImage applicationImageNamed:@"delete.png"];
	pushButton = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
	[pushButton setFrame: CGRectMake(0.0, 0.0, 50.0, 44.0)];
	[pushButton setDrawsShadow: YES];
	[pushButton setEnabled:YES];
	[pushButton setStretchBackground:NO];
	[pushButton setBackground:btnImage forState:0];  //up state
	[pushButton addTarget: self action: @selector(deleteItemQ) forEvents: (1<<6)];
	[botNavBar addSubview: pushButton];

	direcBtns = [[UISegmentedControl alloc] initWithFrame:CGRectMake(220.0f, 8.0f, 88.0f, 30.0f) withStyle:2 withItems:NULL];
	UIImage *btnUpImage = [UIImage applicationImageNamed:@"arrowup.png"];
	UIImage *btnDownImage = [UIImage applicationImageNamed:@"arrowdown.png"];
	[direcBtns insertSegment:0 withImage:btnUpImage animated:FALSE];
	[direcBtns insertSegment:1 withImage:btnDownImage animated:FALSE];
	[direcBtns setDelegate:self];
	[botNavBar addSubview:direcBtns];

	[self addSubview: botNavBar];

	UITextLabel *_title = [[UITextLabel alloc] initWithFrame: CGRectMake(65.0f, 10.0f, 220.0f, 25.0f)];
	[_title setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:20]];
	[_title setCentersHorizontally: YES];
	[_title setBackgroundColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:0.0f]];
	[_title setColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:1.0f]];
	[_title setWrapsText: NO];

	textView = [[UITextView alloc] initWithFrame: CGRectMake(0.0f, 44.0f, 320.0f, rect.size.height - 88.0f)];
    [textView setEditable:NO];
    [textView setTextSize:15];

	NSString *DBFile = @"/var/root/Library/Preferences/MobileRSS/rss.db";

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

	NSMutableString *fullText = [[NSMutableString alloc] initWithString: @"<b>"];

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

	[textView setHTML: fullText];
	
	[rs close];

	//[db executeUpdate:@"update feedItems set hasViewed=1 where itemLink=? and feedsID=? and itemDateConv=?", _visitLink, [NSString stringWithFormat:@"%d", feedsID], _itemDateConv, nil];
	[db executeUpdate:@"update feedItems set hasViewed=1 where itemLink=? and feedsID=?", _visitLink, [NSString stringWithFormat:@"%d", feedsID], nil];

	[self addSubview: textView];
	
	[db close];
	
	// Setup Eye Candy View
	_eyeCandy = [[[EyeCandy alloc] init] retain];

	//[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(addTextView:) userInfo:nil repeats:NO];

	return self;
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
	UIAlertSheet *alertSheet = [[UIAlertSheet alloc] initWithFrame:CGRectMake(0, 240, 320, 240)];
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
	NSString *DBFile = @"/var/root/Library/Preferences/MobileRSS/rss.db";

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
	[navBar release];
	[textView release];
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
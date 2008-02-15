#import "FeedView.h"

@implementation FeedView

- (id) initWithFrame: (struct CGRect)rect withFeed:(int)feedID withTitle:(NSString*)title
{
	[super initWithFrame: rect];

	_feedsID = feedID;
	__title = [title retain];

	_font = [[_delegate fontForInt: 10] retain];

	_settingsView = [[[Settings alloc] initWithFrame:rect withSettingsPath: [_delegate getSettingsPath]] retain];
	//_settingsView = [[[Settings alloc] initWithFrame:rect withSettingsPath: [_delegate getSettingsPath]] autorelease];
	[_settingsView setDelegate: self];

	navBar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)] autorelease];
	[navBar showButtonsWithLeftTitle: @"Back" rightTitle:nil leftBack: TRUE];
    [navBar setBarStyle: 3];
	[navBar setDelegate: self];
	[self addSubview: navBar];

	UIPushButton *pushButton = [[[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO] autorelease];
	[pushButton setFrame: CGRectMake(268.0, 0.0, 50.0, 44.0)];
	[pushButton setDrawsShadow: NO];
	[pushButton setEnabled:YES];
	[pushButton setStretchBackground:NO];
	[pushButton setBackground:[UIImage applicationImageNamed:@"getnew.png"] forState:0];
	[pushButton addTarget: self action: @selector(startRefresh) forEvents: (1<<6)];
	[navBar addSubview: pushButton];

	botNavBar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, rect.size.height - 44.0f, 320.0f, 44.0f)] autorelease];
    [botNavBar setBarStyle: 3];
	[botNavBar setDelegate: self];

	pushButton = [[[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO] autorelease];
	[pushButton setFrame: CGRectMake(0.0, 0.0, 50.0, 44.0)];
	[pushButton setDrawsShadow: YES];
	[pushButton setEnabled:YES];
	[pushButton setStretchBackground:NO];
	[pushButton setBackground:[UIImage applicationImageNamed:@"delete.png"] forState:0];
	[pushButton addTarget: self action: @selector(clearAllQ) forEvents: (1<<6)];
	[botNavBar addSubview: pushButton];

	pushButton = [[[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO] autorelease];
	[pushButton setFrame: CGRectMake(268.0, 0.0, 50.0, 44.0)];
	[pushButton setDrawsShadow: YES];
	[pushButton setEnabled:YES];
	[pushButton setStretchBackground:NO];
	[pushButton setBackground:[UIImage applicationImageNamed:@"mark_all_read.png"] forState:0];
	[pushButton addTarget: self action: @selector(markAll) forEvents: (1<<6)];
	[botNavBar addSubview: pushButton];

	[self addSubview: botNavBar];

	UITextLabel *_title = [[[UITextLabel alloc] initWithFrame: CGRectMake(65.0f, 10.0f, 220.0f, 25.0f)] autorelease];
	[_title setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:20]];
	[_title setText: title];
	[_title setCentersHorizontally: YES];
	[_title setBackgroundColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:0.0f]];
	[_title setColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:1.0f]];
	[_title setWrapsText: NO];

	[self addSubview: _title];

	_viewTable = [[[UITable alloc] initWithFrame: CGRectMake(0.0f, 44.0f, 320.0f, rect.size.height - 88.0f)] autorelease];
	[_viewTable setSeparatorStyle: 1];
	[_viewTable setDelegate: self];
	[_viewTable setDataSource: self];
	[_viewTable setRowHeight: 32.0f];

	_viewTableCol = [[[UITableColumn alloc] initWithTitle: @"Feed Items" identifier:@"items" width: rect.size.width] autorelease];

	[_viewTable addTableColumn: _viewTableCol];

	[self addSubview:_viewTable];

	_eyeCandy = [[[EyeCandy alloc] init] retain];

	[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(finishLoad:) userInfo:nil repeats:NO];

	return self;
}

- (void) finishLoad:(id)param
{
	[_eyeCandy showProgressHUD:@"Loading..." withWindow:[_delegate getWindow] withView:self withRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];
	[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(processPlistWithPath:) userInfo:nil repeats:NO];
}

- (void) processPlistWithPath:(id)param
{
	NSDictionary *FeedsDict = [_settingsView loadSettings: [_delegate getSettingsPath]];
	NSEnumerator *enumerator = [FeedsDict keyEnumerator];
	NSString *currKey;
	NSDictionary *feedDict;

	while (currKey = [enumerator nextObject])
	{
		if ([currKey isEqualToString: @"Font"])
		{
			_font = [[_delegate fontForInt: [[FeedsDict valueForKey: currKey] intValue]] retain];
		}
		else if ([currKey isEqualToString: @"FontSize"])
		{
			_fontSize = [[FeedsDict valueForKey: currKey] intValue];
			
			float rowSize = _fontSize + 4.0;
			
			[_viewTable setRowHeight: rowSize];
		}
		else if ([currKey isEqualToString: @"KeepFeedsFor"])
		{
			//
		}
		else if ([currKey isEqualToString: @"RefreshEvery"])
		{
			
		}
	}

	[_viewTable selectRow: -1 byExtendingSelection: NO];
	[_viewTable clearAllData];
	[_viewTable reloadData];

	[_eyeCandy hideProgressHUD];
}

- (void) startRefresh
{
	_spinner = [[[UIProgressIndicator alloc] initWithFrame: CGRectMake(80.0f, 13.0f, 20.0f, 20.0f)] autorelease];
	[_spinner setAnimationDuration:1];
	[_spinner startAnimation];
	[botNavBar addSubview: _spinner];
	
	_spinnerLabel = [[[UITextLabel alloc] initWithFrame: CGRectMake(110.0f, 13.0f, 150.0f, 20.0f)] autorelease];
	[_spinnerLabel setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:12]];
	[_spinnerLabel setText: @"Refreshing Feed"];
	[_spinnerLabel setBackgroundColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:0.0f]];
	[_spinnerLabel setColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:1.0f]];
	[_spinnerLabel setWrapsText: NO];
	[botNavBar addSubview: _spinnerLabel];

	ThreadProcesses *_tproc = [[[ThreadProcesses alloc] init] autorelease];
	[_tproc setDelegate: self];

	[NSThread detachNewThreadSelector:@selector(refreshSingleFeed:) toTarget:_tproc withObject:nil];
}

- (int) getFeedsID
{
	return _feedsID;
}

- (void) reloadTableData
{
	[_viewTable selectRow: -1 byExtendingSelection: NO];
	[_viewTable clearAllData];
	[_viewTable reloadData];
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	[self reloadTableData];

	[_delegate hideFeed];
}

- (void) clearAllQ
{
	// Alert sheet attached to bootom of Screen.
	UIAlertSheet *alertSheet = [[UIAlertSheet alloc] initWithFrame:CGRectMake(0, 240, 320, 240)];
	[alertSheet addButtonWithTitle:@"Delete Feed Items"];
	[alertSheet addButtonWithTitle:@"Delete Read Feed Items"];
	[alertSheet addButtonWithTitle:@"Cancel"];
	[alertSheet setDelegate:self];
	
	NSArray *btnArry = [alertSheet buttons];
	
	[alertSheet setDefaultButton: [btnArry objectAtIndex: 2]];

	[alertSheet setAlertSheetStyle: 1];
	[alertSheet presentSheetFromAboveView:botNavBar];
}

- (void) clearRead
{
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
	
	NSString *DBFile = [libLocation stringByAppendingString: @"/MobileRSS/rss.db"];

	db = [FMDatabase databaseWithPath: DBFile];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	NSMutableArray *feedsIDs = [NSMutableArray arrayWithCapacity:1];
	NSMutableArray *itemTitles = [NSMutableArray arrayWithCapacity:1];

	FMResultSet *rs = [db executeQuery:@"select feedsID, itemTitle from feedItems where feedsID=? and hasViewed=1", [NSString stringWithFormat:@"%d", _feedsID], nil];

	while ([rs next])
	{
		[feedsIDs addObject: [NSString stringWithFormat:@"%d", [rs intForColumn: @"feedsID"]]];
		[itemTitles addObject: [rs stringForColumn: @"itemTitle"]];
	}

	[rs close];

	int index;

	for (index = 0; index < [feedsIDs count]; index++)
	{
		[db executeUpdate:@"insert into deletedItems (feedsID, itemTitle) values(?, ?)", [feedsIDs objectAtIndex: index], [itemTitles objectAtIndex: index], nil];
		[db executeUpdate:@"delete from feedItems where feedsID=? and itemTitle=?", [feedsIDs objectAtIndex: index], [itemTitles objectAtIndex: index], nil];
	}

	[db close];

	[_viewTable selectRow: -1 byExtendingSelection: NO];
	[_viewTable clearAllData];
	[_viewTable reloadData];
}

- (void) clearAll
{
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
	
	NSMutableArray *feedsIDs = [NSMutableArray arrayWithCapacity:1];
	NSMutableArray *itemTitles = [NSMutableArray arrayWithCapacity:1];

	FMResultSet *rs = [db executeQuery:@"select feedsID, itemTitle from feedItems where feedsID=?", [NSString stringWithFormat:@"%d", _feedsID], nil];

	while ([rs next])
	{
		[feedsIDs addObject: [NSString stringWithFormat:@"%d", [rs intForColumn: @"feedsID"]]];
		[itemTitles addObject: [rs stringForColumn: @"itemTitle"]];
	}

	[rs close];

	int index;

	for (index = 0; index < [feedsIDs count]; index++)
	{
		[db executeUpdate:@"insert into deletedItems (feedsID, itemTitle) values(?, ?)", [feedsIDs objectAtIndex: index], [itemTitles objectAtIndex: index], nil];
		[db executeUpdate:@"delete from feedItems where feedsID=? and itemTitle=?", [feedsIDs objectAtIndex: index], [itemTitles objectAtIndex: index], nil];
	}

	[db close];

	[_viewTable selectRow: -1 byExtendingSelection: NO];
	[_viewTable clearAllData];
	[_viewTable reloadData];
}

- (void) markAll
{
	// Alert sheet attached to bootom of Screen.
	alertSheetMarkAll = [[UIAlertSheet alloc] initWithFrame:CGRectMake(0, 240, 320, 240)];
	[alertSheetMarkAll addButtonWithTitle:@"Mark all as read"];
	[alertSheetMarkAll addButtonWithTitle:@"Mark all as unread"];
	[alertSheetMarkAll addButtonWithTitle:@"Cancel"];
	[alertSheetMarkAll setDelegate:self];
	
	NSArray *btnArry = [alertSheetMarkAll buttons];
	
	[alertSheetMarkAll setDefaultButton: [btnArry objectAtIndex: 2]];

	[alertSheetMarkAll setAlertSheetStyle: 1];
	[alertSheetMarkAll presentSheetFromAboveView:botNavBar];
}

- (void) markAllRead
{
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
	
	NSString *DBFile = [libLocation stringByAppendingString: @"/MobileRSS/rss.db"];

	db = [FMDatabase databaseWithPath: DBFile];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	[db executeUpdate:@"update feedItems set hasViewed=? where feedsID=?", @"1", [NSString stringWithFormat:@"%d", _feedsID], nil];

	[_viewTable selectRow: -1 byExtendingSelection: NO];
	[_viewTable clearAllData];
	[_viewTable reloadData];
}

- (void) markAllUnread
{
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

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	[db executeUpdate:@"update feedItems set hasViewed=? where feedsID=?", @"0", [NSString stringWithFormat:@"%d", _feedsID], nil];

	[_viewTable selectRow: -1 byExtendingSelection: NO];
	[_viewTable clearAllData];
	[_viewTable reloadData];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if (sheet == alertSheetMarkAll)
	{
		switch (button)
		{
			case 1:
				[self markAllRead];
			break;

			case 2:
				[self markAllUnread];
			break;
		}
	}
	else
	{
		switch(button)
		{
			case 1:
				[self clearAll];
			break;

			case 2:
				[self clearRead];
			break;
		}
	}

	[sheet dismiss];
	[sheet release];
}

- (void) clearSpinner
{
	struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;

	if ([[_delegate getWindow] contentView] == [_delegate getFeedView])
	{
		[[_delegate getFeedView] removeFromSuperview];

		//[_spinner release];
		[_eyeCandy release];
		//[_viewTableCol release];
		//[_viewTable release];
		//[botNavBar release];
		//[navBar release];
		//[_settingsView release];
		
		[self initWithFrame: rect withFeed: _feedsID withTitle:__title];

		[[_delegate getWindow] setContentView: [_delegate getFeedView]];
	}
}

- (void) setDelegate: (id)delegate
{
    _delegate = delegate;
}

- (id) delegate
{
	return _delegate;
}

- (void) dealloc
{
	[_eyeCandy release];
	//[_viewTableCol release];
	//[_viewTable release];
	//[botNavBar release];
	[_settingsView release];
	//[navBar release];
	[super dealloc];
}

// Start of UITable required methods
- (int)numberOfRowsInTable:(UITable *)table {
	_appLibraryPath = [[_delegate getSettingsDIR] stringByAppendingPathComponent: @"MobileRSS"];
	NSString *DBFile = [_appLibraryPath stringByAppendingPathComponent: @"rss.db"];

	db = [FMDatabase databaseWithPath: DBFile];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	FMResultSet *rs = [db executeQuery:@"select count(feedItemsID) as count from feedItems where feedsID=?", [NSString stringWithFormat:@"%d", _feedsID], nil];

	[rs next];

	int countVal = [[rs stringForColumn: @"count"] intValue];

	[rs close];

	return countVal;
}

- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col {
	struct CGRect rect;

	UIImageAndTextTableCell *cell = [[[UIImageAndTextTableCell alloc] init] autorelease];

	_appLibraryPath = [[_delegate getSettingsDIR] stringByAppendingPathComponent: @"MobileRSS"];
	NSString *DBFile = [_appLibraryPath stringByAppendingPathComponent: @"rss.db"];

	db = [FMDatabase databaseWithPath: DBFile];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	FMResultSet *rs = [db executeQuery:@"select * from feedItems where feedsID=? order by itemDateConv desc, itemDate desc, feedItemsID asc limit ?,1", [NSString stringWithFormat:@"%d", _feedsID], [NSString stringWithFormat:@"%d", row], nil];

	[rs next];

	[cell setShowDisclosure: YES];
	[cell setDisclosureClickable: YES];

	if ([rs intForColumn: @"hasViewed"] == 0)
	{
		[cell setImage: [UIImage applicationImageNamed: @"bullet.png"]];

		rect = CGRectMake(30.0f, 0.0f, 265.0f, (_fontSize + 4));
	}
	else
	{
		rect = CGRectMake(5.0f, 0.0f, 285.0f, (_fontSize + 4));
	}

	[cell setShowDisclosure: YES];
	[cell setDisclosureClickable: YES];

	UITextLabel *_feedLabel = [[[UITextLabel alloc] initWithFrame: rect] autorelease];
	[_feedLabel setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:[_font retain] traits:2 size:_fontSize]];
	[_feedLabel setText: [rs stringForColumn: @"itemTitle"]];
	[_feedLabel setBackgroundColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:0.0f]];
	[_feedLabel setWrapsText: NO];

	[cell addSubview: _feedLabel];

	[rs close];

	return cell;
}

- (BOOL)table:(UITable *)aTable canSelectRow:(int)row {
	[_delegate showItem: row fromView: @"mainView" feed: _feedsID];

	return YES;
}
// End of UITable required methods

// Start of Debugging and/or iPhone Reverse Engineering Methods
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
// End of Debugging and/or iPhone Reverse Engineering Methods

@end
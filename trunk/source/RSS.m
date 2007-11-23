#import "RSS.h"

static NSRecursiveLock *lock;

@implementation MobileRSS

- (void) applicationDidFinishLaunching: (id) unused
{
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	[window orderFront: self];
	[window makeKey: self];
	[window _setHidden: NO];

	struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;

	struct CGRect contentRect = [UIHardware fullScreenApplicationContentRect];
	contentRect.origin.x = 0.0f;
	contentRect.origin.y = 0.0f;
	
	BOOL isDir;
	NSString *DBFile;

	//Check if 1.4.1 Prefs file exists
	if ([[NSFileManager defaultManager] fileExistsAtPath: @"/var/root/Library/Preferences/com.google.code.mobile-rss.plist" isDirectory: NO])
	{
		DBExists = NO;
		isDir = YES;
		
		DBFile = @"/var/root/Library/Preferences/MobileRSS/rss.db";

		if (![[NSFileManager defaultManager] fileExistsAtPath: @"/var/root/Library/Preferences/MobileRSS" isDirectory: &isDir])
		{
			// Ensure library directories exsist
			[[NSFileManager defaultManager] createDirectoryAtPath: @"/var/root/Library/Preferences/MobileRSS" attributes: nil];
		}

		isDir = NO;

		// Folder exists but what about the file?
		// If the DB already exists then we don't want to import, but because they already have feeds setup
		if (![[NSFileManager defaultManager] fileExistsAtPath: DBFile isDirectory: &isDir])
		{
			[[NSFileManager defaultManager] createFileAtPath: DBFile contents:nil attributes: nil];

			db = [FMDatabase databaseWithPath: DBFile];

			[db setLogsErrors: YES];

			if (![db open]) {
			    NSLog(@"Could not open DB at path: %@", DBFile);
				[_eyeCandy hideProgressHUD];
				[_eyeCandy showStandardAlertWithString: @"An Error Occurred" closeBtnTitle: @"Close" withError: @"Could not open DB"];
			}

			if (!DBExists)
			{
				// DB didn't exist so we need to set it up
				[db executeUpdate:@"create table feeds (feedsID INTEGER PRIMARY KEY, feed text, URL text, position integer)", nil];
				[db executeUpdate:@"create table feedItems (feedItemsID INTEGER PRIMARY KEY, feedsID integer, itemTitle text, itemDate text, itemDateConv text, itemLink text, itemDescrip text, hasViewed integer, dateAdded text)", nil];
				[db executeUpdate:@"create table deletedItems (deletedItemsID INTEGER PRIMARY KEY, feedsID integer, itemTitle text)", nil];
			}

			NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile: @"/var/root/Library/Preferences/com.google.code.mobile-rss.plist"];

			NSEnumerator *enumerator = [settingsDict keyEnumerator];
			NSString *currKey;
			int position = 0;
		
			while (currKey = [enumerator nextObject])
			{
				if ([currKey isEqualToString: @"Feeds"])
				{
					NSArray *feedArray = [settingsDict objectForKey: currKey];

					int index;

					for (index = 0; index < [feedArray count]; index++)
					{
						NSDictionary *feedsDict = [feedArray objectAtIndex: index];

						NSString *titleHolder = [feedsDict objectForKey: @"Title"];

						NSMutableString *urlHolder = [NSMutableString stringWithCapacity: 1];
						[urlHolder setString: [feedsDict objectForKey: @"URL"]];

						[urlHolder replaceOccurrencesOfString: @"feed://" withString: @"http://" options: NSCaseInsensitiveSearch range: NSMakeRange(0, [urlHolder length])];

						[db executeUpdate:@"insert into feeds (feed, URL, position) values (?, ?, ?)", titleHolder, urlHolder, [NSString stringWithFormat:@"%d", position], nil];
					
						position++;
					}
				}
			}

			[db close];

			NSLog(@"Imported 1.4.1 Feeds");
		}

		//Remove now non-needed 1.4.1 Pref file.
		[[NSFileManager defaultManager] removeFileAtPath: @"/var/root/Library/Preferences/com.google.code.mobile-rss.plist" handler: nil];
	}
	//End Check if 1.4.1 Prefs file exists
	
	//Check if LaunchDaemon entry exists
	if (![[NSFileManager defaultManager] fileExistsAtPath: @"/System/Library/LaunchDaemons/org.mobilestudio.mobilerss.plist" isDirectory: NO])
	{
		//HACK: It seems that Apple removed the NSFileManager copyPath:toPath:handler selector. Use system command.
		NSString *cpCommand = @"/bin/cp /Applications/RSS.app/LaunchDaemon.plist /System/Library/LaunchDaemons/org.mobilestudio.mobilerss.plist";
		system([cpCommand UTF8String]);

		cpCommand = @"/bin/cp /Applications/RSS.app/RSSDaemon /sbin/RSSDaemon";
		system([cpCommand UTF8String]);
	}

	//Check if Daemon is running
	pid_t FoundPID = [self FindPID];

	if (FoundPID == -1)
	{
		NSString *launchctlCmd = @"launchctl load /System/Library/LaunchDaemons/org.mobilestudio.mobilerss.plist";
		system([launchctlCmd UTF8String]);
	}

	_numFeeds = 0;
	totalUnread = 0;
	DBExists = NO;
	isDir = YES;
	_font = [[self fontForInt: 10] retain];

	_appLibraryPath = [[self getSettingsDIR] stringByAppendingPathComponent: @"MobileRSS"];
	DBFile = [_appLibraryPath stringByAppendingPathComponent: @"rss.db"];

	if (![[NSFileManager defaultManager] fileExistsAtPath: _appLibraryPath isDirectory: &isDir])
	{
		// Ensure library directories exsist
		[[NSFileManager defaultManager] createDirectoryAtPath: _appLibraryPath attributes: nil];
	}
	else
	{
		isDir = NO;

		// Folder exists but what about the file?
		if ([[NSFileManager defaultManager] fileExistsAtPath: DBFile isDirectory: &isDir])
		{
			DBExists = YES;
		}
		else
		{
			[[NSFileManager defaultManager] createFileAtPath: DBFile contents:nil attributes: nil];
		}
	}

	db = [FMDatabase databaseWithPath: DBFile];
	
	[db setLogsErrors: YES];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	if (!DBExists)
	{
		// DB didn't exist so we need to set it up
		[db executeUpdate:@"create table feeds (feedsID INTEGER PRIMARY KEY, feed text, URL text, position integer)", nil];
		[db executeUpdate:@"create table feedItems (feedItemsID INTEGER PRIMARY KEY, feedsID integer, itemTitle text, itemDate text, itemDateConv text, itemLink text, itemDescrip text, hasViewed integer, dateAdded text)", nil];
		[db executeUpdate:@"create table deletedItems (deletedItemsID INTEGER PRIMARY KEY, feedsID integer, itemTitle text)", nil];
	}
	else
	{
		//DB Exists but make sure they have the newest table
		[db executeUpdate:@"create table deletedItems (deletedItemsID INTEGER PRIMARY KEY, feedsID integer, itemTitle text)", nil];
	}

	mainView = [[UIView alloc] initWithFrame: rect];

	// Add main view to the main window
	[window setContentView: mainView]; 

	// Transition view
	transitionView = [[UITransitionView alloc] initWithFrame:rect];
	[transitionView setDelegate: self];
	[mainView addSubview:transitionView];

	// Setup Settings View
	_settingsView = [[[Settings alloc] initWithFrame:rect withSettingsPath: [self getSettingsPath]] retain];
	[_settingsView setDelegate: self];

	_feeds = [[Feeds alloc] init];

	// Main view Nav Bar
	navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	[navBar showButtonsWithLeftTitle: @"Settings" rightTitle:nil leftBack: FALSE];
    [navBar setBarStyle: 3];
	[navBar setDelegate: self];
	
	UIImage *btnImage = [UIImage applicationImageNamed:@"getnew.png"];
	UIPushButton *pushButton = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
	[pushButton setFrame: CGRectMake(268.0, 0.0, 50.0, 44.0)];
	[pushButton setDrawsShadow: NO];
	[pushButton setEnabled:YES];
	[pushButton setStretchBackground:NO];
	[pushButton setBackground:btnImage forState:0];  //up state
	[pushButton addTarget: self action: @selector(startAllRefresh) forEvents: (1<<6)];
	[navBar addSubview: pushButton];
	
	[pushButton release];

	// Add Nav Bar with Settings Btn to the main view
	[mainView addSubview: navBar];

	botNavBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, rect.size.height - 44.0f, 320.0f, 44.0f)];
    [botNavBar setBarStyle: 3];
	[botNavBar setDelegate: self];

	btnImage = [UIImage applicationImageNamed:@"delete.png"];
	pushButton = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
	[pushButton setFrame: CGRectMake(0.0, 0.0, 50.0, 44.0)];
	[pushButton setDrawsShadow: YES];
	[pushButton setEnabled:YES];
	[pushButton setStretchBackground:NO];
	[pushButton setBackground:btnImage forState:0];  //up state
	[pushButton addTarget: self action: @selector(clearAllQ) forEvents: (1<<6)];
	[botNavBar addSubview: pushButton];

	[pushButton release];

	btnImage = [UIImage applicationImageNamed:@"mark_all_read.png"];
	pushButton = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
	[pushButton setFrame: CGRectMake(268.0, 0.0, 50.0, 44.0)];
	[pushButton setDrawsShadow: YES];
	[pushButton setEnabled:YES];
	[pushButton setStretchBackground:NO];
	[pushButton setBackground:btnImage forState:0];  //up state
	[pushButton addTarget: self action: @selector(markAll) forEvents: (1<<6)];
	[botNavBar addSubview: pushButton];

	[pushButton release];

	[mainView addSubview: botNavBar];

	_title = [[UITextLabel alloc] initWithFrame: CGRectMake(110.0f, 12.0f, 150.0f, 20.0f)];
	[_title setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:20]];
	[_title setText: @"Mobile RSS"];
	[_title setBackgroundColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:0.0f]];
	[_title setColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:1.0f]];
	[_title setWrapsText: NO];

	[mainView addSubview: _title];
	
	[_title release];

	// Table to show feed items
	_viewTable = [[UITable alloc] initWithFrame: CGRectMake(0.0f, 44.0f, 320.0f, rect.size.height - 88.0f)];
	[_viewTable setSeparatorStyle: 1];
	[_viewTable setDelegate: self];
	[_viewTable setDataSource: self];
	[_viewTable setRowHeight: 32.0f];

	// Col for the table that shows feeds items
	_viewTableCol = [[UITableColumn alloc] initWithTitle: @"Feeds" identifier:@"feeds" width: rect.size.width];
	
	// Put the Col into the Table
	[_viewTable addTableColumn: _viewTableCol];

	// Add the table into the main view
	[mainView addSubview:_viewTable];

	// Set the main view as the current view
	[window setContentView: mainView];
	
	// Setup Eye Candy View
	_eyeCandy = [[[EyeCandy alloc] init] retain];
	[_eyeCandy showProgressHUD:@"Loading..." withWindow:window withView:mainView withRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];

	[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(processPlistWithPath:) userInfo:nil repeats:NO];
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	[self showSettings];
}

- (void) clearAllQ
{
	// Alert sheet attached to bootom of Screen.
	UIAlertSheet *alertSheet = [[UIAlertSheet alloc] initWithFrame:CGRectMake(0, 240, 320, 240)];
	[alertSheet addButtonWithTitle:@"Delete All Feed Items"];
	[alertSheet addButtonWithTitle:@"Delete All Read Items"];
	[alertSheet addButtonWithTitle:@"Cancel"];
	[alertSheet setDelegate:self];
	
	NSArray *btnArry = [alertSheet buttons];
	
	[alertSheet setDefaultButton: [btnArry objectAtIndex: 2]];

	[alertSheet setAlertSheetStyle: 1];
	[alertSheet presentSheetFromAboveView:botNavBar];
}

- (void) clearRead
{
	NSString *DBFile = @"/var/root/Library/Preferences/MobileRSS/rss.db";

	db = [FMDatabase databaseWithPath: DBFile];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	NSMutableArray *feedsIDs = [NSMutableArray arrayWithCapacity:1];
	NSMutableArray *itemTitles = [NSMutableArray arrayWithCapacity:1];

	FMResultSet *rs = [db executeQuery:@"select feedsID, itemTitle from feedItems where hasViewed=1", nil];

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
	NSString *DBFile = @"/var/root/Library/Preferences/MobileRSS/rss.db";

	db = [FMDatabase databaseWithPath: DBFile];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	NSMutableArray *feedsIDs = [NSMutableArray arrayWithCapacity:1];
	NSMutableArray *itemTitles = [NSMutableArray arrayWithCapacity:1];

	FMResultSet *rs = [db executeQuery:@"select feedsID, itemTitle from feedItems", nil];

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
	NSString *DBFile = @"/var/root/Library/Preferences/MobileRSS/rss.db";

	db = [FMDatabase databaseWithPath: DBFile];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	[db executeUpdate:@"update feedItems set hasViewed=?", @"1", nil];

	[db close];

	[_viewTable selectRow: -1 byExtendingSelection: NO];
	[_viewTable clearAllData];
	[_viewTable reloadData];
}

- (void) markAllUnread
{
	NSString *DBFile = @"/var/root/Library/Preferences/MobileRSS/rss.db";

	db = [FMDatabase databaseWithPath: DBFile];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	[db executeUpdate:@"update feedItems set hasViewed=?", @"0", nil];

	[db close];

	[_viewTable selectRow: -1 byExtendingSelection: NO];
	[_viewTable clearAllData];
	[_viewTable reloadData];
}

- (pid_t) FindPID
{
	uint32_t i;
    size_t length;
	int32_t err, count;
    struct kinfo_proc *process_buffer;
    struct kinfo_proc *kp;
    int mib[ 3 ] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL };
    pid_t FoundPID;
    int loop, argmax;

    FoundPID = -1;

	sysctl(mib, 3, NULL, &length, NULL, 0);

    if (length == 0)
        return -1;

	process_buffer = (struct kinfo_proc *)malloc(length);

    for (i = 0; i < 60; ++i)
	{
		// in the event of inordinate system load, transient sysctl() failures are possible. retry for up to one minute if necessary.
        if (!(err = sysctl(mib, 3, process_buffer, &length, NULL, 0))) break;
        sleep(1);
    }

    if (err)
	{
        free(process_buffer);
        return -1;
	}

	count = length / sizeof(struct kinfo_proc);

	kp = process_buffer;

#ifdef DEBUG
    NSLog("PID scan: found %d visible procs", count);
#endif

    for (loop = 0; (loop < count) && (FoundPID == -1); loop++) {
#ifdef DEBUG
        NSLog("PID: checking process %d (%s)", kp->kp_proc.p_pid, kp->kp_proc.p_comm);
#endif

		if (!strcasecmp(kp->kp_proc.p_comm,"RSSDaemon"))
		{
            FoundPID = kp->kp_proc.p_pid;
        }

		kp++;
    }

	free(process_buffer);

    return FoundPID;
}

- (void) processPlistWithPath:(id)param
{
	NSDictionary *FeedsDict = [_settingsView loadSettings: [self getSettingsPath]];
	NSEnumerator *enumerator = [FeedsDict keyEnumerator];
	NSString *currKey;
	NSDictionary *feedDict;

	while (currKey = [enumerator nextObject])
	{
		if ([currKey isEqualToString: @"Font"])
		{
			_font = [[self fontForInt: [[FeedsDict valueForKey: currKey] intValue]] retain];
		}
		else if ([currKey isEqualToString: @"FontSize"])
		{
			_fontSize = [[FeedsDict valueForKey: currKey] intValue];
		}
		else if ([currKey isEqualToString: @"KeepFeedsFor"])
		{
			//
		}
		else if ([currKey isEqualToString: @"RefreshEvery"])
		{
			
		}
	}

	float rowSize = _fontSize + 4.0;
	
	[_viewTable setRowHeight: rowSize];

	[_viewTable selectRow: -1 byExtendingSelection: NO];
	[_viewTable clearAllData];
	[_viewTable reloadData];
	[_eyeCandy hideProgressHUD];
}

- (void) startAllRefresh
{
	_spinner = [[UIProgressIndicator alloc] initWithFrame: CGRectMake(80.0f, 13.0f, 20.0f, 20.0f)];
	[_spinner setAnimationDuration:1];
	[_spinner startAnimation];
	[botNavBar addSubview: _spinner];
	
	_spinnerLabel = [[UITextLabel alloc] initWithFrame: CGRectMake(110.0f, 13.0f, 150.0f, 20.0f)];
	[_spinnerLabel setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:12]];
	[_spinnerLabel setText: @"Refreshing All Feeds"];
	[_spinnerLabel setBackgroundColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:0.0f]];
	[_spinnerLabel setColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:1.0f]];
	[_spinnerLabel setWrapsText: NO];
	[botNavBar addSubview: _spinnerLabel];
	
	[_spinnerLabel release];

	ThreadProcesses *_tproc = [[[ThreadProcesses alloc] init] autorelease];
	[_tproc setDelegate: self];

	[NSThread detachNewThreadSelector:@selector(refreshAllFeeds:) toTarget:_tproc withObject:nil];
}

- (void) clearSpinner
{
	if ([window contentView] == mainView)
	{
		[_spinner release];

		[mainView removeFromSuperview];

		[_viewTableCol release];
		[_viewTable release];
		[botNavBar release];
		[navBar release];
		[_feeds release];
		[_settingsView release];
		[transitionView release];
		[mainView release];
		[window release];

		[self applicationDidFinishLaunching:nil];
	}
}

- (void) reloadTable
{
	[_viewTable selectRow: -1 byExtendingSelection: NO];
	[_viewTable clearAllData];
	[_viewTable reloadData];
}

- (FMDatabase*) getDB
{
	return db;
}

- (UIWindow*) getWindow
{
	return window;
}

- (NSString*) getSettingsDIR
{
	return [[self userLibraryDirectory] stringByAppendingPathComponent: @"Preferences"];
}

- (NSString*) getSettingsPath
{
	return [[[[self getSettingsDIR] stringByAppendingPathComponent: @"MobileRSS"] stringByAppendingPathComponent: @"org.mobilestudio.mobilerss"] stringByAppendingPathExtension: @"plist"];
}

- (Settings*) getSettingsView
{
	return _settingsView;
}

- (void) showSettings
{
	[_viewTable selectRow: -1 byExtendingSelection: NO];

	[transitionView transition:6 fromView:mainView toView:_settingsView];

	[window setContentView: _settingsView];
	[_settingsView readSettings: [self getSettingsPath]];

	[_viewTable removeFromSuperview];
	[navBar removeFromSuperview];
}

- (void) hideSettingsView
{
	[_viewTable selectRow: -1 byExtendingSelection: NO];

	[_settingsView addSubview:transitionView];
	[transitionView transition:2 fromView:_settingsView toView:mainView];
	[window setContentView: mainView];
	
	[_settingsView removeFromSuperview];
	[_viewTableCol release];
	[_viewTable release];
	[botNavBar release];
	[navBar release];
	[_feeds release];
	[_settingsView release];
	[transitionView release];
	[mainView release];
	[window release];

	[self applicationDidFinishLaunching:nil];
}

- (void) hideItemView
{
	[_itemViewView addSubview:transitionView];
	[transitionView transition:2 fromView:_itemViewView toView:_feedView];
	[window setContentView: _feedView];

	[_feedView reloadTableData];
}

- (void) showItem:(int)row fromView:(NSString*)fView feed:(int)feedsID {
	[_viewTable selectRow: -1 byExtendingSelection: NO];
	[_viewTable clearAllData];
	[_viewTable reloadData];

	// Setup ItemView View
	struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;

	_itemViewView = [[ItemView alloc] initWithFrame:rect withRow: row withFeed: feedsID];
	[_itemViewView setDelegate: self];

	int transType;

	//Switch views
	//if ([fView isEqualToString:@"itemView"])
	//{
	//	transType = 7;
	//}
	//else
	//{
		transType = 1;
	//}

	[transitionView transition:transType fromView:mainView toView:_itemViewView];;
	[window setContentView: _itemViewView];
}

- (FeedView*) getFeedView
{
	return _feedView;
}

- (void) showFeed: (int)row
{
	_appLibraryPath = [[self getSettingsDIR] stringByAppendingPathComponent: @"MobileRSS"];
	NSString *DBFile = [_appLibraryPath stringByAppendingPathComponent: @"rss.db"];

	db = [FMDatabase databaseWithPath: DBFile];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	FMResultSet *rs = [db executeQuery:@"select feedsID, feed, URL, position from feeds order by position limit ?,1", [NSString stringWithFormat:@"%d", row], nil];

	[rs next];

	NSString *feedName = [rs stringForColumn: @"feed"];
	int feedID = [rs intForColumn: @"feedsID"];

	[rs close];

	struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;

	_feedView = [[FeedView alloc] initWithFrame:rect withFeed: feedID withTitle: feedName];

	[_feedView setDelegate: self];

	[transitionView transition:1 fromView:mainView toView:_feedView];

	[window setContentView: _feedView];
	
	[_viewTable selectRow: -1 byExtendingSelection: NO];
	[_viewTable clearAllData];
	[_viewTable reloadData];
}

- (void) hideFeed
{
	[_viewTable selectRow: -1 byExtendingSelection: NO];
	[_viewTable clearAllData];
	[_viewTable reloadData];

	[_feedView addSubview:transitionView];
	[transitionView transition:2 fromView:_feedView toView:mainView];
	[window setContentView: mainView];
	
	[_feedView removeFromSuperview];
	[_viewTableCol release];
	[_viewTable release];
	[botNavBar release];
	[navBar release];
	[_feeds release];
	[_settingsView release];
	[transitionView release];
	[mainView release];
	[window release];

	[self applicationDidFinishLaunching:nil];
}

- (void) updateAppBadge:(NSString*)value
{
	[lock lock];

	[UIApp setApplicationBadge:value];

	[lock unlock];
}

- (void) clearAppBadge
{
	[UIApp removeApplicationBadge];
}

- (NSString*) fontForInt: (int)index
{
	switch (index)
	{
		case 0: return @".Helvetica LT MM";
		case 1: return @".Times LT MM";
		case 2: return @"American Typewriter";
		case 3: return @"Arial";
		case 4: return @"Arial Rounded MT Bold";
		case 5: return @"Arial Unicode MS";
		case 6: return @"Courier";
		case 7: return @"Courier New";
		case 8: return @"DB LCD Temp";
		case 9: return @"Georgia";
		case 10: return @"Helvetica";
		case 11: return @"Lock Clock";
		case 12: return @"Marker Felt";
		case 13: return @"Phonepadtwo";
		case 14: return @"Times New Roman";
		case 15: return @"Trebuchet MS";
		case 16: return @"Verdana";
		case 17: return @"Zapfino";
	}
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

- (void)applicationWillTerminate
{
	NSString *DBFile = @"/var/root/Library/Preferences/MobileRSS/rss.db";

	db = [FMDatabase databaseWithPath: DBFile];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	FMResultSet *_rs = [db executeQuery:@"select count(itemTitle) as unread from feedItems where hasViewed=?", @"0", nil];

	[_rs next];

	if ([_rs intForColumn: @"unread"] > 0)
	{
		totalUnread = [_rs intForColumn: @"unread"];

		[self clearAppBadge];
		[self updateAppBadge: [NSString stringWithFormat:@"%d", totalUnread]];
	}
	else
	{
		[self clearAppBadge];
	}

	[_rs close];
	
	[db close];
	
	[db release];
	[_rs release];
}

- (void) dealloc
{
	// close the database
	[db close];
	[_eyeCandy release];
	[settingsPath release];
	[_content release];
	[_viewTableCol release];
	[_viewTable release];
	[botNavBar release];
	[navBar release];
	[_feeds release];
	[_settingsView release];
	[transitionView release];
	[mainView release];
	[window release];
	[super dealloc];
}

// Start of UITable required methods
- (int)numberOfRowsInTable:(UITable *)table {
	_appLibraryPath = [[self getSettingsDIR] stringByAppendingPathComponent: @"MobileRSS"];
	NSString *DBFile = [_appLibraryPath stringByAppendingPathComponent: @"rss.db"];

	db = [FMDatabase databaseWithPath: DBFile];

	[db setLogsErrors: YES];
	[db setCrashOnErrors: YES];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}
	
	FMResultSet *rs = [db executeQuery:@"select count(feedsID) as numFeeds from feeds", nil];

	[rs next];
	
	int numRows = [rs intForColumn: @"numFeeds"];

	[rs close];

	return numRows;
}

- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col {
	UIImageAndTextTableCell *cell = [[[UIImageAndTextTableCell alloc] init] autorelease];

	struct CGRect rect;

	_appLibraryPath = [[self getSettingsDIR] stringByAppendingPathComponent: @"MobileRSS"];
	NSString *DBFile = [_appLibraryPath stringByAppendingPathComponent: @"rss.db"];

	db = [FMDatabase databaseWithPath: DBFile];

	[db setLogsErrors: YES];
	[db setCrashOnErrors: YES];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	FMResultSet *rs = [db executeQuery:@"select feedsID, feed, URL, position from feeds order by position limit ?,1", [NSString stringWithFormat:@"%d", row], nil];

	[rs next];

	NSString *_feedName = [rs stringForColumn: @"feed"];
	NSString *feedID = [NSString stringWithFormat:@"%d", [rs intForColumn: @"feedsID"]];

	[rs close];

	FMResultSet *_rs = [db executeQuery:@"select count(itemTitle) as unread from feedItems where feedsID=? and hasViewed=?", feedID, @"0", nil];

	[_rs next];
	
	NSString *feedName = @"";

	if ([_rs intForColumn: @"unread"] > 0)
	{
		[cell setImage: [UIImage applicationImageNamed: @"bullet.png"]];

		totalUnread = totalUnread + [_rs intForColumn: @"unread"];
		rect = CGRectMake(30.0f, 0.0f, 265.0f, (_fontSize + 4));

		[self clearAppBadge];
		[self updateAppBadge: [NSString stringWithFormat:@"%d", totalUnread]];
		
		feedName = [feedName stringByAppendingString: @"("];
		feedName = [feedName stringByAppendingString: [NSString stringWithFormat:@"%d", [_rs intForColumn: @"unread"]]];
		feedName = [feedName stringByAppendingString: @") "];
	}
	else
	{
		rect = CGRectMake(5.0f, 0.0f, 285.0f, (_fontSize + 4));
	}
	
	feedName = [feedName stringByAppendingString: _feedName];
	
	[_rs close];

	[cell setShowDisclosure: YES];
	[cell setDisclosureClickable: YES];

	UITextLabel *_feedLabel = [[[UITextLabel alloc] initWithFrame: rect] autorelease];
	[_feedLabel setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:[_font retain] traits:2 size:_fontSize]];
	[_feedLabel setText: feedName];
	[_feedLabel setBackgroundColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:0.0f]];
	[_feedLabel setWrapsText: NO];

	[cell addSubview: _feedLabel];

	return cell;
}

- (BOOL)table:(UITable *)aTable canSelectRow:(int)row {
	[self showFeed: row];

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
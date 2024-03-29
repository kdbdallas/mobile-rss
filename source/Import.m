#import "Import.h"

@implementation Import

- (id) initWithFrame: (struct CGRect)rect
{
	//Init view with frame rect
	[super initWithFrame: rect];

	navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 40.0f)];
	[navBar showButtonsWithLeftTitle: @"Cancel" rightTitle:nil leftBack: YES];
    [navBar setBarStyle: 3];
	[navBar enableAnimation];
	[navBar setDelegate: self];

	[self addSubview: navBar];
	
	UITextLabel *_title = [[UITextLabel alloc] initWithFrame: CGRectMake(90.0f, 8.0f, 150.0f, 20.0f)];
	[_title setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:14]];
	[_title setText: @"Import an OPML File"];
	[_title setBackgroundColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:0.0f]];
	[_title setColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:1.0f]];
	[_title setWrapsText: NO];
	
	[self addSubview: _title];

	_Table = [[UIPreferencesTable alloc] initWithFrame: CGRectMake(0.0f, 40.0f, 320.0f, 125.0f)];
	[_Table setDataSource: self];
    [_Table setDelegate: self];

	_infoTitle = [[[UIPreferencesTableCell alloc] init] retain];
	[_infoTitle setTitle: @"Select a file to import from the list below"];

	BOOL isDir = YES;
	
	NSProcessInfo *procInfo = [[NSProcessInfo alloc] init];
	firmwareVersion = [[procInfo operatingSystemVersionString] retain];

	if ([firmwareVersion isEqualToString: @"Version 1.1.3 (Build 4A93)"])
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath: @"/var/mobile/Library/Preferences" isDirectory: &isDir])
		{
			uplocation = @"/var/mobile/";
		}
		else
		{
			uplocation = @"/var/root/";
		}
	}
	else
	{
		uplocation = @"/var/root/";
	}

	NSString *filepath = [@"Place OPML files in " stringByAppendingString: uplocation];

	_infoText = [[[UIPreferencesTableCell alloc] init] retain];
	[_infoText setTitle: filepath];

	CGRect switchRect = CGRectMake(rect.size.width - 114.0f, 9.0f, 96.0f, 32.0f);

	_overwriteCell = [[[UIPreferencesTableCell alloc] init] retain];
	[_overwriteCell setTitle: @"Overwrite Current"];
	_overwriteSwitch = [[UISwitchControl alloc] initWithFrame: switchRect];
	[_overwriteCell addSubview: _overwriteSwitch];
	
	[self addSubview: _Table];
	[_Table reloadData];
	
	importTable = [[UITable alloc] initWithFrame: CGRectMake(0.0f, 165.0f, 320.0f, rect.size.height - 165.0f)];
	[importTable setSeparatorStyle: 1];
	[importTable setDelegate: self];
	[importTable setDataSource: self];
	[importTable setRowHeight: 36.0f];

	_importTableCol = [[UITableColumn alloc] initWithTitle: @"Import" identifier:@"import" width: rect.size.width];

	[importTable addTableColumn: _importTableCol];

	[self addSubview: importTable];
	
	[importTable reloadData];

	files = [[[NSMutableArray alloc] initWithCapacity: 1] retain];
	
	// Setup Eye Candy View
	_eyeCandy = [[[EyeCandy alloc] init] retain];

	[self lookForFiles];

	return self;
}

- (void) lookForFiles
{
	BOOL isDir = YES;

	if ([firmwareVersion isEqualToString: @"Version 1.1.3 (Build 4A93)"])
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath: @"/var/mobile/" isDirectory: &isDir])
		{
			libLocation = @"/var/mobile/";
		}
		else
		{
			libLocation = @"/var/root/";
		}
	}
	else
	{
		libLocation = @"/var/root/";
	}
	
	int n, i;
	NSDictionary *fileAttributes;
	
	NSFm = [NSFileManager defaultManager];
	NSArray *dirArray = [NSFm directoryContentsAtPath: libLocation];

	n = [dirArray count];

	for (i = 0; i < n; ++i)
	{
		fileAttributes = [NSFm fileAttributesAtPath:[libLocation stringByAppendingString:[dirArray objectAtIndex: i]] traverseLink:YES];

		if (fileAttributes != nil)
		{
			if ([fileAttributes objectForKey:NSFileType] != NSFileTypeDirectory)
			{
				if ([[[dirArray objectAtIndex: i] pathExtension] isEqualToString: @"opml"] || [[[dirArray objectAtIndex: i] pathExtension] isEqualToString: @"rss"] || [[[dirArray objectAtIndex: i] pathExtension] isEqualToString: @"xml"])
				{
					[files addObject: [dirArray objectAtIndex: i]];
				}
		    }
		}
	}

	[importTable reloadData];
}

- (void) import:(id)param
{
	NSError *err = nil;
	NSXMLNode *statusNode = nil;
	NSEnumerator *childNodeEnum;
	NSXMLNode<importDelegateProto> *childNode = nil;
	NSXMLNode *_TitleNode;
	NSXMLNode *_URLNode;
	BOOL DBExists = NO;
	BOOL isDir = YES;
	FMResultSet *rs;
	FMDatabase *db;
	int index = 0;
	NSString *fileLocation;

	int row = [importTable selectedRow];
	
	if ([firmwareVersion isEqualToString: @"Version 1.1.3 (Build 4A93)"])
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath: @"/var/mobile/Library/Preferences" isDirectory: &isDir])
		{
			libLocation = @"/var/mobile/Library/Preferences/";
			fileLocation = @"/var/mobile/";
		}
		else
		{
			libLocation = @"/var/root/Library/Preferences/";
			fileLocation = @"/var/root/";
		}
	}
	else
	{
		libLocation = @"/var/root/Library/Preferences/";
		fileLocation = @"/var/root/";
	}
	
	NSString *DBFile = [libLocation stringByAppendingString: @"MobileRSS/rss.db"];

	if (![[NSFileManager defaultManager] fileExistsAtPath: [libLocation stringByAppendingString: @"MobileRSS"] isDirectory: &isDir])
	{
		// Ensure library directories exsist
		[[NSFileManager defaultManager] createDirectoryAtPath: [libLocation stringByAppendingString: @"MobileRSS"] attributes: nil];
	}

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
	}
	else
	{
		// If we just created the DB above, then there is no need to see if we need to clear it because it already is
		if ([_overwriteSwitch value] != 0)
		{
			[db executeUpdate:@"delete from feedItems", nil];
			[db executeUpdate:@"delete from feeds", nil];
		}
	}

	NSData *contents = [NSFm contentsAtPath: [fileLocation stringByAppendingString: [files objectAtIndex: [importTable selectedRow]]]];

	xmlDoc = [[[NSClassFromString(@"NSXMLDocument") alloc] initWithData:contents options:NSXMLNodeOptionsNone error:&err] autorelease];

	statusNode = [xmlDoc rootElement];

	if ([[statusNode name] isEqualToString: @"opml"])
	{
		childNodeEnum = [[statusNode children] objectEnumerator];
		childNode = [childNodeEnum nextObject];

		if ([[childNode name] isEqualToString: @"head"])
		{
			childNode = [childNodeEnum nextObject];
		}

		childNodeEnum = [[childNode children] objectEnumerator];

		while(childNode = [childNodeEnum nextObject])
		{
			NSEnumerator *_childNodeEnum = [[childNode children] objectEnumerator];
			
			NSXMLNode<importDelegateProto> *_childNode = nil;
			
			while(_childNode = [_childNodeEnum nextObject])
			{
				_TitleNode = [_childNode attributeForName:@"title"];
				_URLNode = [_childNode attributeForName:@"xmlUrl"];

				NSMutableString *_urlHolder = [NSMutableString stringWithCapacity: 1];
				[_urlHolder setString: [_URLNode stringValue]];

				[_urlHolder replaceOccurrencesOfString: @"feed://" withString: @"http://" options: NSCaseInsensitiveSearch range: NSMakeRange(0, [_urlHolder length])];

				NSString *_titleHolder = @"";
				
				if ([_TitleNode stringValue] != nil && ![[_TitleNode stringValue] isEqualToString: @""])
				{
					NSLog(@"has title: %@", [_TitleNode stringValue]);
					_titleHolder = [_TitleNode stringValue];
				}
				else
				{
					NSLog(@"using url for title");
					_titleHolder = _urlHolder;
				}

				// Process
				rs = [db executeQuery:@"select feedsID, position from feeds where URL = ?", _urlHolder, nil];

				// If not in the DB then we have a new item
				if (![rs next])
				{
					[rs close];

					[db executeUpdate:@"insert into feeds (feed, URL, position) values (?, ?, ?)", _titleHolder, _urlHolder, [NSString stringWithFormat:@"%d", index], nil];
				}
				else
				{
					// Already there, so we move on
					[rs close];
				}

				index = index + 1;
			}

			if ([childNode attributeForName:@"xmlUrl"] != nil)
			{
				_TitleNode = [childNode attributeForName:@"title"];
				_URLNode = [childNode attributeForName:@"xmlUrl"];

				NSMutableString *urlHolder = [NSMutableString stringWithCapacity: 1];
				[urlHolder setString: [_URLNode stringValue]];

				[urlHolder replaceOccurrencesOfString: @"feed://" withString: @"http://" options: NSCaseInsensitiveSearch range: NSMakeRange(0, [urlHolder length])];

				NSString *titleHolder = @"";
				
				if ([_TitleNode stringValue] != nil && ![[_TitleNode stringValue] isEqualToString: @""])
				{
					//NSLog(@"has title: %@", [_TitleNode stringValue]);
					titleHolder = [_TitleNode stringValue];
				}
				else
				{
					//NSLog(@"using url for title");
					titleHolder = urlHolder;
				}

				// Process
				rs = [db executeQuery:@"select feedsID, position from feeds where URL = ?", urlHolder, nil];

				// If not in the DB then we have a new item
				if (![rs next])
				{
					[rs close];

					[db executeUpdate:@"insert into feeds (feed, URL, position) values (?, ?, ?)", titleHolder, urlHolder, [NSString stringWithFormat:@"%d", index], nil];
				}
				else
				{
					// Already there, so we move on
					[rs close];
				}

				index = index + 1;
			}
		}
	}
	else
	{
		[_eyeCandy hideProgressHUD];
		[_eyeCandy showStandardAlertWithString: @"An Error Occurred" closeBtnTitle: @"Close" withError: @"Invalid OPML File"];
	}

	[db close];
	
	[_eyeCandy hideProgressHUD];

	[_delegate hideImport];
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	[_delegate hideImport];
}

- (void)setDelegate: (id)delegate
{
    _delegate = delegate;
}

- (id)delegate
{
	return _delegate;
}

- (void) dealloc
{	
	[super dealloc];
}

// Start of Preference required methods
- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable*)table 
{
	return 3;
}

- (int) preferencesTable: (UIPreferencesTable*)table numberOfRowsInGroup: (int)group 
{
    switch (group) 
	{ 
        case 0: return 1;
		case 1: return 1;
		case 2: return 1;
		default: return 0;
    }
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForGroup: (int)group 
{
	switch (group)
	{
		default: return nil;
	}
}

- (BOOL) preferencesTable: (UIPreferencesTable*)table isLabelGroup: (int)group 
{
    switch (group)
	{
		case 0: return TRUE;
		case 1: return FALSE;
		case 2: return TRUE;
		default: return TRUE;
	}
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForRow: (int)row inGroup: (int)group 
{	
	switch (group)
	{
		case 0: return _infoText;
		case 1: return _overwriteCell;
		case 2: return _infoTitle;
	}
}

- (float) preferencesTable: (UIPreferencesTable*)table heightForRow: (int)row inGroup: (int)group withProposedHeight: (float)proposed 
{
	float groupLabelBuffer = 24.0f;

	switch (group)
	{
		case 0: return proposed;
		case 1: return proposed;
		case 2: return proposed;
		default: return 0.0f;
	}
}
// End of Preferences required modules

// Start of UITable required methods
- (int)numberOfRowsInTable:(UITable *)table {
	int numRows = [files count];

	return numRows;
}

- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col {	
	UIImageAndTextTableCell *cell = [[[UIImageAndTextTableCell alloc] init] autorelease];

	[cell setTitle: [files objectAtIndex: row]];
	[cell setShowDisclosure: YES];
	[cell setDisclosureStyle: 1];
	[cell setDisclosureClickable: YES];

	return cell;
}

- (BOOL)table:(UITable *)aTable canSelectRow:(int)row {
	if (aTable == importTable)
	{
		[_eyeCandy showProgressHUD:@"Importing..." withWindow:[_delegate getWindow] withView:self withRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];

		[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(import:) userInfo:nil repeats:NO];

		return YES;
	}
	else
	{
		return NO;
	}
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
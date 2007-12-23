#import "FeedList.h"

typedef enum _NSBitmapImageFileType {
   NSTIFFFileType,
   NSBMPFileType,
   NSGIFFileType,
   NSJPEGFileType,
   NSPNGFileType,
   NSJPEG2000FileType
} NSBitmapImageFileType;

@implementation FeedList

- (id) initWithFrame: (struct CGRect)rect withSettingsPath: (NSString*)settingsPath
{
	//Init view with frame rect
	[super initWithFrame: rect];
	
	_settingsPath = settingsPath;
	_prevSelected = -1;

	feeds = [[[NSMutableDictionary alloc] initWithCapacity: 1] retain];
	feedEditors = [[[NSMutableArray alloc] initWithCapacity: 1] retain];

	navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 40.0f)];
	// 0 = Blue
	// 1 = Red
	// 2 = Blue Left Arrow
	// 3 = Bright Blue
	[navBar showLeftButton:@"Add/Edit" withStyle:0 rightButton: @"Save" withStyle: 0];
    [navBar setBarStyle: 3];
	[navBar enableAnimation];
	[navBar setDelegate: self];
	
	[self addSubview: navBar];
	
	bottomNavBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, rect.size.height - 40.0f, 320.0f, 40.0f)];
	[bottomNavBar showLeftButton:@"Swipe to Delete" withStyle:0 rightButton: @"Quick Add" withStyle: 0];
    [bottomNavBar setBarStyle: 3];
	[bottomNavBar enableAnimation];
	[bottomNavBar setDelegate: self];
	
	[self addSubview: bottomNavBar];
	
	// Table to show feeds
	_viewTable = [[FeedTable alloc] initWithFrame: CGRectMake(0.0f, 40.0f, 320.0f, rect.size.height - 40.0f - 40.0f)];
	[_viewTable setSeparatorStyle: 1];
	[_viewTable setDelegate: self];
	[_viewTable setDataSource: self];
	[_viewTable setRowHeight: 28.0f];
	[_viewTable setAllowsReordering:YES];

	_viewTableCol = [[UITableColumn alloc] initWithTitle: @"Feeds" identifier:@"feeds" width: rect.size.width];
	
	// Put the Col into the Table
	[_viewTable addTableColumn: _viewTableCol];

	// Add the table into the main view
	[self addSubview:_viewTable];

	_keyboard = [[EditorKeyboard alloc] initWithFrame:CGRectMake(0.0f, 480.0f, 320.0f, 480.0f)];

	[self addSubview:_keyboard];

	custom_field_editor = [[UITextView alloc] initWithFrame:CGRectMake(0,0,0,0)];
    [custom_field_editor setEditable:NO];

	// Setup Eye Candy View
	_eyeCandy = [[[EyeCandy alloc] init] retain];

	return self;
}

- (void) loadSettings
{
	BOOL DBExists = NO;
	BOOL isDir = YES;
	FMResultSet *rs;
	FMDatabase *db;

	_isEditing = NO;
	_isDeleting = NO;

	feedArray = [[[NSMutableArray alloc] initWithCapacity: 1] retain];
	feedCellArray = [[[NSMutableArray alloc] initWithCapacity: 1] retain];

	NSString *_appLibraryPath = [[_delegate getSettingsDIR] stringByAppendingPathComponent: @"MobileRSS"];
	NSString *DBFile = [_appLibraryPath stringByAppendingPathComponent: @"rss.db"];

	if (![[NSFileManager defaultManager] fileExistsAtPath: _appLibraryPath isDirectory: &isDir])
	{
		// Ensure library directories exsist
		[[NSFileManager defaultManager] createDirectoryAtPath: _appLibraryPath attributes: nil];
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

	if (![db open]) {
	    NSLog(@"Could not open DB at path: %@", DBFile);
	}

	if (DBExists)
	{
		rs = [db executeQuery:@"select feedsID, URL from feeds order by position", nil];

		while ([rs next])
		{
			FeedTableCell *FeedCell = [[FeedTableCell alloc] init];
			[FeedCell setDelegate: self];
			[FeedCell setTable: _viewTable];

			UITextLabel *_feedLabel = [[UITextLabel alloc] initWithFrame: CGRectMake(2.0f, 6.0f, 285.0f, 16.0f)];
			[_feedLabel setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:16]];
			[_feedLabel setText: [rs stringForColumn:@"URL"]];
			[_feedLabel setBackgroundColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:0.0f]];
			[_feedLabel setWrapsText: NO];

			[feedEditors addObject: _feedLabel];

			[FeedCell addSubview:_feedLabel];

			[feedCellArray addObject: FeedCell];
		}

		[rs close];

		[feeds setObject:feedArray forKey: @"Feeds"];

		[_viewTable reloadData];
	}
}

- (void) makeEditable
{
	int index;
	struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;
	
	_isEditing = YES;
	
	int count = [feedEditors count];

	[navBar showButtonsWithLeftTitle: @"Sortable" rightTitle:@"Save" leftBack: FALSE];
	
	[self disableCellReordering];

	NSArray *_tmpFeedArray = [[NSArray alloc] initWithArray: feedEditors];

	[feedEditors removeAllObjects];
	[feedArray removeAllObjects];
	[feedCellArray removeAllObjects];
	[feeds removeAllObjects];
	
	[_viewTable setAllowsReordering:NO];
	[_viewTable clearAllData];
	[_viewTable reloadData];
	
	// Since we HAVE to do the below to go editable, we might as well do it to go sortable to keep things the same, and to make sure there are no leftovers
	[_viewTable removeFromSuperview];
	
	_viewTable = [[FeedTable alloc] initWithFrame: CGRectMake(0.0f, 40.0f, 320.0f, rect.size.height - 215.0f - 40.0f)];
	[_viewTable setSeparatorStyle: 1];
	[_viewTable setDelegate: self];
	[_viewTable setDataSource: self];
	[_viewTable setRowHeight: 28.0f];
	[_viewTable setAllowsReordering:YES];
	
	_viewTableCol = [[UITableColumn alloc] initWithTitle: @"Feeds" identifier:@"feeds" width: rect.size.width];

	[_viewTable addTableColumn: _viewTableCol];

	[self addSubview:_viewTable];

	[custom_field_editor setEditable:NO];
	
	for (index = 0; index < count; index++)
	{
		if (![[[_tmpFeedArray objectAtIndex: index] text] isEqualToString: @""])
		{
			UIImageAndTextTableCell *FeedCell = [[UIImageAndTextTableCell alloc] init];

			FeedTextField *_feedField = [[FeedTextField alloc] initWithFrame: CGRectMake(2.0f, 0.0f, 316.0f, 28.0f)];
			[_feedField setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:16]];
			[_feedField setText: [[_tmpFeedArray objectAtIndex: index] text]];
			[_feedField setVerticallyCenterText: YES];
			[_feedField setDelegate: self];
			
			[feedEditors addObject: _feedField];

			[FeedCell addSubview:_feedField];

			[feedCellArray addObject: FeedCell];
		}
	}

	for (index = 0; index < 8; index++)
	{
		UIImageAndTextTableCell *FeedCell = [[UIImageAndTextTableCell alloc] init];

		FeedTextField *_feedField = [[FeedTextField alloc] initWithFrame: CGRectMake(2.0f, 8.0f, 316.0f, 16.0f)];
		[_feedField setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:16]];
		[_feedField setText: @""];
		[_feedField setDelegate: self];
		
		[feedEditors addObject: _feedField];

		[FeedCell addSubview:_feedField];

		[feedCellArray addObject: FeedCell];

		[feeds setObject:feedArray forKey: @"Feeds"];
	}
	
	[_viewTable reloadData];
	
	[_keyboard show];
}

- (void) makeSortable
{
	int index;
	struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;
	
	[_keyboard hide];
	
	_isEditing = NO;

	[navBar showButtonsWithLeftTitle: @"Add/Edit" rightTitle:@"Save" leftBack: FALSE];

	int count = [feedEditors count];
	
	//NSLog(@"feed: %@", feedEditors);

	[feedArray removeAllObjects];
	[feedCellArray removeAllObjects];
	[feeds removeAllObjects];

	[_viewTable clearAllData];
	[_viewTable reloadData];

	// Even with the above _viewTable calls I can not get it to remove all remnients of selections/reording without totally removing the viewtable and recreating it
	// Start of nasty code which I hope is a hack and not the only way to do it
	[_viewTable removeFromSuperview];
	
	_viewTable = [[FeedTable alloc] initWithFrame: CGRectMake(0.0f, 40.0f, 320.0f, rect.size.height - 40.0f - 40.0f)];
	[_viewTable setSeparatorStyle: 1];
	[_viewTable setDelegate: self];
	[_viewTable setDataSource: self];
	[_viewTable setRowHeight: 28.0f];
	[_viewTable setAllowsReordering:YES];
	
	_viewTableCol = [[UITableColumn alloc] initWithTitle: @"Feeds" identifier:@"feeds" width: rect.size.width];

	[_viewTable addTableColumn: _viewTableCol];

	[self addSubview:_viewTable];
	// End of nasty code which I hope is a hack and not the only way to do it

	[custom_field_editor setEditable:NO];

	for (index = 0; index < count; index++)
	{
		if (![[[feedEditors objectAtIndex: index] text] isEqualToString: @""])
		{
			FeedTableCell *FeedCell = [[FeedTableCell alloc] init];
			[FeedCell setDelegate: self];
			[FeedCell setTable: _viewTable];

			UITextLabel *_feedLabel = [[UITextLabel alloc] initWithFrame: CGRectMake(2.0f, 8.0f, 285.0f, 16.0f)];
			[_feedLabel setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:16]];
			[_feedLabel setText: [[feedEditors objectAtIndex: index] text]];
			[_feedLabel setBackgroundColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:0.0f]];
			[_feedLabel setWrapsText: NO];

			[FeedCell addSubview:_feedLabel];

			[feedCellArray addObject: FeedCell];
		}
	}

	[feeds setObject:feedArray forKey: @"Feeds"];
	
	[_viewTable reloadData];
}

- (void) addNewTextField
{
	int index;
	
	index = ([feedCellArray count] - 2);
	
	FeedTextField *_feedField = [feedEditors objectAtIndex: index];

	if (!([[_feedField text] isEqualToString: @""]))
	{
		UIImageAndTextTableCell *FeedCell = [[UIImageAndTextTableCell alloc] init];

		FeedTextField *__feedField = [[FeedTextField alloc] initWithFrame: CGRectMake(2.0f, 2.0f, 316.0f, 16.0f)];
		[__feedField setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:16]];
		[__feedField setText: @""];

		[FeedCell addSubview:__feedField];
		
		[feedEditors addObject: __feedField];

		[feedCellArray addObject: FeedCell];

		[feeds setObject:feedArray forKey: @"Feeds"];

		[_viewTable reloadData];
	}
	else
	{
		index = ([feedCellArray count] - 1);
	
		FeedTextField *___feedField = [feedEditors objectAtIndex: index];

		if (!([[___feedField text] isEqualToString: @""]))
		{
			UIImageAndTextTableCell *_FeedCell = [[UIImageAndTextTableCell alloc] init];

			UITextField *____feedField = [[UITextField alloc] initWithFrame: CGRectMake(2.0f, 2.0f, 316.0f, 16.0f)];
			[____feedField setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:16]];
			[____feedField setText: @""];

			[_FeedCell addSubview:____feedField];
		
			[feedEditors addObject: ____feedField];

			[feedCellArray addObject: _FeedCell];

			[feeds setObject:feedArray forKey: @"Feeds"];

			[_viewTable reloadData];
		}
	}
}

- (void) quickAdd: (NSString*)URL
{
	int index;
	BOOL foundBlankRow = FALSE;

	// Find first empty row
	for (index = 0; index < [feedEditors count]; index++)
	{
		if ([[[feedEditors objectAtIndex: index] text] isEqualToString: @""])
		{
			NSLog(@"row: %i editor: %@ text: %@", index, [feedEditors objectAtIndex: index], [[feedEditors objectAtIndex: index] text]);
			[[feedEditors objectAtIndex: index] setText: URL];

			foundBlankRow = TRUE;
			break;
		}
	}

	if (!foundBlankRow)
	{
		FeedTableCell *FeedCell = [[FeedTableCell alloc] init];
		[FeedCell setDelegate:self];

		UITextLabel *_feedLabel = [[UITextLabel alloc] initWithFrame: CGRectMake(2.0f, 8.0f, 285.0f, 16.0f)];
		[_feedLabel setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:16]];
		[_feedLabel setText: URL];
		[_feedLabel setBackgroundColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:0.0f]];
		[_feedLabel setWrapsText: NO];

		[FeedCell addSubview:_feedLabel];

		[feedEditors addObject: _feedLabel];

		[feedCellArray addObject: FeedCell];
	}

	[_viewTable reloadData];
}

- (void) reloadTable
{
	[_viewTable reloadData];
}

- (void) disableCellReordering
{
	int i;

	for (i = 0; i < [feedCellArray count]; i++)
	{
		cell = [feedCellArray objectAtIndex: i];

		[cell setEnableReordering:NO animated:YES];
		[cell setSelected: NO];
	}
	
	[_viewTable setAllowsReordering: NO];
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	int i;

	if (navbar == navBar)
	{
		switch (button) 
		{
			case 0: //Save
				[_eyeCandy showProgressHUD:@"Saving..." withWindow:[_delegate getWindow] withView:self withRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];

				[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(saveFeeds:) userInfo:nil repeats:NO];
			break;

			case 1:	//Edit/Sort
				if (_isEditing != YES)
				{
					[self makeEditable];
				}
				else
				{
					[self makeSortable];
				}
			break;
		}
	}
	else
	{
		switch (button) 
		{
			case 0: //Quick Add
				[self showQuickAdd];
			break;

			case 1:	//Removable
				[self makeRemovable];
			break;
		}
	}
}

- (void) saveFeeds:(id)param
{
	BOOL DBExists = NO;
	BOOL isDir = YES;
	int index;
	NSMutableArray *_feedList = [[[NSMutableArray alloc] initWithCapacity: 1] retain];
	NSMutableArray *_oldList = [[[NSMutableArray alloc] initWithCapacity: 1] retain];
	NSMutableArray *_oldListIDs = [[[NSMutableArray alloc] initWithCapacity: 1] retain];
	FMResultSet *rs;
	FMDatabase *db;

	NSString *_appLibraryPath = @"/var/root/Library/Preferences/MobileRSS";
	NSString *DBFile = [_appLibraryPath stringByAppendingPathComponent: @"rss.db"];

	if (![[NSFileManager defaultManager] fileExistsAtPath: _appLibraryPath isDirectory: &isDir])
	{
		// Ensure library directories exsist
		[[NSFileManager defaultManager] createDirectoryAtPath: _appLibraryPath attributes: nil];
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
		[db executeUpdate:@"create table feeds (feedsID INTEGER PRIMARY KEY, feed text, URL text, position integer)", nil];
		[db executeUpdate:@"create table feedItems (feedItemsID INTEGER PRIMARY KEY, feedsID integer, itemTitle text, itemDate text, itemDateConv text, itemLink text, itemDescrip text, hasViewed integer, dateAdded text)", nil];
	}

	for (index = 0; index < [feedEditors count]; index++)
	{
		NSMutableString *_feedURL = [NSMutableString stringWithCapacity: 1];
		[_feedURL setString: [[feedEditors objectAtIndex: index] text]];

		[_feedURL replaceOccurrencesOfString: @"feed://" withString: @"http://" options: NSCaseInsensitiveSearch range: NSMakeRange(0, [[[feedEditors objectAtIndex: index] text] length])];

		NSString *feedURL = _feedURL;

		if (![feedURL isEqualToString: @""])
		{
			rs = [db executeQuery:@"select feedsID, position from feeds where URL = ?", feedURL, nil];

			// If not in the DB then we have a new item
			if (![rs next])
			{
				[rs close];

				[db executeUpdate:@"insert into feeds (feed, URL, position) values (?, ?, ?)", feedURL, feedURL, [NSString stringWithFormat:@"%d", index], nil];

				[_feedList addObject: feedURL];
			}
			else
			{
				// It was already in the DB, check to see if it has the correct position
				if ([rs intForColumn:@"position"] != index)
				{
					int feedID = [rs intForColumn:@"feedsID"];

					[rs close];

					// It has the wrong position so lets update it
					[db executeUpdate:@"update feeds set position = ? where feedsID = ?", [NSString stringWithFormat:@"%d", index], [NSString stringWithFormat:@"%d", feedID], nil];
				}
				else
				{
					[rs close];
				}

				[_feedList addObject: feedURL];
			}
		}
	}

	rs = [db executeQuery:@"select feedsID, URL from feeds", nil];

	while ([rs next])
	{
		if (!([_feedList containsObject: [rs stringForColumn:@"URL"]]))
		{
			[_oldList addObject: [rs stringForColumn:@"URL"]];
			[_oldListIDs addObject: [NSString stringWithFormat:@"%d", [rs intForColumn:@"feedsID"]]];
		}
	}

	[rs close];

	if ([_oldList count] > 0)
	{
		[db beginTransaction];
	}

	for (index = 0; index < [_oldList count]; index++)
	{
		[db executeUpdate:@"delete from feedItems where feedsID = ?", [_oldListIDs objectAtIndex:index], nil];
		[db executeUpdate:@"delete from feeds where URL = ?", [_oldList objectAtIndex:index], nil];
	}

	if ([_oldList count] > 0)
	{
		[db commit];
	}

	[db close];

	[_oldList release];
	[_oldListIDs release];

	[_eyeCandy hideProgressHUD];

	// Done, so lets hide the FeedList and go back to the standard settings
	[_delegate hideFeedList];
}

- (void) showQuickAdd
{
	struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;

	_QuickAddView = [[[QuickAdd alloc] initWithFrame:rect] retain];
	[_QuickAddView setDelegate: self];
	
	[transitionView transition:3 fromView:self toView:_QuickAddView];

	[[_delegate getWindow] setContentView: _QuickAddView];
}

- (void) hideQuickAdd
{
	[transitionView transition:7 fromView:_QuickAddView toView:self];

	[[_delegate getWindow] setContentView: self];

	[_QuickAddView removeFromSuperview];
	[_QuickAddView release];
}

- (void) tableRowSelected: (NSNotification*) notification
{
	_currSelectedRow = [_viewTable selectedRow];
	NSLog(@"Current: %i Previous: %i",_currSelectedRow,_prevSelected);
	
	if (_isEditing != YES)
	{
		[self disableCellReordering];

		cell = [feedCellArray objectAtIndex:_currSelectedRow];

		if (_currSelectedRow == _prevSelected)
		{
			[cell setSelected: NO];

			_prevSelected = -1;
		}
		else
		{
			NSLog(@"Begin reordering of cell at row: %i",_currSelectedRow);

			[_viewTable setAllowsReordering: YES];
			
			[cell setSelected: YES];
			[cell setEnableReordering:YES animated:YES];

			[_viewTable _beginReorderingForCell:cell];
			//[_viewTable _enableRowDeletion: NO forCell: cell atRow: _currSelectedRow allowInsert: NO allowReorder: YES animated: YES];

			_prevSelected = _currSelectedRow;
		}
	}
	else
	{
		if (_currSelectedRow == ([feedCellArray count] - 1))
		{
			UIImageAndTextTableCell *FeedCell = [[UIImageAndTextTableCell alloc] init];

			FeedTextField *__feedField = [[FeedTextField alloc] initWithFrame: CGRectMake(2.0f, 2.0f, 316.0f, 16.0f)];
			[__feedField setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:16]];
			[__feedField setText: @""];

			[FeedCell addSubview:__feedField];
			
			[feedEditors addObject: __feedField];

			[feedCellArray addObject: FeedCell];

			[feeds setObject:feedArray forKey: @"Feeds"];

			[_viewTable reloadData];
		}
	}
}

- (int) table:(UITable *) table moveDestinationForRow:(int)row withSuggestedDestinationRow:(int) suggestedRow 
{
	if (_isEditing != YES)
	{
		NSLog(@"For Row: %i Suggested Row: %i",row,suggestedRow);
	
		_prevSuggestedRow = suggestedRow;

		return suggestedRow;
	}
	else
	{
		return row;
	}
}

- (void) table:(UITable *)table movedRow:(int)row toRow:(int)toRow
{
	if (_isEditing != YES)
	{
		NSLog(@"Moving from row %i to %i",row,toRow);
		
		UIImageAndTextTableCell *_cell = [[feedCellArray objectAtIndex:row] autorelease];
		[feedCellArray removeObjectAtIndex:row];
		[feedCellArray insertObject:_cell atIndex:toRow];

		FeedTextField *editor = [[feedEditors objectAtIndex:row] autorelease];
		[feedEditors removeObjectAtIndex:row];
		[feedEditors insertObject:editor atIndex:toRow];

		_movedRow = toRow;

		_prevSuggestedRow = -1;
	}
}

- (void) tableDidFinishMovingRow:(NSNotification*) notification
{
	if (_isEditing != YES)
	{
		NSLog(@"Finished moving row: %i",_movedRow);
	}
}

- (void) makeRemovable
{
	int index;
	
	if (!_isDeleting)
	{
		_isDeleting = YES;

		// 0 = Blue
		// 1 = Red
		// 2 = Blue Left Arrow
		// 3 = Bright Blue
		[bottomNavBar showLeftButton:@"Swipe to Delete" withStyle:1 rightButton: @"Quick Add" withStyle: 0];
	
		[self disableCellReordering];

		for (index = 0; index < [feedCellArray count]; index++)
		{
			cell = [[feedCellArray objectAtIndex:index] autorelease];
			[cell createRemoveControl];
			[cell _showDeleteOrInsertion:YES withDisclosure:NO animated:YES isDelete:YES andRemoveConfirmation:YES];
			[cell setEnableReordering: NO animated: YES];
		}

		[_viewTable enableRowDeletion:YES animated:YES];
		[_viewTable reloadData];
	}
	else
	{
		_isDeleting = NO;

		// 0 = Blue
		// 1 = Red
		// 2 = Blue Left Arrow
		// 3 = Bright Blue
		[bottomNavBar showLeftButton:@"Swipe to Delete" withStyle:0 rightButton: @"Quick Add" withStyle: 0];

		struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;

		_isEditing = NO;

		int count = [feedEditors count];

		[feedArray removeAllObjects];
		[feedCellArray removeAllObjects];
		[feeds removeAllObjects];

		[_viewTable clearAllData];
		[_viewTable reloadData];

		// Even with the above _viewTable calls I can not get it to remove all remnients of selections/reording without totally removing the viewtable and recreating it
		// Start of nasty code which I hope is a hack and not the only way to do it
		[_viewTable removeFromSuperview];

		_viewTable = [[FeedTable alloc] initWithFrame: CGRectMake(0.0f, 40.0f, 320.0f, rect.size.height - 40.0f - 40.0f)];
		[_viewTable setSeparatorStyle: 1];
		[_viewTable setDelegate: self];
		[_viewTable setDataSource: self];
		[_viewTable setRowHeight: 28.0f];
		[_viewTable setAllowsReordering:YES];

		_viewTableCol = [[UITableColumn alloc] initWithTitle: @"Feeds" identifier:@"feeds" width: rect.size.width];

		[_viewTable addTableColumn: _viewTableCol];

		[self addSubview:_viewTable];
		// End of nasty code which I hope is a hack and not the only way to do it

		[custom_field_editor setEditable:NO];

		for (index = 0; index < count; index++)
		{
			if (![[[feedEditors objectAtIndex: index] text] isEqualToString: @""])
			{
				FeedTableCell *FeedCell = [[FeedTableCell alloc] init];
				[FeedCell setDelegate: self];
				[FeedCell setTable: _viewTable];

				UITextLabel *_feedLabel = [[UITextLabel alloc] initWithFrame: CGRectMake(2.0f, 8.0f, 285.0f, 16.0f)];
				[_feedLabel setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:16]];
				[_feedLabel setText: [[feedEditors objectAtIndex: index] text]];
				[_feedLabel setBackgroundColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:0.0f]];
				[_feedLabel setWrapsText: NO];

				[FeedCell addSubview:_feedLabel];

				[feedCellArray addObject: FeedCell];
			}
		}

		[feeds setObject:feedArray forKey: @"Feeds"];

		[_viewTable reloadData];
	}
}

- (BOOL) getIsDeleting
{
	return _isDeleting;
}

- (void) setDeletingRow: (int)row
{
	deletingRow = row;
}

- (int) getDeletingRow
{
	return deletingRow;
}

- (void) removeRow: (int)row
{
	[[feedEditors objectAtIndex: row] setText: @""];

	if ([feedEditors count] > 1)
	{
		[feedEditors removeObjectAtIndex:row];
		[feedCellArray removeObjectAtIndex:row];
	}
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

// Start of UITable required methods
- (int)numberOfRowsInTable:(UITable *)table {
	int numRows = [feedCellArray count];

	return numRows;
}

- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col {	
	cell = [feedCellArray objectAtIndex:row];

	return cell;
}

- (BOOL)table:(UITable *)aTable canSelectRow:(int)row {
	if (!_isEditing && !_isDeleting)
	{
		return YES;
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

#pragma mark UIWindowDelegate Methods

- (id) windowWillReturnFieldEditor:(UIWindow*)sender toObject:(id)anObject
{
    if ([anObject isKindOfClass:[UITextField class]])
    {
        // do any per-edit setup here (e.g. select all text)
        return custom_field_editor;
    }
    return nil;
}

@end
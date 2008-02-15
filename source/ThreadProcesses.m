#import "ThreadProcesses.h"

@implementation ThreadProcesses

- (void) refreshAllFeeds:(id)param
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSLog(@"Refreshing All Feeds");

	int index;
	int i;
	int fullIndex = 0;
	NSMutableArray *_feed = [NSMutableArray arrayWithCapacity:1];
	NSMutableArray *_feedCount = [NSMutableArray arrayWithCapacity:1];
	NSMutableArray *_feedNames = [NSMutableArray arrayWithCapacity:1];
	NSMutableArray *__content = [NSMutableArray arrayWithCapacity:1];
	
	Feeds *_feeds = [[Feeds alloc] init];
	[_feeds setDelegate: self];

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

	FMDatabase *_db = [FMDatabase databaseWithPath: DBFile];

	if (![_db open]) {
	    NSLog(@"Could not open db.");
	}

	FMResultSet *rs = [_db executeQuery:@"select feedsID, URL, position from feeds order by position", nil];

	while ([rs next])
	{
		//NSLog(@"Getting Feed: %@", [rs stringForColumn: @"URL"]);

		[_feeds initArray];
		[_feeds pullFeedURL: [rs stringForColumn: @"URL"]];

		if ([[_feeds returnArray] count] > 0)
		{
			[_feed addObject: [rs stringForColumn: @"feedsID"]];

			[__content addObjectsFromArray: [_feeds returnArray]];

			[_feedCount addObject: [NSString stringWithFormat:@"%d", [[_feeds returnArray] count]]];
			[_feedNames addObject: [[[_feeds returnArray] objectAtIndex: 0] objectForKey: @"feed"]];
		}
		else
		{
			[_feed addObject: [rs stringForColumn: @"feedsID"]];

			[_feedCount addObject: [NSString stringWithFormat:@"%d", [[_feeds returnArray] count]]];
			[_feedNames addObject: [rs stringForColumn: @"URL"]];
		}
	}

	[rs close];

	for (i = 0; i < [_feed count]; i++)
	{
		[_db executeUpdate:@"update feeds set feed=? where feedsID=?", [_feedNames objectAtIndex:i], [_feed objectAtIndex: i], nil];

		for (index = 0; index < [[_feedCount objectAtIndex: i] intValue]; index++)
		{
			NSDictionary *_item = [[__content objectAtIndex:fullIndex] retain];

			//rs = [_db executeQuery:@"select feedItemsID from feedItems where feedsID = ? and itemTitle = ? and itemDate = ?", [_feed objectAtIndex: i], [_item objectForKey:@"ItemTitle"], [_item objectForKey:@"ItemDates"], nil];
			rs = [_db executeQuery:@"select feedItemsID from feedItems where feedsID = ? and itemTitle = ?", [_feed objectAtIndex: i], [_item objectForKey:@"ItemTitle"], nil];

			// If not in the DB then we have a new item
			if (![rs next])
			{
				[rs close];

				rs = [_db executeQuery:@"select deletedItemsID from deletedItems where feedsID = ? and itemTitle = ?", [_feed objectAtIndex: i], [_item objectForKey:@"ItemTitle"], nil];

				// If not in the deleted table then we want it
				if (![rs next])
				{
					[rs close];

					if ([_item objectForKey:@"ItemTitle"] != nil)
					{
						NSDate *_itemDateConv;
						NSString *itemDateConv;

						if ([_item objectForKey:@"ItemDates"] == nil || [_item objectForKey:@"ItemDates"] == NULL)
						{
							itemDateConv = [NSString stringWithFormat:@"%@", [NSCalendarDate  date]];
							_itemDateConv = [NSDate dateWithNaturalLanguageString: itemDateConv];
							itemDateConv = [_itemDateConv description];
						}
						else
						{
							_itemDateConv = [NSDate dateWithNaturalLanguageString: [_item objectForKey:@"ItemDates"]];
							itemDateConv = [_itemDateConv description];
						}

						[_db executeUpdate:@"insert into feedItems (feedsID, itemTitle, itemDate, itemDateConv, itemLink, itemDescrip, hasViewed, dateAdded) values (?, ?, ?, ?, ?, ?, ?, ?)", [_feed objectAtIndex: i], [_item objectForKey:@"ItemTitle"], [_item objectForKey:@"ItemDates"], itemDateConv, [_item objectForKey:@"ItemLinks"], [_item objectForKey:@"ItemDesc"], @"0", [NSString stringWithFormat:@"%@", [NSCalendarDate  date]], nil];
					}
				}
				else
				{
					[rs close];
				}
			}
			else
			{
				[rs close];
			}
			
			fullIndex = fullIndex + 1;
		}
	}
	NSLog(@"Done, now dbupdate");
	[self performSelectorOnMainThread:@selector(DBUpdated:) withObject:nil waitUntilDone:NO];
	NSLog(@"done, now db close");
	[_db close];
	NSLog(@"done, now pool release");
	[pool release];
}

- (void) showErrGetFeed: (NSString*)url
{
	[_delegate showErrGetFeed:url];
}

- (void) refreshSingleFeed:(id)param
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	int feedsID = (int)[_delegate getFeedsID];

	//NSLog(@"Refreshing Single Feed: %d", feedsID);

	int index;
	int i = 0;
	NSMutableArray *_feedCount = [NSMutableArray arrayWithCapacity:1];
	NSMutableArray *_feedNames = [NSMutableArray arrayWithCapacity:1];
	NSMutableArray *__content = [NSMutableArray arrayWithCapacity:1];

	Feeds *_feeds = [[Feeds alloc] init];

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

	FMDatabase *db = [FMDatabase databaseWithPath: DBFile];

	if (![db open]) {
	    NSLog(@"Could not open db.");
	}

	FMResultSet *rs = [db executeQuery:@"select feedsID, URL, position from feeds where feedsID=?", [NSString stringWithFormat:@"%d", feedsID], nil];

	while ([rs next])
	{
		//NSLog(@"Getting Feed: %@", [rs stringForColumn: @"URL"]);

		[_feeds initArray];
		[_feeds pullFeedURL: [rs stringForColumn: @"URL"]];

		[__content addObjectsFromArray: [_feeds returnArray]];

		[_feedCount addObject: [NSString stringWithFormat:@"%d", [[_feeds returnArray] count]]];
		//NSLog(@"bla1");
		//NSLog(@"%@", [_feeds returnArray]);
		//NSLog(@"count %d", [[_feeds returnArray] count]);
		
		if ([[_feeds returnArray] count] > 0)
		{
			//NSLog(@"bbbb");
			[_feedNames addObject: [[[_feeds returnArray] objectAtIndex: 0] objectForKey: @"feed"]];
		}
		else
		{
			//NSLog(@"bbbb2");
			[_feedNames addObject: [rs stringForColumn: @"URL"]];
		}
		//NSLog(@"bla2");
	}

	[rs close];

	[db executeUpdate:@"update feeds set feed=? where feedsID=?", [_feedNames objectAtIndex:i], [NSString stringWithFormat:@"%d", feedsID], nil];

	for (index = 0; index < [[_feedCount objectAtIndex: i] intValue]; index++)
	{
		NSDictionary *_item = [[__content objectAtIndex:index] retain];

		//rs = [db executeQuery:@"select feedItemsID from feedItems where feedsID = ? and itemTitle = ? and itemDate = ?", [NSString stringWithFormat:@"%d", feedsID], [_item objectForKey:@"ItemTitle"], [_item objectForKey:@"ItemDates"], nil];
		rs = [db executeQuery:@"select feedItemsID from feedItems where feedsID = ? and itemTitle = ?", [NSString stringWithFormat:@"%d", feedsID], [_item objectForKey:@"ItemTitle"], nil];

		// If not in the DB then we have a new item
		if (![rs next])
		{
			[rs close];

			rs = [db executeQuery:@"select deletedItemsID from deletedItems where feedsID = ? and itemTitle = ?", [NSString stringWithFormat:@"%d", feedsID], [_item objectForKey:@"ItemTitle"], nil];

			// If not in the deleted table then we want it
			if (![rs next])
			{
				[rs close];

				if ([_item objectForKey:@"ItemTitle"] != nil)
				{
					NSDate *_itemDateConv;
					NSString *itemDateConv;

					if ([_item objectForKey:@"ItemDates"] == nil || [_item objectForKey:@"ItemDates"] == NULL)
					{
						itemDateConv = [NSString stringWithFormat:@"%@", [NSCalendarDate  date]];
					}
					else
					{
						_itemDateConv = [NSDate dateWithNaturalLanguageString: [_item objectForKey:@"ItemDates"]];
						itemDateConv = [_itemDateConv description];
					}

					[db executeUpdate:@"insert into feedItems (feedsID, itemTitle, itemDate, itemDateConv, itemLink, itemDescrip, hasViewed, dateAdded) values (?, ?, ?, ?, ?, ?, ?, ?)", [NSString stringWithFormat:@"%d", feedsID], [_item objectForKey:@"ItemTitle"], [_item objectForKey:@"ItemDates"], [NSString stringWithFormat:@"%@", itemDateConv], [_item objectForKey:@"ItemLinks"], [_item objectForKey:@"ItemDesc"], @"0", [NSString stringWithFormat:@"%@", [NSCalendarDate  date]], nil];
				}
			}
			else
			{
				[rs close];
			}
		}
		else
		{
			[rs close];
		}
	}
	
	[self performSelectorOnMainThread:@selector(DBUpdated:) withObject:nil waitUntilDone:NO];

	[db close];

	[pool release];
}

- (void) DBUpdated:(id)param
{
	[_delegate clearSpinner];
}

- (void)setDelegate: (id)delegate
{
    _delegate = delegate;
}

- (void) dealloc
{
	[super dealloc];
}

@end
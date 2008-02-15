#import "RSSDaemon.h"

@implementation RSSDaemon

- (void) applicationDidFinishLaunching: (id) unused
{
	//_feeds = [[Feeds alloc] init];

	[self processPlistWithPath];

	[self refreshAllFeeds];

	[self InfiLoop];
}

- (void) InfiLoop
{
	if (_RefreshEvery != 0)
	{
		time_t begin = time(0);
		time_t nextRun = begin + _RefreshEvery;

		while (1)
		{
			time_t now = time(0);

			if (now >= nextRun)
			{
				nextRun += _RefreshEvery;

				[self refreshAllFeeds];
			}

			NSLog(@"going to sleep");
			sleep(60);
			NSLog(@"waking up");
		}
	}
}

- (void) processPlistWithPath
{
	NSDictionary *FeedsDict = [self loadSettings: [self getSettingsPath]];
	NSEnumerator *enumerator = [FeedsDict keyEnumerator];
	NSString *currKey;
	NSDictionary *feedDict;

	while (currKey = [enumerator nextObject])
	{
		if ([currKey isEqualToString: @"KeepFeedsFor"])
		{
			_KeepFeedsFor = [[FeedsDict valueForKey: currKey] intValue];
			_KeepFeedsFor = (_KeepFeedsFor * 604800);
		}
		else if ([currKey isEqualToString: @"RefreshEvery"])
		{
			_RefreshEvery = [[FeedsDict valueForKey: currKey] intValue];
			
			switch (_RefreshEvery)
			{
				case 0:
					//MANUAL
				break;
				
				case 1:
					//5 Min
					_RefreshEvery = 300;
				break;
				
				case 2:
					//10 Min
					_RefreshEvery = 600;
				break;
				
				case 3:
					//15 Min
					_RefreshEvery = 900;
				break;
				
				case 4:
					//20 Min
					_RefreshEvery = 1200;
				break;
				
				case 5:
					//30 Min
					_RefreshEvery = 1800;
				break;
				
				case 6:
					//40 Min
					_RefreshEvery = 2400;
				break;
				
				case 7:
					//50 Min
					_RefreshEvery = 3000;
				break;
				
				case 8:
					//1 Hour
					_RefreshEvery = 3600;
				break;
				
				case 9:
					//2 Hour
					_RefreshEvery = 7200;
				break;
				
				case 10:
					//3 Hour
					_RefreshEvery = 10800;
				break;
				
				case 11:
					//6 Hour
					_RefreshEvery = 21600;
				break;
				
				case 12:
					//9 Hour
					_RefreshEvery = 32400;
				break;
				
				case 13:
					//12 Hour
					_RefreshEvery = 43200;
				break;
				
				case 14:
					//1 Day
					_RefreshEvery = 604800;
				break;
			}
		}
	}
}

- (NSDictionary*) loadSettings: (NSString*)path
{
	_settingsPath = [path retain];

	if ([[NSFileManager defaultManager] isReadableFileAtPath: _settingsPath])
	{
		plistDict = [NSDictionary dictionaryWithContentsOfFile: _settingsPath];
	}
	else
	{
		plistDict = [NSDictionary dictionaryWithContentsOfFile: @"/Applications/RSS.app/Default.plist"];
	}

	return plistDict;
}

- (void) refreshAllFeeds
{
	pid_t FoundPID = [self FindPID];

	if (FoundPID == -1)
	{
		_feeds = [[Feeds alloc] init];

		totalUnread = 0;

		int index;
		int i;
		int fullIndex = 0;
		NSMutableArray *_feed = [NSMutableArray arrayWithCapacity:1];
		NSMutableArray *_feedCount = [NSMutableArray arrayWithCapacity:1];
		NSMutableArray *_feedNames = [NSMutableArray arrayWithCapacity:1];
		_content = [NSMutableArray arrayWithCapacity:1];

		NSString *DBFile = @"/var/root/Library/Preferences/MobileRSS/rss.db";

		db = [FMDatabase databaseWithPath: DBFile];

		if (![db open]) {
		    NSLog(@"Could not open db.");
		}

		FMResultSet *rs = [db executeQuery:@"select feedsID, URL, position from feeds order by position", nil];

		while ([rs next])
		{
			[_feed addObject: [rs stringForColumn: @"feedsID"]];

			[_feeds initArray];
			[_feeds pullFeedURL: [rs stringForColumn: @"URL"]];

			[_content addObjectsFromArray: [_feeds returnArray]];

			[_feedCount addObject: [NSString stringWithFormat:@"%d", [[_feeds returnArray] count]]];
			[_feedNames addObject: [[[_feeds returnArray] objectAtIndex: 0] objectForKey: @"feed"]];
		}

		[rs close];

		for (i = 0; i < [_feed count]; i++)
		{
			[db executeUpdate:@"update feeds set feed=? where feedsID=?", [_feedNames objectAtIndex:i], [_feed objectAtIndex: i], nil];

			for (index = 0; index < [[_feedCount objectAtIndex: i] intValue]; index++)
			{
				NSDictionary *_item = [[_content objectAtIndex:fullIndex] retain];
			
				//rs = [db executeQuery:@"select feedItemsID from feedItems where feedsID = ? and itemTitle = ? and itemDate = ?", [_feed objectAtIndex: i], [_item objectForKey:@"ItemTitle"], [_item objectForKey:@"ItemDates"], nil];
				rs = [db executeQuery:@"select feedItemsID from feedItems where feedsID = ? and itemTitle = ?", [_feed objectAtIndex: i], [_item objectForKey:@"ItemTitle"], nil];

				// If not in the DB then we have a new item
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

						[db executeUpdate:@"insert into feedItems (feedsID, itemTitle, itemDate, itemDateConv, itemLink, itemDescrip, hasViewed, dateAdded) values (?, ?, ?, ?, ?, ?, ?, ?)", [_feed objectAtIndex: i], [_item objectForKey:@"ItemTitle"], [_item objectForKey:@"ItemDates"], itemDateConv, [_item objectForKey:@"ItemLinks"], [_item objectForKey:@"ItemDesc"], @"0", [NSString stringWithFormat:@"%@", [NSCalendarDate  date]], nil];
					}
				}
				else
				{
					[rs close];
				}
			
				fullIndex = fullIndex + 1;
			}
		}

		NSMutableArray *_needToDelete = [NSMutableArray arrayWithCapacity:1];

		FMResultSet *_rs = [db executeQuery:@"select feedItemsID, dateAdded from feedItems", nil];

		while ([_rs next])
		{
			NSDate *_dateAdded = [_rs dateForColumn: @"dateAdded"];

			NSTimeInterval _timeOld = [[NSCalendarDate  date] timeIntervalSinceDate: _dateAdded];

			if (_timeOld > _KeepFeedsFor)
			{
				[_needToDelete addObject: [NSString stringWithFormat:@"%d", [_rs intForColumn: @"feedItemsID"]]];
			}
		}

		[_rs close];
	
		for (index = 0; index < [_needToDelete count]; index++)
		{
			[db executeUpdate:@"delete from feedItems where feedItemsID=?", [_needToDelete objectAtIndex: index], nil];
		}

		[db close];

		FoundPID = [self FindPID];

		if (FoundPID == -1)
		{
			NSString *badgeUpdateCmd = @"/Applications/RSS.app/badgeUpdate";

			system([badgeUpdateCmd UTF8String]);
		}

		[_feeds release];
		[_feed release];
		[_feedCount release];
		[_feedNames release];
		[DBFile release];
		[rs release];
		[_needToDelete release];
		[_rs release];
	}
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

		if (!strcasecmp(kp->kp_proc.p_comm,"RSS"))
		{
            FoundPID = kp->kp_proc.p_pid;
        }

		kp++;
    }

	free(process_buffer);

    return FoundPID;
}

- (pid_t) FindSBPID
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

		if (!strcasecmp(kp->kp_proc.p_comm,"SpringBoard"))
		{
            FoundPID = kp->kp_proc.p_pid;
        }

		kp++;
    }

	free(process_buffer);

    return FoundPID;
}

- (NSString*) getSettingsDIR
{
	return [[self userLibraryDirectory] stringByAppendingPathComponent: @"Preferences"];
}

- (NSString*) getSettingsPath
{
	return [[[[self getSettingsDIR] stringByAppendingPathComponent: @"MobileRSS"] stringByAppendingPathComponent: @"org.mobilestudio.mobilerss"] stringByAppendingPathExtension: @"plist"];
}

- (void) dealloc
{
	[_content release];
	[_appLibraryPath release];
	[plistDict release];
	//[_feeds release];
	[db release];
	[super dealloc];
}

@end
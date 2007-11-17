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
	NSLog(@"starting iniloop");
	if (_RefreshEvery != 0)
	{
		NSLog(@"yes we refresh");
		time_t begin = time(0);
		time_t nextRun = begin + _RefreshEvery;

		while (1)
		{
			NSLog(@"looping");
			time_t now = time(0);

			if (now >= nextRun)
			{
				NSLog(@"looped1");
				nextRun += _RefreshEvery;
				NSLog(@"looped2");
				[self refreshAllFeeds];
				NSLog(@"looped3");
			}

			NSLog(@"going to sleep");
			sleep(60);
			NSLog(@"waking up");
		}
		NSLog(@"done with loop");
	}
	NSLog(@"done with iniloop");
}

- (void) processPlistWithPath
{
	NSLog(@"process start");
	NSDictionary *FeedsDict = [self loadSettings: [self getSettingsPath]];
	NSLog(@"process 1");
	NSEnumerator *enumerator = [FeedsDict keyEnumerator];
	NSLog(@"process 2");
	NSString *currKey;
	NSDictionary *feedDict;
	NSLog(@"process 3");
	while (currKey = [enumerator nextObject])
	{
		NSLog(@"process 4");
		if ([currKey isEqualToString: @"KeepFeedsFor"])
		{
			NSLog(@"process 5");
			_KeepFeedsFor = [[FeedsDict valueForKey: currKey] intValue];
			NSLog(@"process 6");
			_KeepFeedsFor = (_KeepFeedsFor * 604800);
			NSLog(@"process 7");
		}
		else if ([currKey isEqualToString: @"RefreshEvery"])
		{
			NSLog(@"process 8");
			_RefreshEvery = [[FeedsDict valueForKey: currKey] intValue];
			NSLog(@"process 9");
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
			NSLog(@"process 10");
		}
		NSLog(@"process 11");
	}
	NSLog(@"process end");
}

- (NSDictionary*) loadSettings: (NSString*)path
{
	NSLog(@"loadsetting start");
	_settingsPath = [path retain];
	NSLog(@"loadsetting 1");
	if ([[NSFileManager defaultManager] isReadableFileAtPath: _settingsPath])
	{
		NSLog(@"loadsetting 2");
		plistDict = [NSDictionary dictionaryWithContentsOfFile: _settingsPath];
	}
	else
	{
		NSLog(@"loadsetting 3");
		plistDict = [NSDictionary dictionaryWithContentsOfFile: @"/Applications/RSS.app/Default.plist"];
	}
	NSLog(@"loadsetting end");

	return plistDict;
}

- (void) refreshAllFeeds
{
	NSLog(@"refreshall start");
	pid_t FoundPID = [self FindPID];
	NSLog(@"refreshall 1");
	if (FoundPID == -1)
	{
		NSLog(@"refreshall 2");
		_feeds = [[Feeds alloc] init];
		NSLog(@"refreshall 3");
		totalUnread = 0;

		int index;
		int i;
		int fullIndex = 0;
		NSMutableArray *_feed = [NSMutableArray arrayWithCapacity:1];
		NSMutableArray *_feedCount = [NSMutableArray arrayWithCapacity:1];
		NSMutableArray *_feedNames = [NSMutableArray arrayWithCapacity:1];
		_content = [NSMutableArray arrayWithCapacity:1];
		NSLog(@"refreshall 4");
		NSString *DBFile = @"/var/root/Library/Preferences/MobileRSS/rss.db";
		NSLog(@"refreshall 5");
		db = [FMDatabase databaseWithPath: DBFile];
		NSLog(@"refreshall 6");
		if (![db open]) {
		    NSLog(@"Could not open db.");
		}
		NSLog(@"refreshall 7");
		FMResultSet *rs = [db executeQuery:@"select feedsID, URL, position from feeds order by position", nil];
		NSLog(@"refreshall 8");
		while ([rs next])
		{
			NSLog(@"refreshall 9");
			[_feed addObject: [rs stringForColumn: @"feedsID"]];
			NSLog(@"refreshall 10");
			[_feeds initArray];
			NSLog(@"refreshall 11");
			[_feeds pullFeedURL: [rs stringForColumn: @"URL"]];
			NSLog(@"refreshall 12");
			[_content addObjectsFromArray: [_feeds returnArray]];
			NSLog(@"refreshall 13");
			[_feedCount addObject: [NSString stringWithFormat:@"%d", [[_feeds returnArray] count]]];
			NSLog(@"refreshall 14");
			[_feedNames addObject: [[[_feeds returnArray] objectAtIndex: 0] objectForKey: @"feed"]];
			NSLog(@"refreshall 15");
		}
		NSLog(@"refreshall 16");

		[rs close];
		NSLog(@"refreshall 17");

		for (i = 0; i < [_feed count]; i++)
		{
			NSLog(@"refreshall 18");
			[db executeUpdate:@"update feeds set feed=? where feedsID=?", [_feedNames objectAtIndex:i], [_feed objectAtIndex: i], nil];
			NSLog(@"refreshall 19");
			for (index = 0; index < [[_feedCount objectAtIndex: i] intValue]; index++)
			{
				NSLog(@"refreshall 20");
				NSDictionary *_item = [[_content objectAtIndex:fullIndex] retain];
				NSLog(@"refreshall 21");
				//rs = [db executeQuery:@"select feedItemsID from feedItems where feedsID = ? and itemTitle = ? and itemDate = ?", [_feed objectAtIndex: i], [_item objectForKey:@"ItemTitle"], [_item objectForKey:@"ItemDates"], nil];
				rs = [db executeQuery:@"select feedItemsID from feedItems where feedsID = ? and itemTitle = ?", [_feed objectAtIndex: i], [_item objectForKey:@"ItemTitle"], nil];
				NSLog(@"refreshall 22");
				// If not in the DB then we have a new item
				if (![rs next])
				{
					NSLog(@"refreshall 23");
					[rs close];
					NSLog(@"refreshall 24");
					if ([_item objectForKey:@"ItemTitle"] != nil)
					{
						NSLog(@"refreshall 25");
						NSDate *_itemDateConv;
						NSString *itemDateConv;
						NSLog(@"refreshall 26");
						if ([_item objectForKey:@"ItemDates"] == nil || [_item objectForKey:@"ItemDates"] == NULL)
						{
							NSLog(@"refreshall 27");
							itemDateConv = [NSCalendarDate  date];
							NSLog(@"refreshall 28");
						}
						else
						{
							NSLog(@"refreshall 29");
							_itemDateConv = [NSDate dateWithNaturalLanguageString: [_item objectForKey:@"ItemDates"]];
							NSLog(@"refreshall 30");
							itemDateConv = [_itemDateConv description];
							NSLog(@"refreshall 31");
						}
						NSLog(@"refreshall 32");
						[db executeUpdate:@"insert into feedItems (feedsID, itemTitle, itemDate, itemDateConv, itemLink, itemDescrip, hasViewed, dateAdded) values (?, ?, ?, ?, ?, ?, ?, ?)", [_feed objectAtIndex: i], [_item objectForKey:@"ItemTitle"], [_item objectForKey:@"ItemDates"], itemDateConv, [_item objectForKey:@"ItemLinks"], [_item objectForKey:@"ItemDesc"], @"0", [NSCalendarDate  date], nil];
						NSLog(@"refreshall 33");
					}
					NSLog(@"refreshall 34");
				}
				else
				{
					NSLog(@"refreshall 35");
					[rs close];
					NSLog(@"refreshall 36");
				}
				NSLog(@"refreshall 37");
			
				fullIndex = fullIndex + 1;
				NSLog(@"refreshall 38");
			}
			NSLog(@"refreshall 39");
		}
		NSLog(@"refreshall 40");

		NSMutableArray *_needToDelete = [NSMutableArray arrayWithCapacity:1];
		NSLog(@"refreshall 41");
		FMResultSet *_rs = [db executeQuery:@"select feedItemsID, dateAdded from feedItems", nil];
		NSLog(@"refreshall 42");
		while ([_rs next])
		{
			NSLog(@"refreshall 43");
			NSDate *_dateAdded = [_rs dateForColumn: @"dateAdded"];
			NSLog(@"refreshall 44");
			NSTimeInterval _timeOld = [[NSCalendarDate date] timeIntervalSinceDate: _dateAdded];
			NSLog(@"refreshall 45");
			if (_timeOld > _KeepFeedsFor)
			{
				NSLog(@"refreshall 46");
				[_needToDelete addObject: [NSString stringWithFormat:@"%d", [_rs intForColumn: @"feedItemsID"]]];
				NSLog(@"refreshall 47");
			}
			NSLog(@"refreshall 48");
		}
		NSLog(@"refreshall 49");

		[_rs close];
		NSLog(@"refreshall 50");
		for (index = 0; index < [_needToDelete count]; index++)
		{
			NSLog(@"refreshall 51");
			[db executeUpdate:@"delete from feedItems where feedItemsID=?", [_needToDelete objectAtIndex: index], nil];
			NSLog(@"refreshall 52");
		}
		NSLog(@"refreshall 53");
		[db close];
		NSLog(@"refreshall 54");
		FoundPID = [self FindPID];
		NSLog(@"refreshall 55");
		if (FoundPID == -1)
		{
			NSLog(@"refreshall 56");
			NSString *badgeUpdateCmd = @"/Applications/RSS.app/badgeUpdate";
			NSLog(@"refreshall 57");
			system([badgeUpdateCmd UTF8String]);
			NSLog(@"refreshall 58");
		}
		NSLog(@"refreshall 59");
		[_feeds release];
		NSLog(@"refreshall 60");
		[_feed release];
		NSLog(@"refreshall 61");
		[_feedCount release];
		NSLog(@"refreshall 62");
		[_feedNames release];
		NSLog(@"refreshall 63");
		[DBFile release];
		NSLog(@"refreshall 64");
		[rs release];
		NSLog(@"refreshall 65");
		[_needToDelete release];
		NSLog(@"refreshall 66");
		[_rs release];
		NSLog(@"refreshall 67");
	}
	NSLog(@"refreshall 68");
}

- (pid_t) FindPID
{
	NSLog(@"findpid start");
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
	NSLog(@"findpid end");

    return FoundPID;
}

- (pid_t) FindSBPID
{
	NSLog(@"findsbpid start");
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
	NSLog(@"findsbpid end");
    return FoundPID;
}

- (NSString*) getSettingsDIR
{
	NSLog(@"getsettingsdir");
	return [[self userLibraryDirectory] stringByAppendingPathComponent: @"Preferences"];
}

- (NSString*) getSettingsPath
{
	NSLog(@"getsettingspath");
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
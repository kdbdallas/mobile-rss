#import "badgeUpdate.h"

static NSRecursiveLock *lock;

@implementation badgeUpdate

- (void) applicationDidFinishLaunching: (id) unused
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

	FMResultSet *_rs = [db executeQuery:@"select count(itemTitle) as unread from feedItems where hasViewed=?", @"0", nil];

	[_rs next];

	if ([_rs intForColumn: @"unread"] > 0)
	{
		int totalUnread = [_rs intForColumn: @"unread"];

		[self clearAppBadge];
		[self updateAppBadge: [NSString stringWithFormat:@"%d", totalUnread]];
	}
	else
	{
		[self clearAppBadge];
	}

	[_rs close];
	
	[db close];

	[_rs release];
	
	exit(0);
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

- (void) dealloc
{
	[db release];
	[super dealloc];
}

@end
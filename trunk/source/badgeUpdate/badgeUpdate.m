#import "badgeUpdate.h"

static NSRecursiveLock *lock;

@implementation badgeUpdate

- (void) applicationDidFinishLaunching: (id) unused
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
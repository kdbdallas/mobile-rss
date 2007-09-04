#import "SettingsView.h"

@implementation SettingsView

- (id) initWithFrame: (struct CGRect)rect withSettingsPath: (NSString*)settingsPath
{
	//Init view with frame rect
	[super initWithFrame: rect];
	
	_settingsPath = settingsPath;
	
	feedInputs = [[NSMutableArray alloc] initWithCapacity: 1];

	_prefsTable = [[UIPreferencesTable alloc] initWithFrame: rect];
	[_prefsTable setDataSource: self];
    [_prefsTable setDelegate: self];
	[_prefsTable reloadData];
	[_prefsTable setBottomBufferHeight:44.0f];
	
	_prefsHeader = [[UIPreferencesTableCell alloc] init];
	[_prefsHeader setTitle: @"RSS Settings"];
	[_prefsHeader setIcon: [UIImage applicationImageNamed: @"icon_small.png"]];
	
	[self addSubview: _prefsTable];
	
	return self;
}

- (NSDictionary*)loadSettings: (NSString*)settingsPath
{
	_settingsPath = settingsPath;
	
	if ([[NSFileManager defaultManager] isReadableFileAtPath: settingsPath])
	{
		plistDict = [NSDictionary dictionaryWithContentsOfFile: settingsPath];
	}
	else
	{
		plistDict = [NSDictionary dictionaryWithContentsOfFile: @"/Applications/RSS.app/Default.plist"];
	}
	
	return plistDict;
}

- (void) readSettings: (NSString*)settingsPath
{
	int index;
	
	_settingsPath = settingsPath;
	
	//Read in settings to replace defaults
	if ([[NSFileManager defaultManager] isReadableFileAtPath: settingsPath])
	{
		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile: settingsPath];
		NSEnumerator *enumerator = [settingsDict keyEnumerator];
		NSString *currKey;
		
		while (currKey = [enumerator nextObject])
		{
			if ([currKey isEqualToString: @"Feeds"])
			{
				NSArray *feedArray = [settingsDict objectForKey: currKey];

				for (index = 0; index < [feedArray count]; index++)
				{
					NSDictionary *feedsDict = [feedArray objectAtIndex: index];
					
					UIPreferencesTextTableCell *_prefsFeed = [[[UIPreferencesTextTableCell alloc] init] retain];
					[_prefsFeed setTitle: @"Feed"];
					[[_prefsFeed textField] setText: [feedsDict objectForKey: @"URL"]];
					[_prefsFeed createRemoveControl];

					[feedInputs addObject: _prefsFeed];
				}
			}
		}
	}

	[_prefsTable reloadData];
}

- (void) writeSettings: (NSString*)settingsPath
{
	NSString *error;

	NSMutableDictionary *settingsDict = [[NSMutableDictionary alloc] initWithCapacity: 1];

	int row;
	int index;
	int rowCount;
	NSString *tmpValue;
	
	NSMutableArray *feedArray = [[NSMutableArray alloc] initWithCapacity: 1];
	
	rowCount = [feedInputs count];
	NSLog([NSString stringWithFormat:@"%d", rowCount]);

	//Build settings dictionary
	for(index = 0; index < rowCount; index++) {
		tmpValue = [[[feedInputs objectAtIndex: index] textField] text];

		NSMutableDictionary *indFeedDict = [[NSMutableDictionary alloc] initWithCapacity: 1];
		
		[indFeedDict setObject:tmpValue forKey: @"Title"];
		[indFeedDict setObject:tmpValue forKey: @"URL"];
		[indFeedDict setObject:@"0" forKey: @"Update"];
		
		[feedArray addObject: indFeedDict];
	}
	
	[settingsDict setObject:feedArray forKey: @"Feeds"];
	
	//NSLog(@"%@", settingsDict);
	
	//Seralize settings dictionary
	NSData *rawPList = [NSPropertyListSerialization dataFromPropertyList: settingsDict format: NSPropertyListXMLFormat_v1_0 errorDescription: &error];
	
	NSLog(error);
	
	//Write settings plist file
	settingsPath = [_delegate getSettingsPath];

	[rawPList writeToFile: settingsPath atomically: YES];
	
	[_delegate hideSettingsView];
}

- (void) addFeed
{
	UIPreferencesTextTableCell *_prefsFeed = [[[UIPreferencesTextTableCell alloc] init] retain];
	[_prefsFeed setTitle: @"Feed"];
	[[_prefsFeed textField] setText: @""];
	[_prefsFeed setEnableReordering:YES animated:YES];
	[feedInputs addObject: _prefsFeed];
	
	[_prefsTable reloadData];
}

- (void) removeFeed
{
	[_prefsTable enableRowDeletion:YES animated:YES];
	[_prefsTable reloadData];
}

- (void) saveFeeds
{
	[self writeSettings:_settingsPath];
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
	[_prefsTable release];
	[_prefsHeader release];
	[plistDict release];
	
	[super dealloc];
}

- (void)tableSelectionDidChange:(int)row {
	_rowSelected = row;
}

- (void)scrollerDidEndDragging:(id)fp8
{
	[_prefsTable setKeyboardVisible:NO animated:YES];
}

- (void) table:(UITable *) table deleteRow:(int) row {
	row = row - 2;
	[feedInputs removeObjectAtIndex:row];
	[_prefsTable reloadData];
}

- (BOOL) table:(UITable *) table canDeleteRow:(int) row {
	return YES;
}

- (BOOL) table:(UITable *) table canMoveRow:(int) row {
	return YES;
}

// Start of Preference required methods
- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable*)table 
{
	return 2;
}

- (int) preferencesTable: (UIPreferencesTable*)table numberOfRowsInGroup: (int)group 
{
    switch (group) 
	{ 
        case 0: return 0;
		case 1: return [feedInputs count];
		default: return 0;
    }
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForGroup: (int)group 
{
	switch (group)
	{
		case 0: return _prefsHeader;
		case 1: return _prefsHeader;
		default: return nil;
	}
}

- (BOOL) preferencesTable: (UIPreferencesTable*)table isLabelGroup: (int)group 
{
    switch (group)
	{
		case 0: return TRUE;
		case 1: return FALSE;
		default: return TRUE;
	}
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForRow: (int)row inGroup: (int)group 
{
	switch (group)
	{
		case 0: return _prefsHeader;
		case 1: return [[feedInputs objectAtIndex:row] retain];
		default: return nil;
	}
}

- (float) preferencesTable: (UIPreferencesTable*)table heightForRow: (int)row inGroup: (int)group withProposedHeight: (float)proposed 
{
	float groupLabelBuffer = 24.0f;
	
	switch (group)
	{
		case 0: return proposed + groupLabelBuffer;
		default: return proposed;
	}
}
// End of Preferences required modules

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
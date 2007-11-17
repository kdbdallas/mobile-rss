#import "QuickAdd.h"

@implementation QuickAdd

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
	
	_Table = [[UIPreferencesTable alloc] initWithFrame: CGRectMake(0.0f, 40.0f, 320.0f, rect.size.height - 40.0f)];
	[_Table setDataSource: self];
    [_Table setDelegate: self];

	[self addSubview: _Table];
	
	quickAdds = [[[NSMutableArray alloc] initWithCapacity: 1] retain];
	
	_DiggFeed = [[[UIPreferencesTableCell alloc] init] retain];
	UIImage *diggImage = [UIImage applicationImageNamed:@"feedIcons/digg.png"];
	UIImageView *diggImageView = [[UIImageView alloc] initWithImage:diggImage];
	[diggImageView setFrame: CGRectMake(((320.0f - 81.0f) / 2.0f), 5.0f, 81.0f, 50)];
	[_DiggFeed addSubview: diggImageView];

	[quickAdds addObject: @"http://digg.com/rss/index.xml"];

	_EngadgetFeed = [[[UIPreferencesTableCell alloc] init] retain];
	UIImage *engadgetImage = [UIImage applicationImageNamed:@"feedIcons/engadget.png"];
	UIImageView *engadgetImageView = [[UIImageView alloc] initWithImage:engadgetImage];
	[engadgetImageView setFrame: CGRectMake(((320.0f - 186.0f) / 2.0f), 5.0f, 186.0f, 50)];
	[_EngadgetFeed addSubview: engadgetImageView];

	[quickAdds addObject: @"http://feeds.engadget.com/weblogsinc/engadget"];
	
	_SlashdotFeed = [[[UIPreferencesTableCell alloc] init] retain];
	UIImage *slashdotImage = [UIImage applicationImageNamed:@"feedIcons/slashdot.png"];
	UIImageView *slashdotImageView = [[UIImageView alloc] initWithImage:slashdotImage];
	[slashdotImageView setFrame: CGRectMake(((320.0f - 200.0f) / 2.0f), 5.0f, 200.0f, 49)];
	[_SlashdotFeed addSubview: slashdotImageView];

	[quickAdds addObject: @"http://rss.slashdot.org/Slashdot/slashdot"];
	
	_YahooFeed = [[[UIPreferencesTableCell alloc] init] retain];
	UIImage *yahooImage = [UIImage applicationImageNamed:@"feedIcons/yahoo.png"];
	UIImageView *yahooImageView = [[UIImageView alloc] initWithImage:yahooImage];
	[yahooImageView setFrame: CGRectMake(((320.0f - 144.0f) / 2.0f), 18.0f, 144.0f, 33)];
	[_YahooFeed addSubview: yahooImageView];

	[quickAdds addObject: @"http://rss.news.yahoo.com/rss/topstories"];
	
	_AppleFeed = [[[UIPreferencesTableCell alloc] init] retain];
	UIImage *appleImage = [UIImage applicationImageNamed:@"feedIcons/apple.png"];
	UIImageView *appleImageView = [[UIImageView alloc] initWithImage:appleImage];
	[appleImageView setFrame: CGRectMake(((320.0f - 42.0f) / 2.0f), 5.0f, 42.0f, 50)];
	[_AppleFeed addSubview: appleImageView];

	[quickAdds addObject: @"http://images.apple.com/main/rss/hotnews/hotnews.rss"];

	[_Table reloadData];

	return self;
}

- (void) reloadTable
{
	[_Table reloadData];
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

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	[_delegate hideQuickAdd];
}

- (void)tableSelectionDidChange:(int)row
{
	row = [_Table selectedRow];

	[_delegate quickAdd: [quickAdds objectAtIndex: (row - 1)]];

	[_delegate hideQuickAdd];
}

// Start of Preference required methods
- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable*)table 
{
	return 1;
}

- (int) preferencesTable: (UIPreferencesTable*)table numberOfRowsInGroup: (int)group 
{
    switch (group) 
	{ 
        case 0: return 5;
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
		default: return FALSE;
	}
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForRow: (int)row inGroup: (int)group 
{
	switch (row)
	{
		case 0: return _DiggFeed;
		case 1: return _EngadgetFeed;
		case 2: return _SlashdotFeed;
		case 3: return _YahooFeed;
		case 4: return _AppleFeed;
		default: return nil;
	}
}

- (float) preferencesTable: (UIPreferencesTable*)table heightForRow: (int)row inGroup: (int)group withProposedHeight: (float)proposed 
{
	float groupLabelBuffer = 60.0f;
	
	switch (group)
	{
		case 0: return groupLabelBuffer;
		default: return 0.0f;
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
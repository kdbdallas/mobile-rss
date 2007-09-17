#import "RSS.h"

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

	mainView = [[UIView alloc] initWithFrame: rect];
	
	// Setup for later use. We setup here so any "early" calls dont die
	feedsAndItems = [[[NSMutableDictionary alloc] initWithCapacity: 1] retain];

	// Add main view to the main window
	[window setContentView: mainView]; 

	// Transition view
	transitionView = [[UITransitionView alloc] initWithFrame:rect];
	[mainView addSubview:transitionView];
	
	// Setup Settings View
	_settingsView = [[[SettingsView alloc] initWithFrame:rect withSettingsPath: [self getSettingsPath]] retain];
	[_settingsView setDelegate: self];
	
	// Settings Toolbar
	toolBar *_toolbar = [[[toolBar alloc] initWithFrame:CGRectMake(0.0f, contentRect.size.height - 44.0f, contentRect.size.width, 44.0f)] retain];
	[_toolbar setDelegate:_settingsView];
	
	[_settingsView addSubview:_toolbar];
	
	// Main view Nav Bar
	navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 30.0f)];
    [navBar setBarStyle: 3];
	[navBar setDelegate: self];
	[navBar setPrompt: @"Mobile RSS"];

	// Image for settings
	UIImage *btnImage = [UIImage applicationImageNamed:@"info_icon.png"];
	
	// Make the settings image into a btn 
	UIPushButton *pushButton = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
	[pushButton setFrame: CGRectMake(0.0, 0.0, 50.0, 30.0)];
	[pushButton setDrawsShadow: NO];
	[pushButton setEnabled:YES];
	[pushButton drawImageAtPoint: CGPointMake(20.0, 0) fraction: 0.0];
	[pushButton setStretchBackground:NO];
	[pushButton setBackground:btnImage forState:0];  //up state
	[pushButton addTarget: self action: @selector(showSettings) forEvents: 1];
	[navBar addSubview: pushButton];

	// Add Nav Bar with Settings Btn to the main view
	[mainView addSubview: navBar];

	// Table to show feed items
	_viewTable = [[UITable alloc] initWithFrame: CGRectMake(0.0f, 30.0f, 320.0f, rect.size.height - 30.0f)];
	[_viewTable setSeparatorStyle: 1];
	[_viewTable setDelegate: self];
	[_viewTable setDataSource: self];
	[_viewTable setRowHeight: 36.0f];

	// Col for the table that shows feeds items
	_viewTableCol = [[UITableColumn alloc] initWithTitle: @"Feed Items" identifier:@"items" width: rect.size.width];
	
	// Put the Col into the Table
	[_viewTable addTableColumn: _viewTableCol];

	// Set the main view as the current view
	[window setContentView: mainView];
	
	// Add the table into the main view
	[mainView addSubview:_viewTable];
	
	// Setup Eye Candy View
	_eyeCandy = [[[EyeCandy alloc] init] retain];
	[_eyeCandy showProgressHUD:@"Loading..." withWindow:window withView:mainView withRect:CGRectMake(0.0f, 100.0f, 320.0f, 50.0f)];

	[NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(processPlistWithPath:) userInfo:nil repeats:NO];
}

- (void) processPlistWithPath:(id)param
{
	NSDictionary *FeedsDict = [_settingsView loadSettings: [self getSettingsPath]];
	NSEnumerator *enumerator = [FeedsDict keyEnumerator];
	NSEnumerator *feedListEnum;
	NSString *currKey;
	NSArray *feedList;
	NSDictionary *feedDict;

	_feeds = [[Feeds alloc] init];
	[_feeds initArray];

	while (currKey = [enumerator nextObject])
	{
		// Should only not be this if the file is invalid
		if ([currKey isEqualToString: @"Feeds"])
		{
			// Feeds key is value is an Array of actual feed dictionarys
			feedList = [FeedsDict valueForKey: currKey];
			feedListEnum = [feedList objectEnumerator];

			while (feedDict = [feedListEnum nextObject])
			{
				NSLog([feedDict valueForKey: @"URL"]);

				[_feeds pullFeedURL: [feedDict valueForKey: @"URL"]];
			}
		}
		else
		{
			[_eyeCandy showStandardAlertWithString: @"An Error Occurred" closeBtnTitle: @"Close" withError: @"Invalid Feed plist"];
		}
	}
	
	_content = [NSMutableArray arrayWithCapacity:1];
	
	[_content addObjectsFromArray: [_feeds returnArray]];

	[_viewTable reloadData];
	[_eyeCandy hideProgressHUD];
}

- (UIWindow*) getWindow
{
	return window;
}

- (void) addItem:(NSMutableDictionary *)item
{
	[_content addObject: item];
}

- (int) countAllItems
{
	int counter = 0;
	
	counter = [[_content retain] count];

	return counter;
}

- (NSString*) getSettingsPath
{
	return [[[[self userLibraryDirectory] stringByAppendingPathComponent: @"Preferences"] stringByAppendingPathComponent: @"com.google.code.mobile-rss"] stringByAppendingPathExtension: @"plist"];
}

- (void) showSettings
{
	//Switch views
	[transitionView transition:6 fromView:mainView toView:_settingsView];

	[window setContentView: _settingsView];
	[_settingsView readSettings: [self getSettingsPath]];
}

- (void) hideSettingsView
{
	[_settingsView addSubview:transitionView];
	[transitionView transition:2 fromView:_settingsView toView:mainView];
	[window setContentView: mainView];
	
	[_settingsView removeFromSuperview];
	[self applicationDidFinishLaunching:nil];
}

- (void) hideItemView
{
	[_itemViewView addSubview:transitionView];
	[transitionView transition:2 fromView:_itemViewView toView:mainView];
	[window setContentView: mainView];
	[_viewTable reloadData];
}

- (void) showItem:(int)row fromView:(NSString*)fView {
	NSDictionary *_item = [[_content objectAtIndex:row] retain];
	NSString *_value = [_item objectForKey:@"ItemTitle"];

	if ([fView isEqualToString:@"itemView"] && [_value length] == 0)
	{
		row = row + 1;

		_item = [[_content objectAtIndex:row] retain];
		_value = [_item objectForKey:@"ItemTitle"];
	}

	if ([_value length] != 0)
	{
		// Setup ItemView View
		struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
		rect.origin.x = rect.origin.y = 0.0f;

		_itemViewView = [[ItemView alloc] initWithFrame:rect withItem: [[_content objectAtIndex:row] retain] withRow: row];
		[_itemViewView setDelegate: self];

		int transType;

		//Switch views
		if ([fView isEqualToString:@"itemView"])
		{
			transType = 7;
		}
		else
		{
			transType = 1;
		}
	
		[transitionView transition:transType fromView:mainView toView:_itemViewView];

		[window setContentView: _itemViewView];
	}
}

- (void) dealloc
{
	[transitionView release];
	[_eyeCandy release];
	[settingsPath release];
	[_settingsView release];
	[_itemViewView release];
	[_content release];
	[_viewTable release];
	[navBar release];
	[mainView release];
	[window release];
	[super dealloc];
}

// Start of UITable required methods
- (int)numberOfRowsInTable:(UITable *)table {
	int numRows = [self countAllItems];

	return numRows;
}

- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col {	
	UIImageAndTextTableCell *cell = [[UIImageAndTextTableCell alloc] init];

	NSDictionary *_item = [[_content objectAtIndex:row] retain];
	NSString *_value = [_item objectForKey:@"ItemTitle"];

	if ([_value length] == 0)
	{
		[cell setTitle: [_item objectForKey:@"feed"]];
		[cell setImage: [UIImage applicationImageNamed:@"icon-tiny.png"]];
	}
	else
	{
		[cell setTitle: _value];
		[cell setShowDisclosure: YES];
		[cell setDisclosureClickable: YES];
	}
	
	return cell;
}

- (BOOL)table:(UITable *)aTable canSelectRow:(int)row {
	[self showItem: row fromView: @"mainView"];

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
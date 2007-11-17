#import "Settings.h"

@implementation Settings

- (id) initWithFrame: (struct CGRect)rect withSettingsPath: (NSString*)settingsPath
{
	//Init view with frame rect
	[super initWithFrame: rect];

	_isSelecting = NO;
	_settingsPath = [settingsPath retain];
	storedRefresh = 0;
	storedFont = 10;
	
	// Transition view
	transitionView = [[UITransitionView alloc] initWithFrame:rect];
	[self addSubview:transitionView];

	navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 40.0f)];
	[navBar showButtonsWithLeftTitle: @"Cancel" rightTitle:@"Save" leftBack: FALSE];
    [navBar setBarStyle: 3];
	[navBar enableAnimation];
	[navBar setDelegate: self];
	[self addSubview: navBar];

	UITextLabel *_title = [[UITextLabel alloc] initWithFrame: CGRectMake(130.0f, 9.0f, 140.0f, 20.0f)];
	[_title setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:14]];
	[_title setText: @"Settings"];
	[_title setBackgroundColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:0.0f]];
	[_title setColor: [UIView colorWithRed:52.0f green:154.0f blue:243.0f alpha:1.0f]];
	[_title setWrapsText: NO];
	
	[self addSubview: _title];

	_prefsTable = [[UIPreferencesTable alloc] initWithFrame: CGRectMake(0.0f, 40.0f, 320.0f, rect.size.height - 40.0f)];
	[_prefsTable setDataSource: self];
    [_prefsTable setDelegate: self];
	[_prefsTable reloadData];

	[self addSubview: _prefsTable];
	
	_manageFeeds = [[[UIPreferencesTableCell alloc] init] retain];
	[_manageFeeds setTitle: @"Manage Feeds and Ordering"];
	[_manageFeeds setShowDisclosure: YES];
	[_manageFeeds setDisclosureClickable: YES];
	[_manageFeeds setDisclosureStyle: 1];

	_importFeeds = [[[UIPreferencesTableCell alloc] init] retain];
	[_importFeeds setTitle: @"Import Feeds"];
	[_importFeeds setShowDisclosure: YES];
	[_importFeeds setDisclosureClickable: YES];
	[_importFeeds setDisclosureStyle: 1];

	CGRect sliderRect = CGRectMake(20.0f, 8.0f, 296.0f - 20.0f, 32.0f);

	_keepForTitleCell = [[UIPreferencesTableCell alloc] init];
	[_keepForTitleCell setTitle: @"Keep Feed Items for (in Weeks)"];

	_keepForCell = [[UIPreferencesTableCell alloc] init];
	_keepForSlider = [[UISliderControl alloc] initWithFrame: sliderRect];
	[_keepForSlider setMinValue: 1];
	[_keepForSlider setMaxValue: 100];
	[_keepForSlider setShowValue: TRUE];
	[_keepForCell addSubview: _keepForSlider];

	// 7 == Mouse Dragged
	[_keepForSlider addTarget:self action:@selector(handleSlider:) forEvents:7];

	_chooseFontCell = [[UIPreferencesTableCell alloc] init];
	[_chooseFontCell setTitle: @"Font"];
	[_chooseFontCell setShowDisclosure: YES];
	[_chooseFontCell setDisclosureClickable: YES];
	[_chooseFontCell setDisclosureStyle: 1];

	sliderRect = CGRectMake(100.0f, 8.0f, 196.0f, 32.0f);

	_fontSizeCell = [[UIPreferencesTableCell alloc] init];
	[_fontSizeCell setTitle: @"Font Size"];
	_fontSizeSlider = [[UISliderControl alloc] initWithFrame: sliderRect];
	[_fontSizeSlider setMinValue: 10];
	[_fontSizeSlider setMaxValue: 50];
	[_fontSizeSlider setShowValue: TRUE];
	[_fontSizeCell addSubview: _fontSizeSlider];

	fontChooser = [[UIPickerView alloc] initWithFrame: CGRectMake(0.0f, rect.size.height - 200.0f, 320.0f, 200.0f)];
	[fontChooser setDelegate: self];
	[fontChooser setSoundsEnabled: TRUE];

	_refreshEveryCell = [[UIPreferencesTableCell alloc] init];
	[_refreshEveryCell setTitle: @"Refresh Interval"];
	[_refreshEveryCell setShowDisclosure: YES];
	[_refreshEveryCell setDisclosureClickable: YES];
	[_refreshEveryCell setDisclosureStyle: 1];

	refreshPicker = [[UIPickerView alloc] initWithFrame: CGRectMake(0.0f, rect.size.height - 200.0f, 320.0f, 200.0f)];
	[refreshPicker setDelegate: self];
	[refreshPicker setSoundsEnabled: TRUE];

	_table = [refreshPicker createTableWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 200.0f)];
	[_table setAllowsMultipleSelection: FALSE];

	_pickerCol = [[UITableColumn alloc] initWithTitle: @"Refresh" identifier:@"refresh" width: rect.size.width];

	[refreshPicker columnForTable: _pickerCol];

	UIImage *btnImage = [UIImage applicationImageNamed:@"paypal.png"];

	UIPushButton *pushButton = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
	[pushButton setFrame: CGRectMake(129.0, 420.0f, 62.0, 31.0)];
	[pushButton setDrawsShadow: YES];
	[pushButton setEnabled:YES];
	[pushButton setStretchBackground:NO];
	[pushButton setBackground:btnImage forState:0];  //up state
	[pushButton addTarget: self action: @selector(donate) forEvents: 1];
	
	[self addSubview: pushButton];

	return self;
}

- (void) donate
{
	[_delegate openURL: [NSURL URLWithString: @"https://www.paypal.com/cgi-bin/webscr?cmd=_xclick&business=dbrown%40port21%2ecom&item_name=Mobile%20RSS&buyer_credit_promo_code=&buyer_credit_product_category=&buyer_credit_shipping_method=&buyer_credit_user_address_change=&no_shipping=0&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8"]];
}

- (void) handleSlider: (id) slider
{
	int result = (int)round([_keepForSlider value]);

   	[_keepForSlider setValue:result];
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

- (void) readSettings: (NSString*)path
{
	_settingsPath = [path retain];
	
	NSDictionary *settingsDict;

	if ([[NSFileManager defaultManager] isReadableFileAtPath: [_settingsPath retain]])
	{
		settingsDict = [NSDictionary dictionaryWithContentsOfFile: [_settingsPath retain]];
	}
	else
	{
		settingsDict = [NSDictionary dictionaryWithContentsOfFile: @"/Applications/RSS.app/Default.plist"];
	}
	
	NSEnumerator *enumerator = [settingsDict keyEnumerator];
	NSString *currKey;
	
	while (currKey = [enumerator nextObject])
	{
		if ([currKey isEqualToString: @"RefreshEvery"])
		{
			storedRefresh = [[settingsDict objectForKey: currKey] intValue];
		}

		if ([currKey isEqualToString: @"KeepFeedsFor"])
		{
			[self setKeepFor: [[settingsDict objectForKey: currKey] intValue]];
		}

		if ([currKey isEqualToString: @"Font"])
		{
			storedFont = [[settingsDict objectForKey: currKey] intValue];
		}

		if ([currKey isEqualToString: @"FontSize"])
		{
			[self setFontSize: [[settingsDict objectForKey: currKey] intValue]];
		}
	}

	[_prefsTable reloadData];
}

- (void) saveSettings
{
	NSString *error;
	NSString *tmpString;

	NSMutableDictionary *settingsDict = [[NSMutableDictionary alloc] initWithCapacity: 1];

	tmpString = [NSString stringWithFormat:@"%d", storedRefresh];
	[settingsDict setObject:tmpString forKey: @"RefreshEvery"];

	tmpString = [NSString stringWithFormat:@"%d", (int)[_keepForSlider value]];
	[settingsDict setObject:tmpString forKey: @"KeepFeedsFor"];

	tmpString = [NSString stringWithFormat:@"%d", storedFont];
	[settingsDict setObject:tmpString forKey: @"Font"];

	tmpString = [NSString stringWithFormat:@"%d", (int)[_fontSizeSlider value]];
	[settingsDict setObject:tmpString forKey: @"FontSize"];

	//Seralize settings dictionary
	NSData *rawPList = [NSPropertyListSerialization dataFromPropertyList: settingsDict format: NSPropertyListXMLFormat_v1_0 errorDescription: &error];

	//Write settings plist file
	[rawPList writeToFile: [_settingsPath retain] atomically: YES];

	[_delegate hideSettingsView];
}

- (void) setFontSize: (int)value
{
	[_fontSizeSlider setValue: (float)value];
}

- (void) setKeepFor: (int)value
{
	[_keepForSlider setValue: (float)value];
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	switch (button)
	{
		case 0:
			[self saveSettings];
		break;

		case 1:
			[_delegate hideSettingsView];
		break;
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

- (NSString*) getSettingsDIR
{
	return [_delegate getSettingsDIR];
}

- (UIWindow*) getWindow
{
	return [_delegate getWindow];
}

- (void) dealloc
{
	[_prefsTable release];
	[_keepForCell release];
	[_keepForSlider release];

	[super dealloc];
}

- (void)tableSelectionDidChange:(int)row {
	struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;

	row = [_prefsTable selectedRow];

	switch (row)
	{
		case 1:
			// Feed List View
			_FeedListView = [[[FeedList alloc] initWithFrame:rect withSettingsPath: [_settingsPath retain]] retain];
			[_FeedListView setDelegate: self];

			[transitionView transition:6 fromView:self toView:_FeedListView];

			[[_delegate getWindow] setContentView: _FeedListView];
			[_FeedListView loadSettings];
		break;
		
		case 2:
			// Import View
			_ImportView = [[[Import alloc] initWithFrame: rect] retain];
			[_ImportView setDelegate: self];

			[transitionView transition:6 fromView:self toView:_ImportView];

			[[_delegate getWindow] setContentView: _ImportView];
		break;

		case 7:
			_isSelecting = YES;
			[self addSubview: fontChooser];

			[fontChooser reloadData];
		break;

		case 10:
			_isSelecting = YES;
			[self addSubview: refreshPicker];

			[refreshPicker reloadData];
		break;
	}
}

- (void) hideFeedList
{
	[_manageFeeds setSelected: NO withFade: NO];

	[_FeedListView addSubview:transitionView];

	[transitionView transition:6 fromView:_FeedListView toView:self];

	[[_delegate getWindow] setContentView: self];
	[_FeedListView removeFromSuperview];

	[_FeedListView release];

	[_manageFeeds setEnabled: YES];
	[_prefsTable selectRow: -1 byExtendingSelection: NO withFade: YES];
}

- (void) hideImport
{
	[_importFeeds setSelected: NO withFade: NO];

	[_ImportView addSubview:transitionView];

	[transitionView transition:6 fromView:_ImportView toView:self];

	[[_delegate getWindow] setContentView: self];
	[_ImportView removeFromSuperview];

	[_ImportView release];

	[_importFeeds setEnabled: YES];
	[_prefsTable selectRow: -1 byExtendingSelection: NO withFade: YES];
}

// Start of Preference required methods
- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable*)table 
{
	return 5;
}

- (int) preferencesTable: (UIPreferencesTable*)table numberOfRowsInGroup: (int)group 
{
    switch (group)
	{
		case 0: return 2;
		case 1: return 0;
		case 2: return 1;
		case 3: return 2;
		case 4: return 1;
		default: return 0;
    }
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForGroup: (int)group 
{
	switch (group)
	{
		case 0: return nil;
		case 1: return _keepForTitleCell;
		case 2: return _keepForTitleCell;
		case 3: return nil;
		case 4: return nil;
		default: return nil;
	}
}

- (BOOL) preferencesTable: (UIPreferencesTable*)table isLabelGroup: (int)group 
{
    switch (group)
	{
		case 0: return FALSE;
		case 1: return TRUE;
		case 2: return FALSE;
		case 3: return FALSE;
		case 4: return FALSE;
		default: return TRUE;
	}
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForRow: (int)row inGroup: (int)group 
{
	switch (group)
	{
		case 0: 
			if (row == 0)
			{
				return _manageFeeds;
			}
			else
			{
				return _importFeeds;
			}
		break;
		case 1: return _keepForTitleCell;
		case 2: return _keepForCell;
		case 3:
			if (row == 0)
			{
				return _chooseFontCell;
			}
			else
			{
				return _fontSizeCell;
			}
		break;
		case 4: return _refreshEveryCell;
		default: return nil;
	}
}

- (float) preferencesTable: (UIPreferencesTable*)table heightForRow: (int)row inGroup: (int)group withProposedHeight: (float)proposed 
{
	float groupLabelBuffer = 24.0f;
	
	switch (group)
	{
		case 1: return proposed + groupLabelBuffer;
		default: return proposed;
	}
}
// End of Preferences required modules

- (void) pickerView:(UIPickerView*)picker row:(int)row column:(int)col checked:(BOOL)checked
{
	if (_isSelecting)
	{
		[_prefsTable selectRow: -1 byExtendingSelection: NO withFade: NO];

		if (picker == fontChooser)
		{
			storedFont = row;
			[fontChooser removeFromSuperview];
			[_prefsTable selectRow: -1 byExtendingSelection: NO withFade: YES];
		}
		else
		{
			storedRefresh = row;
			[refreshPicker removeFromSuperview];
			[_prefsTable selectRow: -1 byExtendingSelection: NO withFade: YES];
		}

		_isSelecting = NO;
	}
}

- (void)scrollerDidEndDragging:(id)fp8
{
	if (_isSelecting)
	{
		[_prefsTable selectRow: -1 byExtendingSelection: NO withFade: NO];

		[fontChooser removeFromSuperview];
		[refreshPicker removeFromSuperview];
		[_prefsTable selectRow: -1 byExtendingSelection: NO withFade: YES];

		_isSelecting = NO;
	}
}

- (int) numberOfColumnsInPickerView:(UIPickerView*)picker
{
	return 1;
}

- (int) pickerView:(UIPickerView*)picker numberOfRowsInColumn:(int)col
{
	if (picker == fontChooser)
	{
		return 18;
	}
	else
	{
		return 16;
	}
}

- (UIPickerTableCell*) pickerView:(UIPickerView*)picker tableCellForRow:(int)row inColumn:(int)col
{
	UIPickerTableCell *cell = [[[UIPickerTableCell alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 32.0f)] autorelease];

	if (picker == fontChooser)
	{
		switch (row)
		{
			case 0: [cell setTitle: @".Helvetica LT MM"]; break;
			case 1: [cell setTitle: @".Times LT MM"]; break;
			case 2: [cell setTitle: @"American Typewriter"]; break;
			case 3: [cell setTitle: @"Arial"]; break;
			case 4: [cell setTitle: @"Arial Rounded MT Bold"]; break;
			case 5: [cell setTitle: @"Arial Unicode MS"]; break;
			case 6: [cell setTitle: @"Courier"]; break;
			case 7: [cell setTitle: @"Courier New"]; break;
			case 8: [cell setTitle: @"DB LCD Temp"]; break;
			case 9: [cell setTitle: @"Georgia"]; break;
			case 10: [cell setTitle: @"Helvetica"]; break;
			case 11: [cell setTitle: @"Lock Clock"]; break;
			case 12: [cell setTitle: @"Marker Felt"]; break;
			case 13: [cell setTitle: @"Phonepadtwo"]; break;
			case 14: [cell setTitle: @"Times New Roman"]; break;
			case 15: [cell setTitle: @"Trebuchet MS"]; break;
			case 16: [cell setTitle: @"Verdana"]; break;
			case 17: [cell setTitle: @"Zapfino"]; break;
		}

		if (row == storedFont)
		{
			[cell setChecked: YES];
		}
	}
	else
	{
		switch (row)
		{
			case 0: [cell setTitle: @"Manually"]; break;
			case 1: [cell setTitle: @"5 min"]; break;
			case 2: [cell setTitle: @"10 min"]; break;
			case 3: [cell setTitle: @"15 min"]; break;
			case 4: [cell setTitle: @"20 min"]; break;
			case 5: [cell setTitle: @"30 min"]; break;
			case 6: [cell setTitle: @"40 min"]; break;
			case 7: [cell setTitle: @"50 min"]; break;
			case 8: [cell setTitle: @"1 hour"]; break;
			case 9: [cell setTitle: @"2 hours"]; break;
			case 10: [cell setTitle: @"3 hours"]; break;
			case 11: [cell setTitle: @"6 hours"]; break;
			case 12: [cell setTitle: @"9 hours"]; break;
			case 13: [cell setTitle: @"12 hours"]; break;
			case 14: [cell setTitle: @"1 day"]; break;
			case 15: [cell setTitle: @"7 days"]; break;
		}

		if (row == storedRefresh)
		{
			[cell setChecked: YES];
		}
	}

	return cell;
}

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
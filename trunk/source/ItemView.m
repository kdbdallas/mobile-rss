#import "ItemView.h"

@implementation ItemView

- (id) initWithFrame: (struct CGRect)rect withItem: (NSDictionary*)item withRow:(int)row
{
	//Init view with frame rect
	[super initWithFrame: rect];
	
	//NSLog(@"%@", item);
	
	[self setRow: row];
	[self setItem: item];
	
	navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 70.0f)];
	[navBar showButtonsWithLeftTitle: @"Back" rightTitle:@"Next >>" leftBack: TRUE];
    [navBar setBarStyle: 3];
	[navBar enableAnimation];
	[navBar setDelegate: self];

	UINavBarButton *_visitButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(110.0f, 37.0f, 80.0f, 32.0f)];
	[_visitButton setAutosizesToFit: FALSE];
	[_visitButton setTitle: @"Visit Link"];
	[_visitButton setNavBarButtonStyle:0];
	[_visitButton addTarget: self action: @selector(visitLink) forEvents: 1];
	[navBar addSubview: _visitButton];
	[navBar setPrompt: [[item objectForKey:@"ItemsFeed"] retain]];

	[self addSubview: navBar];
	
	textView = [[UITextView alloc]
        initWithFrame: CGRectMake(0.0f, 70.0f, 320.0f, rect.size.height - 70.0f)];
    [textView setEditable:NO];
    [textView setTextSize:15];

	NSMutableString *fullText = [[NSMutableString alloc] initWithString: @"<b>"];
	[fullText appendString:[[item objectForKey:@"ItemTitle"] retain]];
	[fullText appendString:@"</b>"];
	
	if ([[item objectForKey:@"ItemDates"] retain] != nil)
	{
		[fullText appendString:@"<br/>"];
		[fullText appendString:@"<small>"];
		[fullText appendString:@"<i>"];
		[fullText appendString:[[item objectForKey:@"ItemDates"] retain]];
		[fullText appendString:@"</i>"];
		[fullText appendString:@"</small>"];
	}

	[fullText appendString:@"<br/><br/>"];
	
	if ([[item objectForKey:@"ItemDesc"] retain] != nil)
	{
		[fullText appendString:[[item objectForKey:@"ItemDesc"] retain]];
	}
	else
	{
		[fullText appendString:@"<i>The feed did not supply the text of this item. To view this item please click the Visit Link button above.</i>"];
	}

	[textView setHTML: fullText];
	
	[self addSubview: textView];
	
	return self;
}

- (void) visitLink
{
	[_delegate openURL: [NSURL URLWithString:[[_item objectForKey:@"ItemLinks"] retain]]];
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
	rect.origin.x = rect.origin.y = 0.0f;
	
	int rowPlusOne;

	switch (button) 
	{
		case 0: //Next
			rowPlusOne = _row + 1;

			[self setRow: rowPlusOne];
			[_delegate showItem:rowPlusOne fromView:@"itemView"];
		break;

		case 1:	//Back
			[_delegate hideItemView];
		break;
	}
}

- (void) setItem: (NSDictionary*)i
{
	_item = i;
}

- (void) setRow: (int)row
{
	_row = row;
}

- (void)setDelegate: (id)delegate
{
    _delegate = delegate;
}

- (void) dealloc
{
	[navBar release];
	[textView release];
	[super dealloc];
}

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

@end
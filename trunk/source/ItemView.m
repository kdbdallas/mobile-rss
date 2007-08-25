#import <UIKit/UIKit.h>
#import "ItemView.h"

@implementation ItemView
- (id)initWithFrame:(CGRect)frame
{
//	[super initWithFrame: frame];

	navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 40.0f)];
	[navBar showButtonsWithLeftTitle: @"Back" rightTitle: @"Home" leftBack: TRUE];
    [navBar setBarStyle: 3];
	[navBar setDelegate: self];
	[self addSubview: navBar];

	textView = [[UITextView alloc] initWithFrame: CGRectMake(0.0f, 40.0f, 320.0f, frame.size.height - 40.0f)];
    [textView setEditable:NO];
    [textView setTextSize:14];

	[self addSubview: textView];
}

- (void)fillWithData:(NSArray *)feedItemTitles withFeedItemDesc:(NSArray *)feedItemDesc
{
	//_feedItemTitles = feedItemTitles;
	//_feedItemDesc = feedItemDesc;
}

- (void)showDataAtIndex:(int)row
{
	//[navBar setPrompt: [@"Digg: " stringByAppendingString:[[feedItemTitles objectAtIndex:row] retain]]];
	//	[textView setText: [[feedItemDesc objectAtIndex:row] retain]];
}

- (void)dealloc {
//	[ navBar release ];
//	[ textView release ];
//	[ super dealloc ];
}

@end
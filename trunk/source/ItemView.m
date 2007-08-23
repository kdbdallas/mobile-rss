#import <UIKit/UIKit.h>
#import "ItemView.h"

@implementation ItemView
- (id)initWithFrame:(CGRect)frame atIndex:(int)row withFeedItemTitles:(NSArray *)feedItemTitles withFeedItemDesc:(NSArray *)feedItemDesc
{
	//itemView = [[UIView alloc] initWithFrame: frame];
	
	self = [super initWithFrame:frame];
	
	navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 40.0f)];
	[navBar showButtonsWithLeftTitle: @"Back" rightTitle: @"Home" leftBack: TRUE];
    [navBar setBarStyle: 3];
	[navBar setDelegate: self];
	[self addSubview: navBar];
	//[navBar setPrompt: [@"Digg: " stringByAppendingString:[[feedItemTitles objectAtIndex:row] retain]]];

	textView = [[UITextView alloc] initWithFrame: CGRectMake(0.0f, 40.0f, 320.0f, frame.size.height - 40.0f)];
    [textView setEditable:NO];
    [textView setTextSize:14];
	[textView setText: [[feedItemDesc objectAtIndex:row] retain]];

	[self addSubview: textView];
}

/*- (void)dealloc {
	[ navBar release ];
	[ super dealloc ];
}*/

@end
#import "toolBar.h"

#define BUTTON_COUNT 6

@implementation toolBar

- (id)initWithFrame:(struct CGRect)frame;
{
	struct CGRect contentRect = [UIHardware fullScreenApplicationContentRect];
	contentRect.origin.x = 0.0f;
	contentRect.origin.y = 0.0f;

    self = [super initWithFrame:frame];
    if (self)
	{
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

		float buttonWidth = contentRect.size.width / BUTTON_COUNT;
		
		_addButton = [[UIPushButton alloc] initWithFrame:CGRectMake(buttonWidth * 0.0f, 0.0f, buttonWidth, 44.0f)];
		[_addButton setAutosizesToFit:NO];
		[_addButton setImage:[UIImage imageNamed:@"add.png"] forState:0]; // normal state
		[_addButton addTarget:self action:@selector(addPressed) forEvents:1]; // mouse down
		[_addButton setShowPressFeedback:YES];
		[_addButton setEnabled:YES];
		[self addSubview:_addButton];
		
		_saveButton = [[UIPushButton alloc] initWithFrame:CGRectMake(buttonWidth * 2.0f, 0.0f, 111.0f, 44.0f)];
		[_saveButton setAutosizesToFit:NO];
		[_saveButton setImage:[UIImage imageNamed:@"save.png"] forState:0]; // normal state
		[_saveButton addTarget:self action:@selector(savePressed) forEvents:1]; // mouse down
		[_saveButton setShowPressFeedback:YES];
		[_saveButton setEnabled:YES];
		[self addSubview:_saveButton];
		
		_removeButton = [[UIPushButton alloc] initWithFrame:CGRectMake(buttonWidth * 5.0f, 0.0f, buttonWidth, 44.0f)];
		[_removeButton setAutosizesToFit:NO];
		[_removeButton setImage:[UIImage imageNamed:@"remove.png"] forState:0]; // normal state
		[_removeButton addTarget:self action:@selector(removePressed) forEvents:1]; // mouse down
		[_removeButton setShowPressFeedback:YES];
		[_removeButton setEnabled:YES];
		[self addSubview:_removeButton];

		CFRelease(colorSpace);
	}
    return self;
}

- (void)dealloc
{
	[_addButton release];
	[_saveButton release];
	[_removeButton release];
	[super dealloc];
}

- (void)setDelegate:(id)object
{
	_delegate = object;
}

- (id)delegate
{
	return _delegate;
}

- (void)addPressed
{
	[_delegate addFeed];
}

- (void)savePressed
{
	[_delegate saveFeeds];
}

- (void)removePressed
{	
	[_delegate removeFeed];
}

- (BOOL)isOpaque
{
	return NO;
}

- (void)drawRect:(struct CGRect)rect
{
	NSLog(@"toolbar: drawRect:");

	UIBezierPath *path = [UIBezierPath roundedRectBezierPath:rect withRoundedCorners:15 withCornerRadius:22.0];
	const float backgroundComponents[4] = {0, 0, 0, 0.7};
	CGContextSetFillColor(UICurrentContext(), backgroundComponents);
	[path fill];

	[super drawRect:rect];
}

@end
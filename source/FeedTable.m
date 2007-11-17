#import "FeedTable.h"

@implementation FeedTable

- (int)swipe:(int)fp8 withEvent:(struct __GSEvent *)fp12
{
	if (fp8 == 8 && ([_delegate getIsDeleting]))
	{
		CGPoint point = GSEventGetLocationInWindow(fp12);

		point.y -= 40;
		CGPoint offset = _startOffset; 

		point.x += offset.x;
		point.y += offset.y;
		int row = [self rowAtPoint:point];
		
		[_delegate setDeletingRow: row];

		[[self visibleCellForRow:row column:0] _showDeleteOrInsertion:YES withDisclosure:NO animated:YES isDelete:YES andRemoveConfirmation:YES];
	}

	return [ super swipe:fp8 withEvent:fp12 ];
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
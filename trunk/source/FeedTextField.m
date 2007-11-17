#import "FeedTextField.h"

@implementation FeedTextField

- (void)fieldEditorDidBeginEditing:(id)fp8
{
	[(FeedList*)_delegate addNewTextField];

	[super fieldEditorDidBeginEditing:fp8];
}

@end
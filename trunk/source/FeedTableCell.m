#import "FeedTableCell.h"

@implementation FeedTableCell

- (void)removeControlWillHideRemoveConfirmation:(id)fp8
{
    [self _showDeleteOrInsertion:NO withDisclosure:NO animated:YES isDelete:YES andRemoveConfirmation:YES];

	[super removeControlWillHideRemoveConfirmation:fp8];
}

- (void)setTable:(FeedTable *)table
{
    _table = table;
}

- (void)_willBeDeleted
{
	int row = [_delegate getDeletingRow];

	[_delegate removeRow:row];

	[_delegate setDeletingRow: nil];

	[super _willBeDeleted];
}

- (void)setDelegate: (id)delegate
{
    _delegate = delegate;
}

- (id)delegate
{
	return _delegate;
}

@end
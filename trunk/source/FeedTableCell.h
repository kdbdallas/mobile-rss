#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UISimpleTableCell.h>
#import <UIKit/UITable.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import "FeedTable.h"

@protocol feedTableCellDelegateProto
	- (int) getDeletingRow;
	- (void) removeRow: (int)row;
	- (void) setDeletingRow: (int)row;
@end

@interface FeedTableCell : UIImageAndTextTableCell
{
	id<feedTableCellDelegateProto> _delegate;
	FeedTable *_table;
}

- (void)removeControlWillHideRemoveConfirmation:(id)fp8;
- (void)setTable:(FeedTable *)table;
- (void)_willBeDeleted;
- (void)setDelegate: (id)delegate;

@end
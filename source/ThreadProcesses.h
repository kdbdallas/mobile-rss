#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EyeCandy.h"
#import "Settings.h"
#import "Feeds.h"
#import "FMDatabase/FMDatabase.h"

@protocol threadProcessesDelegateProto
	- (int) getFeedsID;
	- (void) clearSpinner;
@end

@interface ThreadProcesses : UIApplication {
	id<threadProcessesDelegateProto> _delegate;
	EyeCandy *_eyeCandy;
}

- (void) refreshAllFeeds:(id)param;
- (void)setDelegate: (id)delegate;
- (void) dealloc;

@end
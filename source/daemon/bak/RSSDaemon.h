#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <time.h>
#import "Feeds.h"
#import "FMDatabase/FMDatabase.h"
#include <unistd.h>
#include <sys/sysctl.h>

@interface RSSDaemon : UIApplication {
	int _KeepFeedsFor;
	int _RefreshEvery;
	int totalUnread;
	NSMutableArray *_content;
	NSString *_appLibraryPath;
	FMDatabase *db;
	NSString *_settingsPath;
	NSDictionary *plistDict;
	Feeds *_feeds;
}

- (void) InfiLoop;
- (void) processPlistWithPath;
- (NSDictionary*) loadSettings: (NSString*)path;
- (void) refreshAllFeeds;
- (NSString*) getSettingsDIR;
- (NSString*) getSettingsPath;
- (pid_t) FindPID;
- (void) dealloc;

@end
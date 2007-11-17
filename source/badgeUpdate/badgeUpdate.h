#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import "FMDatabase/FMDatabase.h"

@interface badgeUpdate : UIApplication {
	FMDatabase *db;
}

- (void) updateAppBadge:(NSString*)value;
- (void) clearAppBadge;
- (void) dealloc;

@end
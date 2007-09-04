#import "Feeds.h"

@implementation Feeds

- (NSMutableArray*) pullFeedURL:(NSString*)FeedURL
{
	NSURLResponse *response=0;
	NSError *error=0;
	NSData *rssData;
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FeedURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
	
	rssData = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error];
	
	if (rssData == nil)
	{
		_eyeCandy = [[EyeCandy alloc] init];
		[_eyeCandy showStandardAlertWithString: @"An Error Occurred" closeBtnTitle: @"Close" withError: [error localizedFailureReason]];
		[_eyeCandy release];
	}
	
	return [self processXML: rssData];
}

- (NSMutableArray*) processXML:(NSData*)data
{
	NSError *err = nil;
	NSEnumerator *childNodeEnum;
	NSEnumerator *itemEnum;
	NSXMLNode *statusNode = nil;
	NSXMLNode *childNode = nil;
	NSXMLNode *itemNode = nil;
	BOOL hasTitle = false;
	NSString *groupTitle;

	/* NOTE: This way of doing NSXMLDocument is to work around a problem with the
	ARM linker. For some reason, it does not see the NSXMLDocument symbol that is defined
	in the OfficeImport framework. So we resolve the symbol at runtime. */
	xmlDoc = [[[NSClassFromString(@"NSXMLDocument") alloc] initWithData:data options:NSXMLNodeOptionsNone error:&err] autorelease];
	
	//NSLog(@"%@", xmlDoc);
	
	statusNodes = [[[[xmlDoc children] lastObject] children] retain];
	
	NSEnumerator *statusNodeEnumerator = [statusNodes objectEnumerator];
	
	//First should be channel
	while ((statusNode = [statusNodeEnumerator nextObject]))
	{
		groupTitle = @"";
		
		//Gives me all the items
		childNodeEnum = [[statusNode children] objectEnumerator];
		
		while((childNode = [childNodeEnum nextObject]))
		{
			NSMutableDictionary *content = [[[NSMutableDictionary alloc] init] autorelease];

			if ([[childNode name] isEqualToString:@"title"] && hasTitle == false)
			{
				[content setValue:[childNode stringValue] forKey:@"feed"];
				
				groupTitle = [childNode stringValue];
			}
			
			itemEnum = [[childNode children] objectEnumerator];

			while((itemNode = [itemEnum nextObject]))
			{
				if ([[itemNode name] isEqualToString:@"title"])
				{
					[content setValue:[itemNode stringValue] forKey:@"ItemTitle"];
				}
				else if ([[itemNode name] isEqualToString:@"description"])
				{
					[content setValue:[itemNode stringValue] forKey:@"ItemDesc"];
				}
				else if ([[itemNode name] isEqualToString:@"pubDate"] || [[itemNode name] isEqualToString:@"dc:date"])
				{
					[content setValue:[itemNode stringValue] forKey:@"ItemDates"];
				}
				else if ([[itemNode name] isEqualToString:@"link"])
				{
					[content setValue:[itemNode stringValue] forKey:@"ItemLinks"];
				}
				else
				{
					//NSLog(@"What arent we getting name: %@", [itemNode name]);
					//NSLog(@"What arent we getting value: %@", [itemNode stringValue]);
				}
			}

			if (([[childNode name] isEqualToString:@"title"] && hasTitle == false) || [[childNode name] isEqualToString:@"item"])
			{
				[content setValue:groupTitle forKey:@"ItemsFeed"];
				
				[self groupItems: content];
				
				if ([[childNode name] isEqualToString:@"title"])
				{
					hasTitle = true;
				}
			}
		}
		
		// This is because sites like Slashdot think it is fun to break the mold
		if ([[statusNode name] isEqualToString:@"item"])
		{
			NSMutableDictionary *content = [[[NSMutableDictionary alloc] init] autorelease];

			childNodeEnum = [[statusNode children] objectEnumerator];

			while((itemNode = [childNodeEnum nextObject]))
			{
				if ([[itemNode name] isEqualToString:@"title"])
				{
					[content setValue:[itemNode stringValue] forKey:@"ItemTitle"];
				}
				else if ([[itemNode name] isEqualToString:@"description"])
				{
					[content setValue:[itemNode stringValue] forKey:@"ItemDesc"];
				}
				else if ([[itemNode name] isEqualToString:@"pubDate"] || [[itemNode name] isEqualToString:@"dc:date"])
				{
					[content setValue:[itemNode stringValue] forKey:@"ItemDates"];
				}
				else if ([[itemNode name] isEqualToString:@"link"])
				{
					[content setValue:[itemNode stringValue] forKey:@"ItemLinks"];
				}
				else
				{
					//NSLog(@"What arent we getting name: %@", [itemNode name]);
					//NSLog(@"What arent we getting value: %@", [itemNode stringValue]);
				}
			}

			[content setValue:groupTitle forKey:@"ItemsFeed"];

			[self groupItems: content];
		}
	}

	return nil;
}

- (void) initArray
{
	Items = [[NSMutableArray alloc] initWithCapacity: 1];
}

- (void) groupItems:(NSMutableDictionary*)content
{
	[Items addObject: content];
}

- (NSArray*) returnArray
{
	return Items;
}

// Start of required NSURLConnection methods
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it has enough information to create the NSURLResponse
    // it can be called multiple times, for example in the case of a redirect, so each time we reset the data.
    [_responseData setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData receivedData is declared as a method instance elsewhere
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// release the connection, and the data object
    [connection release];
    [_responseData release];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    [_responseData release];

	NSLog([error localizedDescription]);

	_eyeCandy = [[EyeCandy alloc] init];
	[_eyeCandy showStandardAlert: @"An Error Occurred" closeBtnTitle: @"Close" withError: error];
}
// End of required NSURLConnection methods

@end
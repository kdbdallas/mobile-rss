#import "Feeds.h"

@implementation Feeds

- (NSMutableArray*) pullFeedURL:(NSString*)FeedURL
{
	NSURLResponse *response=0;
	NSError *error=0;
	NSData *rssData;
	
	//_URL = [FeedURL retain];
	
	//NSLog(@"feedURL: %@", FeedURL);
	//NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FeedURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
	
	//rssData = [NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error];
	rssData = [NSData dataWithContentsOfURL: [NSURL URLWithString:FeedURL]];

	_eyeCandy = [[EyeCandy alloc] init];

	if (rssData == nil)
	{
		//[_eyeCandy showStandardAlertWithString: @"An Error Occurred" closeBtnTitle: @"Close" withError: [error localizedFailureReason]];
		[_delegate performSelectorOnMainThread:@selector(showErrGetFeed:) withObject:FeedURL waitUntilDone:NO];
		
		return nil;
	}
	else
	{
		return [self processXML: rssData withURL: FeedURL];
	}
}

- (NSMutableArray*) processXML:(NSData*)data withURL:(NSString*)url
{
	NSError *err = nil;
	NSEnumerator *childNodeEnum;
	NSEnumerator *itemEnum;
	NSXMLNode *statusNode = nil;
	NSXMLNode<XMLClassProto> *childNode = nil;
	NSXMLNode *itemNode = nil;
	BOOL hasTitle = false;
	NSString *groupTitle;
	BOOL wasAtom = false;
	NSArray *nodeAttrs;

	if (data != nil)
	{
		//NSLog(@"Data: %@", data);
		
		/* NOTE: This way of doing NSXMLDocument is to work around a problem with the
		ARM linker. For some reason, it does not see the NSXMLDocument symbol that is defined
		in the OfficeImport framework. So we resolve the symbol at runtime. */
		xmlDoc = [[[NSClassFromString(@"NSXMLDocument") alloc] initWithData:data options:NSXMLNodeOptionsNone error:&err] autorelease];

		//NSLog(@"xmlDoc: %@", xmlDoc);

		if ([[xmlDoc children] count] > 0)
		{	
			NSEnumerator *statusNodeEnumerator;
	
			statusNodes = [[[[xmlDoc children] lastObject] children] retain];
	
			if (!statusNodes)
			{
				statusNode = [xmlDoc rootElement];
		
				if ((![[statusNode name] isEqualToString: @"channel"]) || (![[statusNode name] isEqualToString: @"feed"]))
				{
					childNodeEnum = [[statusNode children] objectEnumerator];

					while ((childNode = [childNodeEnum nextObject]))
					{
						if (([[childNode name] isEqualToString: @"channel"]) || ([[childNode name] isEqualToString: @"feed"]))
						{
							if ([[statusNode name] isEqualToString: @"feed"])
							{
								wasAtom = true;
							}

							statusNodeEnumerator = [[childNode children] objectEnumerator];
							break;
						}
						else if (([[childNode name] isEqualToString: @"entry"]))
						{
							statusNodeEnumerator = [[statusNode children] objectEnumerator];
						}
					}
				}
			}
			else
			{
				statusNodeEnumerator = [statusNodes objectEnumerator];
			}
	
			groupTitle = @"";
	
			//First should be channel
			while ((statusNode = [statusNodeEnumerator nextObject]))
			{
				//NSLog(@"%@", statusNode);
		
				NSMutableDictionary *content = [[[NSMutableDictionary alloc] init] autorelease];
		
				if ([[statusNode name] isEqualToString:@"title"] && hasTitle == false)
				{
					[content setValue:[statusNode stringValue] forKey:@"feed"];

					groupTitle = [statusNode stringValue];
				}

				if ([[statusNode name] isEqualToString: @"entry"])
				{
					//NSLog(@"ccc: %@", [statusNode name]);
			
					childNodeEnum = [[statusNode children] objectEnumerator];

					while((childNode = [childNodeEnum nextObject]))
					{
						//NSLog(@"ccc: %@", [childNode name]);

						if ([[childNode name] isEqualToString:@"title"])
						{
							NSString *tmpValue;
					
							tmpValue = [childNode stringValue];
					
							if ([tmpValue isEqualToString: @""])
							{
								tmpValue = @"<No Title>";
							}
					
							[content setValue:tmpValue forKey:@"ItemTitle"];
						}
						else if ([[childNode name] isEqualToString:@"description"] || [[childNode name] isEqualToString:@"content"] || [[childNode name] isEqualToString:@"summary"])
						{
							[content setValue:[childNode stringValue] forKey:@"ItemDesc"];
						}
						else if ([[childNode name] isEqualToString:@"published"])
						{
							[content setValue:[childNode stringValue] forKey:@"ItemDates"];
						}
						else if ([[childNode name] isEqualToString:@"link"])
						{
							if ([[childNode stringValue] isEqualToString: nil])
							{
								[content setValue:[childNode stringValue] forKey:@"ItemLinks"];
							}
							else
							{
								NSXMLNode *linkTypeNode = [childNode attributeForName:@"rel"];
						
								if ([[linkTypeNode stringValue] isEqualToString: @"alternate"])
								{
									childNode = [childNode attributeForName:@"href"];
									[content setValue:[childNode stringValue] forKey:@"ItemLinks"];
								}
							}
						}
						else
						{
							//NSLog(@"What arent we getting1 name: %@", [itemNode name]);
							//NSLog(@"What arent we getting1 value: %@", [itemNode stringValue]);
						}
					}
				}
				else
				{
					addedIt = NO;

					//Gives me all the items
					childNodeEnum = [[statusNode children] objectEnumerator];
		
					while((childNode = [childNodeEnum nextObject]))
					{
						//NSLog(@"%@", childNode);

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
								NSString *tmpValue;

								tmpValue = [itemNode stringValue];

								if ([tmpValue isEqualToString: @""])
								{
									tmpValue = @"<No Title>";
								}

								[content setValue:tmpValue forKey:@"ItemTitle"];
							}
							else if ([[itemNode name] isEqualToString:@"description"] || [[itemNode name] isEqualToString:@"content"] || [[itemNode name] isEqualToString:@"summary"])
							{
								[content setValue:[itemNode stringValue] forKey:@"ItemDesc"];
							}
							else if ([[itemNode name] isEqualToString:@"pubDate"] || [[itemNode name] isEqualToString:@"dc:date"] || [[itemNode name] isEqualToString:@"published"])
							{
								[content setValue:[itemNode stringValue] forKey:@"ItemDates"];
							}
							else if ([[itemNode name] isEqualToString:@"link"])
							{
								[content setValue:[itemNode stringValue] forKey:@"ItemLinks"];
							}
							else
							{
								//NSLog(@"What arent we getting2 name: %@", [itemNode name]);
								//NSLog(@"What arent we getting2 value: %@", [itemNode stringValue]);
							}
						}

						if (([[childNode name] isEqualToString:@"title"] && hasTitle == false) || [[childNode name] isEqualToString:@"item"] || [[childNode name] isEqualToString:@"entry"])
						{
							[content setValue:groupTitle forKey:@"ItemsFeed"];
			
							[self groupItems: content];
			
							if ([[childNode name] isEqualToString:@"title"])
							{
								hasTitle = true;
							}
						}
					}
		
					// This is because sites like Slashdot and Yahoo think it is fun to break the mold
					if ([[statusNode name] isEqualToString:@"item"] || [[childNode name] isEqualToString:@"entry"])
					{
						NSMutableDictionary *content = [[[NSMutableDictionary alloc] init] autorelease];

						childNodeEnum = [[statusNode children] objectEnumerator];

						while((itemNode = [childNodeEnum nextObject]))
						{
							if ([[itemNode name] isEqualToString:@"title"])
							{
								NSString *tmpValue;

								tmpValue = [itemNode stringValue];

								if ([tmpValue isEqualToString: @""])
								{
									tmpValue = @"<No Title>";
								}

								[content setValue:tmpValue forKey:@"ItemTitle"];
							}
							else if ([[itemNode name] isEqualToString:@"description"] || [[itemNode name] isEqualToString:@"content"] || [[itemNode name] isEqualToString:@"summary"])
							{
								[content setValue:[itemNode stringValue] forKey:@"ItemDesc"];
							}
							else if ([[itemNode name] isEqualToString:@"pubDate"] || [[itemNode name] isEqualToString:@"dc:date"] || [[itemNode name] isEqualToString:@"published"])
							{
								[content setValue:[itemNode stringValue] forKey:@"ItemDates"];
							}
							else if ([[itemNode name] isEqualToString:@"link"])
							{
								[content setValue:[itemNode stringValue] forKey:@"ItemLinks"];
							}
							else
							{
								//NSLog(@"What arent we getting name3: %@", [itemNode name]);
								//NSLog(@"What arent we getting value3: %@", [itemNode stringValue]);
							}
						}
				
						addedIt = YES;

						[content setValue:groupTitle forKey:@"ItemsFeed"];

						[self groupItems: content];
					}
				}
		
				if ((([[statusNode name] isEqualToString:@"title"] && hasTitle == false) || [[statusNode name] isEqualToString:@"item"] || [[statusNode name] isEqualToString:@"entry"]) && addedIt == NO)
				{
					[content setValue:groupTitle forKey:@"ItemsFeed"];
	
					[self groupItems: content];
	
					if ([[statusNode name] isEqualToString:@"title"])
					{
						hasTitle = true;
					}
				}
			}
		}
		else
		{
			NSLog(@"Could not get feed: %@", url);

			[_delegate performSelectorOnMainThread:@selector(showErrGetFeed:) withObject:url waitUntilDone:NO];
		}
	}
	else
	{
		NSLog(@"Could not get feed: %@  data nil", url);

		[_delegate performSelectorOnMainThread:@selector(showErrGetFeed:) withObject:url waitUntilDone:NO];
	}

	return nil;
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	[sheet dismiss];
	[sheet release];
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

- (void)setDelegate: (id)delegate
{
    _delegate = delegate;
}

- (id)delegate
{
	return _delegate;
}

- (void) dealloc
{
	//[theConnection release];
	//[_responseData release];
	[xmlDoc release];
	[statusNodes release];
	[Items release];
	[super dealloc];
}

// Start of required NSURLConnection methods
/*- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
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
}*/
// End of required NSURLConnection methods

@end
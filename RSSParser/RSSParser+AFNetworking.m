//
//  RSSParser+AFNetworking.m
//  RSSParser
//
//  Created by Thibaut LE LEVIER on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSSParser+AFNetworking.h"

#import "AFHTTPRequestOperation.h"
#import "AFURLResponseSerialization.h"

@implementation RSSParser (AFNetworking)

+ (void)parseRSSFeedForRequest:(NSURLRequest *)urlRequest
                       success:(void (^)(NSArray *feedItems))success
                       failure:(void (^)(NSError *error))failure
{
    RSSParser *const parser = [RSSParser new];
    [parser parseRSSFeedForRequest: urlRequest 
                           success: success 
                           failure: failure];
}


- (void)parseRSSFeedForRequest:(NSURLRequest *)urlRequest
                       success:(void (^)(NSArray *feedItems))success
                       failure:(void (^)(NSError *error))failure
{    
    AFHTTPRequestOperation *const operation = [[AFHTTPRequestOperation alloc] initWithRequest: urlRequest];
    
    operation.responseSerializer = [AFXMLParserResponseSerializer new];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/xml", @"text/xml",@"application/rss+xml", @"application/atom+xml", nil];
    
    [operation setCompletionBlockWithSuccess: ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSXMLParser *const xmlParser = (NSXMLParser *)responseObject;
        [xmlParser setDelegate:self];
        [xmlParser parse];
    		if(!xmlParser.parserError) {
    			success(self.items);
    		} else {
    			failure(xmlParser.parserError);
    		}
    }
                                     failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
                                         failure(error);
                                     }];
    
    [operation start];
}

@end

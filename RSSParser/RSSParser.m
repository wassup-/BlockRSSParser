//
//  RSSParser.m
//  RSSParser
//
//  Created by Thibaut LE LEVIER on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSSParser.h"

@interface RSSParser() {
    RSSItem *currentItem;
    NSMutableString *tmpString;
    NSDictionary *tmpAttrDict;
}

@property (nonatomic) NSDateFormatter *formatter;
@property (nonatomic, strong) NSMutableArray<RSSItem *> *mutableItems;

@end

@implementation RSSParser

#pragma mark lifecycle
- (id)init {
    self = [super init];
    if (self) {
        self.mutableItems = [NSMutableArray new];
        
        _formatter = [NSDateFormatter new];
        [_formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_EN"]];
        [_formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
    }
    return self;
}

#pragma mark - Properties

-(NSArray<RSSItem *> *)items {
    return self.mutableItems;
}

#pragma mark -

-(RSSMediaType)mediaTypeForURL:(NSString *)url {
    // TODO
    return RSSMediaTypeImage;
}

#pragma mark NSXMLParser delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
        currentItem = [RSSItem new];
	} else if([elementName hasPrefix:@"media:"]) {
        NSString *const url = attributeDict[@"url"];
        if(url.length) {
    		[currentItem addMedia: url
                         withType: [self mediaTypeForURL: url]];
        }
	}
	
    tmpString = NSMutableString.new;
    tmpAttrDict = attributeDict;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
        [self.mutableItems addObject:currentItem];
    }
    if (currentItem != nil && tmpString != nil) {
        
        if ([elementName isEqualToString:@"title"]) {
            [currentItem setTitle:tmpString];
        } else if ([elementName isEqualToString:@"description"]) {
            [currentItem setItemDescription:tmpString];
        } else if ([elementName isEqualToString:@"content:encoded"] || [elementName isEqualToString:@"content"]) {
            [currentItem setContent:tmpString];
        } else if ([elementName isEqualToString:@"link"]) {
            [currentItem setLink:[NSURL URLWithString:tmpString]];
        } else if ([elementName isEqualToString:@"comments"]) {
            [currentItem setCommentsLink:[NSURL URLWithString:tmpString]];
        } else if ([elementName isEqualToString:@"wfw:commentRss"]) {
            [currentItem setCommentsFeed:[NSURL URLWithString:tmpString]];
        } else if ([elementName isEqualToString:@"slash:comments"]) {
            [currentItem setCommentsCount:[NSNumber numberWithInt:[tmpString intValue]]];
        } else if ([elementName isEqualToString:@"pubDate"]) {
            [currentItem setPubDate:[_formatter dateFromString:tmpString]];
        } else if ([elementName isEqualToString:@"dc:creator"]) {
            [currentItem setAuthor:tmpString];
        } else if ([elementName isEqualToString:@"guid"]) {
            [currentItem setGuid:tmpString];
        }
        
        // sometimes the URL is inside enclosure element, not in link. Reference: http://www.w3schools.com/rss/rss_tag_enclosure.asp
        if ([elementName isEqualToString:@"enclosure"] && tmpAttrDict != nil) {
            NSString *url = [tmpAttrDict objectForKey:@"url"];
            if(url) {
                [currentItem setLink:[NSURL URLWithString:url]];
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [tmpString appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    [parser abortParsing];
}

@end

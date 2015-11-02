//
//  RSSParser.h
//  RSSParser
//
//  Created by Thibaut LE LEVIER on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RSSItem.h"

#import <Foundation/Foundation.h>

@interface RSSParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, readonly) NSArray<RSSItem *> *items;

@end

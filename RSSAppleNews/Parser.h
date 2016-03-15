//
//  Parser.h
//  RSSAppleNews
//
//  Created by ed8009 on 14.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsRSS.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface Parser : UIViewController <NSXMLParserDelegate>

+ (id)sharedMyManagerParser;
- (void)startParser:(NSMutableData *)data;
- (NSArray *)fetchedResultsControllerr;

@end

//
//  Parser.h
//  RSSAppleNews
//
//  Created by ed8009 on 14.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkingWithCoreData.h"
@interface Parser : UIViewController <NSXMLParserDelegate>
@property (nonatomic, strong) NSString *urlRSS;

+ (id)sharedMyManagerParser;
- (void)startParser:(NSMutableData *)data urlRSS:(NSString *)urlRSS;

@end

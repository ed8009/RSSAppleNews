//
//  UserRSSFeedTableViewController.h
//  RSSAppleNews
//
//  Created by ed8009 on 23.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableCellCustom.h"
#import "BrowserViewController.h"
#import "LoadingData.h"
#import "Parser.h"

@interface UserRSSFeedTableViewController : UITableViewController

@property (nonatomic, strong) NSString *urlRSS;

@end

//
//  ReadRssTableViewController.h
//  RSSAppleNews
//
//  Created by ed8009 on 09.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ReadRssTableViewController : UITableViewController <NSXMLParserDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,strong) NSMutableArray* newsCoreData;

@end

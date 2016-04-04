//
//  WorkingWithCoreData.h
//  RSSAppleNews
//
//  Created by ed8009 on 24.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSnews.h"
#import "RSSDetails.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "LoadingData.h"

@interface WorkingWithCoreData : UIViewController

+ (id)sharedMyManagerCoreData;
- (NSArray *)getAllCategories;
- (void)addRSSFeedName:(NSString *)nameFeed linkFeed:(NSString *)linkFeed;
- (NSArray *)getDetailOfSelectedCategory:(NSString *)linkRSS;
- (NSArray *)getAllRSSRecords;
- (void)deleteCategories:(RSSnews *)objectRSS;
- (BOOL)essenceExistsInDatabase:(NSString *)link rssEntity:(NSString *)rssEntity;
- (void)saveDataBase:(NSDictionary *)newsItem urlRSS:(NSString *)urlRSS;

@end

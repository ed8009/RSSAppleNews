//
//  RSSDetails+CoreDataProperties.h
//  RSSAppleNews
//
//  Created by ed8009 on 24.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "RSSDetails.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSSDetails (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *newsDate;
@property (nullable, nonatomic, retain) NSString *newsDescription;
@property (nullable, nonatomic, retain) NSString *newsLink;
@property (nullable, nonatomic, retain) NSString *newsTitle;
@property (nullable, nonatomic, retain) RSSnews *rss;

@end

NS_ASSUME_NONNULL_END

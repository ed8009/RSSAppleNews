//
//  TableCellCustom.h
//  RSSAppleNews
//
//  Created by ed8009 on 09.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCellCustom : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *currentTitle;
@property (nonatomic, weak) IBOutlet UILabel *currentDescription;
@property (nonatomic, weak) IBOutlet UILabel *currentDate;

@end

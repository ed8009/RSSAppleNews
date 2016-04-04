//
//  AddRSSFeedViewController.h
//  RSSAppleNews
//
//  Created by ed8009 on 23.03.16.
//  Copyright © 2016 ed8009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parser.h"
#import "LoadingData.h"


@interface AddRSSFeedViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameRSSField;
@property (weak, nonatomic) IBOutlet UITextField *linkRSSField;
- (IBAction)add:(id)sender;
- (IBAction)closeModal:(id)sender;

@end

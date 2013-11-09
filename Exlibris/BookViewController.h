//
//  NewBookViewController.h
//  Bukini
//
//  Created by Paweł Ksieniewicz on 09.11.2013.
//  Copyright (c) 2013 Paweł Ksieniewicz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface BookViewController : UITableViewController <ZBarReaderDelegate>

@property (strong,nonatomic) Book *book;

@property (strong, nonatomic) IBOutlet UITextField *authorField;
@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextField *publisherField;
@property (strong, nonatomic) IBOutlet UISwitch *isReadedSwitch;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)nextField:(id)sender;


@end

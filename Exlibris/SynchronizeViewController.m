//
//  SynchronizeViewController.m
//  Bukini
//
//  Created by Paweł Ksieniewicz on 09.11.2013.
//  Copyright (c) 2013 Paweł Ksieniewicz. All rights reserved.
//

#import "SynchronizeViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "Book.h"

@interface SynchronizeViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation SynchronizeViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"WYślij email");
    if ([MFMailComposeViewController canSendMail])
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:Book.class.description];

        MFMailComposeViewController *mailer = [MFMailComposeViewController new];
        [mailer setMailComposeDelegate:self];
        [mailer setSubject:@"[Bukini] archiwum"];
        [mailer setMessageBody:@"Oto archiwum!"
                        isHTML:NO];
        
        [mailer addAttachmentData:data
                         mimeType:@"text"
                         fileName:@"archive.bukini"];
        
        [self presentViewController:mailer
                           animated:YES
                         completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES
                                   completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow
                                  animated:YES];
}

@end

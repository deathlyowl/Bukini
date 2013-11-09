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
#import <DBChooser/DBChooser.h>

#define DROPBOX_KEY @"bv3wwgkgggevdr4"
@interface SynchronizeViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation SynchronizeViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0)         [self sendMail];
    else if (indexPath.row == 1)    [self sendToDropbox];
    else if (indexPath.row == 2)    [self chooseFromDropbox];
}

- (void) sendMail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [MFMailComposeViewController new];
        [mailer setMailComposeDelegate:self];
        [mailer setSubject:@"[Bukini] archiwum"];
        [mailer setMessageBody:@"Oto archiwum!"
                        isHTML:NO];
        
        [mailer addAttachmentData:self.data
                         mimeType:@"text"
                         fileName:@"archive.bukini"];
        
        [self presentViewController:mailer
                           animated:YES
                         completion:nil];
    }
}

- (void) chooseFromDropbox{
    NSLog(@"Choose from DB");
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow
                                  animated:YES];
    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect
                                    fromViewController:self
                                            completion:^(NSArray *results)
     {
         if ([results count]) {
             // Process results from Chooser
             //NSLog(@"%@", [[results lastObject] link]);
             
             [Book importArchive:[NSData dataWithContentsOfURL:[[results lastObject] link]]];
         } else {
             // User canceled the action
         }
     }];
}

- (void) sendToDropbox
{
    NSLog(@"Send to DB");    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow
                                  animated:YES];
}

- (NSData *) data{
    return [[NSUserDefaults standardUserDefaults] objectForKey:Book.class.description];
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

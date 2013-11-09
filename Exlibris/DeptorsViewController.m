//
//  DeptorsViewController.m
//  Bukini
//
//  Created by Paweł Ksieniewicz on 09.11.2013.
//  Copyright (c) 2013 Paweł Ksieniewicz. All rights reserved.
//

#import "DeptorsViewController.h"
#import <AddressBook/AddressBook.h>

@interface DeptorsViewController () {
    ABAddressBookRef addressBookRef;
    NSMutableArray *persons;
}

@end

@implementation DeptorsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    persons = NSMutableArray.new;
    // Request authorization to Address Book
    addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                NSLog(@"Granted");
                [self loadContacts];
                // First time access has been granted, add the contact
     //           [self _addContactToAddressBook];
            } else {
                NSLog(@"Revijed");
                // User denied access
                // Display an alert telling user the contact could not be added
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        NSLog(@"Access");
        [self loadContacts];
        // The user has previously given access, add the contact
        //[self _addContactToAddressBook];
    }
    else {
        NSLog(@"No access");
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) loadContacts{
    persons = NSMutableArray.new;
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBookRef);
    
    for ( int i = 0; i < nPeople; i++ )
    {
        
        [persons addObject:CFBridgingRelease(CFArrayGetValueAtIndex( allPeople, i ))];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return persons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ABRecordRef person = (__bridge ABRecordRef)(persons[indexPath.row]);
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    // Configure the cell...
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", firstName, lastName]];
    NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
    UIImage  *img = [UIImage imageWithData:imgData];
    
    
    [cell.imageView setImage:img ? [DeptorsViewController imageWithImage:img scaledToSize:CGSizeMake(50, 50)] : [DeptorsViewController imageWithImage:[UIImage imageNamed:@"nothing"] scaledToSize:CGSizeMake(50, 50)]];
    [cell.imageView setBackgroundColor:self.tableView.tintColor];
    [cell.imageView.layer setCornerRadius:50./2.];
    
    UILabel *badge = [[UILabel alloc] initWithFrame:CGRectMake(45, 37.5, 25, 25)];
    [badge setText:@"5"];
    [badge setBackgroundColor:self.tableView.tintColor];
    [badge setFont:[UIFont boldSystemFontOfSize:10]];
    [badge setTextAlignment:NSTextAlignmentCenter];
    [badge.layer setCornerRadius:25./2.];
    [badge setTextColor:[UIColor whiteColor]];
    
    [cell addSubview:badge];
    
    return cell;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end

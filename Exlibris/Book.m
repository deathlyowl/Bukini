//
//  Books.m
//  Exlibris
//
//  Created by Paweł Ksieniewicz on 08.11.2013.
//  Copyright (c) 2013 Paweł Ksieniewicz. All rights reserved.
//

#import "Book.h"

static NSArray *sectionsArray, *initialsArray;
static NSString *filterString;
static NSMutableArray *filteredAll;
static NSMutableArray *allBooks;
static NSData *importBuffer;

@implementation Book

@synthesize title, author, publisher;

+ (NSMutableArray *)all
{
    static dispatch_once_t once;
    dispatch_once(&once, ^
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:self.class.description];
        allBooks = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : NSMutableArray.new;
    });
    return allBooks;
}

+ (void) importArchive:(NSData *)archive{
    importBuffer = archive;
    UIAlertView *missingAlert = [[UIAlertView alloc] initWithTitle:@"Nowe archiwum"
                                              message:@"Wygląda na to, że chcesz skorzystać z pliku archiwum."
                                             delegate:self
                                    cancelButtonTitle:@"Nie rób nic"
                                    otherButtonTitles:@"Zastąp bazę nową", @"Połącz bazy", nil];
    
    [missingAlert show];
}

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 0 - nie rób nic
    // 1 — zastąp
    // 2 — połącz
    
    switch (buttonIndex) {
        case 0: return;
        case 1:
            allBooks = importBuffer ? [NSKeyedUnarchiver unarchiveObjectWithData:importBuffer] : allBooks;
            break;
        case 2:
            if (importBuffer) {
                NSMutableArray *newBooks = [NSKeyedUnarchiver unarchiveObjectWithData:importBuffer];
                [allBooks addObjectsFromArray:newBooks];
            }
    }
    [self sort];
    [self saveQuiet:NO];
}

+ (Book *)bookWithVolumeInfoDictionary:(NSDictionary *)volumeInfo{
    Book *book = Book.new;
    
    book.author = [volumeInfo[@"authors"] componentsJoinedByString:@", "];
    book.title = volumeInfo[@"title"];
    
    return book;
}

#pragma mark - Manage objects
+ (void)addBook:(Book *)book
{
    [self.all addObject:book];
    [self sort];
    [self saveQuiet:NO];
}

+ (void)removeBook:(Book *)book
{
    [self.all removeObject:book];
    [self sort];
    [self saveQuiet:YES];
}

+ (void)saveBook:(Book *)newBook
        overBook:(Book *)oldBook
{
    NSUInteger index = [self.all indexOfObject:oldBook];
    
    if (index == NSNotFound) [self addBook:newBook];
    else [self.all replaceObjectAtIndex:index withObject:newBook];
    [self saveQuiet:NO];
}

+ (void)saveQuiet:(BOOL) isQuiet
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.all]
                                              forKey:self.class.description];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (!isQuiet) [[NSNotificationCenter defaultCenter] postNotificationName:BOOKS_UPDATED object:nil];
}

#pragma mark - Serialization
- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:title forKey:@"title"];
    [coder encodeObject:author forKey:@"author"];
    [coder encodeObject:publisher forKey:@"publisher"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    title = [coder decodeObjectForKey:@"title"];
    author = [coder decodeObjectForKey:@"author"];
    publisher = [coder decodeObjectForKey:@"publisher"];
    return self;
}

#pragma mark - Search
- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText
{
    filterString = searchText.length ? searchText : nil;
    [Book sort];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOKS_UPDATED object:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

+ (void) filterWithString:(NSString *)string
{
    filteredAll = [NSMutableArray arrayWithArray:self.all];
    if (string) [filteredAll filterUsingPredicate:[NSPredicate predicateWithFormat:
                                                   @"title contains[c] %@ || author contains[c] %@ || publisher contains[c] %@", string, string, string]];
}

#pragma mark - Table view helpers
+ (Book *)bookForIndexPath:(NSIndexPath *)indexPath
{
    return sectionsArray[indexPath.section][indexPath.row];
}

+ (void) generateSections
{
    NSMutableSet *initialsSet = NSMutableSet.new;
    for (Book *book in filteredAll) [initialsSet addObject:[[book.title substringToIndex:1] uppercaseString]];
    initialsArray = [[initialsSet allObjects]
                     sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b){return [a localizedCompare:b];}];
    
    NSMutableArray *mutableSectionsArray = NSMutableArray.new;
    for (NSString *initial in initialsArray)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title beginswith[c] %@", initial];
        NSArray *filtered = [filteredAll filteredArrayUsingPredicate:predicate];
        [mutableSectionsArray addObject:filtered];
    }
    sectionsArray = (NSArray *) mutableSectionsArray;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return initialsArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *currentSection = sectionsArray[section];
    return currentSection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    Book *book = [Book bookForIndexPath:indexPath];
    [cell.textLabel setText:book.title];
    [cell.detailTextLabel setText:book.author];
    [cell.imageView setImage:[UIImage imageNamed:book.publisher]];
    
    if (!cell.imageView.image) [cell.imageView setImage:[UIImage imageNamed:@"empty"]];
    
    return cell;
}

#pragma mark - Table view editing
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        BOOL lastRow = [tableView numberOfRowsInSection:indexPath.section] == 1;
        [Book removeBook:[Book bookForIndexPath:indexPath]];
        if (lastRow)    [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        else            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view index titles
- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return initialsArray[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return initialsArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

#pragma mark - Others
- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ — %@", author, title];
}

+ (void) sort
{
    [self filterWithString:filterString];
    [filteredAll sortUsingComparator:^NSComparisonResult(Book *a, Book *b){return [a.title localizedCompare:b.title];}];
    [self generateSections];
}

@end

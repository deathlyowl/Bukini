//
//  Books.m
//  Exlibris
//
//  Created by Paweł Ksieniewicz on 08.11.2013.
//  Copyright (c) 2013 Paweł Ksieniewicz. All rights reserved.
//

#import "Book.h"

static NSArray *sectionsArray;
static NSArray *initialsArray;
static NSMutableArray *filteredAll;
static NSString *filterString;

@implementation Book

@synthesize title, author, publisher;

+ (NSMutableArray *)all
{
    static dispatch_once_t once;
    static NSMutableArray *allBooks;
    dispatch_once(&once, ^
    {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:self.class.description];
        if (data)   allBooks = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        else        allBooks = NSMutableArray.new;
        NSLog(@"%i books", allBooks.count);
    });
    
    return allBooks;
}

+ (void) filterWithString:(NSString *)string{
    filteredAll = [NSMutableArray arrayWithArray:self.all];
    
    if (string) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"title contains[c] %@ || author contains[c] %@ || publisher contains[c] %@", string, string, string];
        
        [filteredAll filterUsingPredicate:predicate];
    }
    
    NSLog(@"%i filtered", filteredAll.count);
}

+ (void) generateSections
{
    NSMutableSet *initialsSet = NSMutableSet.new;
    for (Book *book in filteredAll) [initialsSet addObject:[[book.title substringToIndex:1] uppercaseString]];
    initialsArray = [[initialsSet allObjects]
                     sortedArrayUsingComparator:
                     ^NSComparisonResult(NSString *a, NSString *b){return [a localizedCompare:b];}];
    
    NSMutableArray *mutableSectionsArray = NSMutableArray.new;
    
    for (NSString *initial in initialsArray)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title beginswith[c] %@", initial];
        NSArray *filtered = [Book.all filteredArrayUsingPredicate:predicate];
        [mutableSectionsArray addObject:filtered];
    }
    
    sectionsArray = (NSArray *) mutableSectionsArray;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    filterString = searchText.length ? searchText : nil;
    
    [Book sort];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOKS_UPDATED object:nil];
}

+ (void) sort{
    [self filterWithString:filterString];
    
    [filteredAll sortUsingComparator:^NSComparisonResult(Book *a, Book *b){return [a.title compare:b.title];}];
    [self generateSections];
}

+ (void)addBook:(Book *)book{
    NSLog(@"[Book]\tAdding book: %@", book);
    [self.all addObject:book];
    [self sort];
    [self saveQuiet:NO];
}

+ (void)removeBook:(Book *)book{
    NSLog(@"[Book]\tRemoving book: %@", book);
    [self.all removeObject:book];
    [self sort];
    [self saveQuiet:YES];
}

+ (void)saveBook:(Book *)newBook
        overBook:(Book *)oldBook
{
    [self.all replaceObjectAtIndex:[self.all indexOfObject:oldBook]
                        withObject:newBook];
    [self saveQuiet:NO];
}

+ (void)saveQuiet:(BOOL) isQuiet
{
    //Saving it
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.all]
                                              forKey:self.class.description];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (!isQuiet) [[NSNotificationCenter defaultCenter] postNotificationName:BOOKS_UPDATED object:nil];
    
    NSLog(@"[Book]\tBooks saved");
}

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

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ — %@", author, title];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return initialsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sectionsArray[section] count];
}

+ (Book *)bookForIndexPath:(NSIndexPath *)indexPath{
    return sectionsArray[indexPath.section][indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    Book *book = [Book bookForIndexPath:indexPath];
    [cell.textLabel setText:book.title];
    [cell.detailTextLabel setText:book.author];
    [cell.imageView setImage:[UIImage imageNamed:book.publisher]];
    
    if (!cell.imageView.image) [cell.imageView setImage:[UIImage imageNamed:@"empty"]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return initialsArray[section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return initialsArray;
}

- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
    return index;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        BOOL lastRow = [tableView numberOfRowsInSection:indexPath.section] == 1;
        
        [Book removeBook:[Book bookForIndexPath:indexPath]];
        // Delete the row from the data source
        //
        
        if (lastRow)    [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        else            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

@end

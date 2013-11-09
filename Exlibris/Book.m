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
    });
    return allBooks;
}

+ (void) generateSections{
    NSLog(@"Gensec");
    NSMutableSet *initialsSet = NSMutableSet.new;
    for (Book *book in self.all) [initialsSet addObject:[book.title substringToIndex:1]];
    initialsArray = [[initialsSet allObjects]
                     sortedArrayUsingComparator:
                     ^NSComparisonResult(NSString *a, NSString *b){return [a compare:b];}];
    
    
    NSMutableArray *mutableSectionsArray = NSMutableArray.new;
    
    for (NSString *initial in initialsArray)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title beginswith %@", initial];
        NSArray *filtered = [Book.all filteredArrayUsingPredicate:predicate];
        [mutableSectionsArray addObject:filtered];
    }
    
    sectionsArray = (NSArray *) mutableSectionsArray;
}

+ (void) sort{
    [self.all sortUsingComparator:^NSComparisonResult(Book *a, Book *b){return [a.title compare:b.title];}];
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

@end

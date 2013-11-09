//
//  NewBookViewController.m
//  Bukini
//
//  Created by Paweł Ksieniewicz on 09.11.2013.
//  Copyright (c) 2013 Paweł Ksieniewicz. All rights reserved.
//

#import "BookViewController.h"

@interface BookViewController () <UIAlertViewDelegate> {
    UIAlertView *missingAlert, *googleIsStupidAlert;
    BOOL showScanner;
}

@end

@implementation BookViewController
@synthesize book;

- (void)viewDidLoad
{
    showScanner = YES;
    [super viewDidLoad];
    
    missingAlert = [[UIAlertView alloc] initWithTitle:@"Błąd"
                                              message:@"Czegoś brakuje"
                                             delegate:self
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles:nil];
    
    
    googleIsStupidAlert = [[UIAlertView alloc] initWithTitle:@"Książki nie ma w Google Books"
                                              message:@"Niestety, na tę chwilę, największa darmowa baza kodów ISBN nie zawiera tej książki. Musisz samodzielnie przepisać jej tytuł i autora z okładki. Albo ze strony tytułowej."
                                             delegate:self
                                    cancelButtonTitle:@"No trudno"
                                    otherButtonTitles:nil];
    
    if (book)
    {
        showScanner = NO;
        [self loadBook];
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void) loadBook{
    [_authorField setText:book.author];
    [_titleField setText:book.title];
    [_publisherField setText:book.publisher];
}

- (void) selectFirstEmptyField{
    if      (!_authorField.text.length)     [_authorField becomeFirstResponder];
    else if (!_titleField.text.length)      [_titleField becomeFirstResponder];
    else if (!_publisherField.text.length)  [_publisherField becomeFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self selectFirstEmptyField];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    if (showScanner)
    {
        showScanner = NO;
        ZBarReaderViewController *reader = [ZBarReaderViewController new];
        reader.readerDelegate = self;
        [reader.scanner setSymbology: ZBAR_QRCODE
                              config: ZBAR_CFG_ENABLE
                                  to: 0];
        reader.readerView.zoom = 1.0;
        
        [self presentViewController:reader
                           animated:YES
                         completion:nil];
    }
    else [self selectFirstEmptyField];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)save:(id)sender {
    if (!_authorField.text.length || !_titleField.text.length || !_publisherField.text.length)
    {
        [missingAlert show];
    }
    else
    {
        if (!book)
        {
            NSLog(@"Save new");
            // New Book
            book = Book.new;
            book.author = _authorField.text;
            book.title = _titleField.text;
            book.publisher = _publisherField.text;
            
            [Book addBook:book];
        }
        else
        {
            
            NSLog(@"Edit old");
            // Edit book
            Book *newBook = Book.new;
            newBook.author = _authorField.text;
            newBook.title = _titleField.text;
            newBook.publisher = _publisherField.text;
            
            [Book saveBook:newBook
                  overBook:book];
            
        }
    
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)nextField:(id)sender {
    if (sender == _authorField) [_titleField becomeFirstResponder];
    if (sender == _titleField) [_publisherField becomeFirstResponder];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results) break;
    
    NSString *ISBN = symbol.data;
    
    NSLog(@"ISBN:%@", ISBN);
    
    NSData *myData = [[NSData alloc]initWithContentsOfURL:[NSURL.alloc initWithString:[NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=isbn:%@", ISBN]]];
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:myData options:NSJSONReadingMutableContainers error:nil];
    
    if ([response[@"totalItems"] intValue]) {
        NSLog(@"We have a book!");
        
        NSDictionary *item = [response[@"items"] firstObject];
        
        
        book = [Book bookWithVolumeInfoDictionary:item[@"volumeInfo"]];
        [self loadBook];
        [reader dismissViewControllerAnimated:YES
                                   completion:nil];
    }
    else{
        [reader dismissViewControllerAnimated:YES
                                   completion:nil];
        [googleIsStupidAlert show];
    }
}

@end

//
//  ViewController.m
//  FormattedCurrencyInput
//
//  Created by Peter Boni on 4/07/13.
//  Copyright (c) 2013 Peter Boni. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize textField = _textField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _textField.delegate = self;

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:2];

    NSString *currencySymbol = [[numberFormatter currencySymbol] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [numberFormatter setPositivePrefix:currencySymbol];
    [numberFormatter setPositiveSuffix:@""];

    _textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:0]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)valueButton:(id)sender
{
    NSString *textFieldStr = [NSString stringWithFormat:@"%@", _textField.text];

    NSMutableString *textFieldStrValue = [NSMutableString stringWithString:textFieldStr];

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

    NSString *currencySymbol = [[numberFormatter currencySymbol] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [numberFormatter setPositivePrefix:currencySymbol];
    [numberFormatter setPositiveSuffix:@""];

    [textFieldStrValue replaceOccurrencesOfString:currencySymbol
                                       withString:@""
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, [textFieldStrValue length])];

    [textFieldStrValue replaceOccurrencesOfString:numberFormatter.groupingSeparator
                                       withString:@""
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, [textFieldStrValue length])];

    NSDecimalNumber *textFieldNum = [NSDecimalNumber decimalNumberWithString:textFieldStrValue];

    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:[NSString stringWithFormat:@"Value: %@, Number: %@", textFieldStr, textFieldNum]
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSInteger MAX_DIGITS = 11; // $999,999,999.99

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:2];

    // Set currency symbol as prefix
    NSString *currencySymbol = [[numberFormatter currencySymbol] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [numberFormatter setPositivePrefix:currencySymbol];
    [numberFormatter setPositiveSuffix:@""];

    NSString *stringMaybeChanged = [NSString stringWithString:string];
    if (stringMaybeChanged.length > 1)
    {
        NSMutableString *stringPasted = [NSMutableString stringWithString:stringMaybeChanged];

        [stringPasted replaceOccurrencesOfString:currencySymbol
                                      withString:@""
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [stringPasted length])];

        [stringPasted replaceOccurrencesOfString:numberFormatter.groupingSeparator
                                      withString:@""
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [stringPasted length])];

        NSDecimalNumber *numberPasted = [NSDecimalNumber decimalNumberWithString:stringPasted];
        stringMaybeChanged = [numberFormatter stringFromNumber:numberPasted];
    }

    UITextRange *selectedRange = [textField selectedTextRange];
    UITextPosition *start = textField.beginningOfDocument;
    NSInteger cursorOffset = [textField offsetFromPosition:start toPosition:selectedRange.start];
    NSMutableString *textFieldTextStr = [NSMutableString stringWithString:textField.text];
    NSUInteger textFieldTextStrLength = textFieldTextStr.length;

    [textFieldTextStr replaceCharactersInRange:range withString:stringMaybeChanged];

    [textFieldTextStr replaceOccurrencesOfString:currencySymbol
                                  withString:@""
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [textFieldTextStr length])];

    [textFieldTextStr replaceOccurrencesOfString:numberFormatter.groupingSeparator
                                      withString:@""
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [textFieldTextStr length])];

    [textFieldTextStr replaceOccurrencesOfString:numberFormatter.decimalSeparator
                                      withString:@""
                                         options:NSLiteralSearch
                                           range:NSMakeRange(0, [textFieldTextStr length])];

    if (textFieldTextStr.length <= MAX_DIGITS)
    {
        NSDecimalNumber *textFieldTextNum = [NSDecimalNumber decimalNumberWithString:textFieldTextStr];
        NSDecimalNumber *divideByNum = [[[NSDecimalNumber alloc] initWithInt:10] decimalNumberByRaisingToPower:numberFormatter.maximumFractionDigits];
        NSDecimalNumber *textFieldTextNewNum = [textFieldTextNum decimalNumberByDividingBy:divideByNum];
        NSString *textFieldTextNewStr = [numberFormatter stringFromNumber:textFieldTextNewNum];

        textField.text = textFieldTextNewStr;

        if (cursorOffset != textFieldTextStrLength)
        {
            NSInteger lengthDelta = textFieldTextNewStr.length - textFieldTextStrLength;
            NSInteger newCursorOffset = MAX(0, MIN(textFieldTextNewStr.length, cursorOffset + lengthDelta));
            UITextPosition* newPosition = [textField positionFromPosition:textField.beginningOfDocument offset:newCursorOffset];
            UITextRange* newRange = [textField textRangeFromPosition:newPosition toPosition:newPosition];
            [textField setSelectedTextRange:newRange];
        }
    }

    return NO;
}

@end
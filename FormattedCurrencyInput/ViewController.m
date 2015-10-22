//
//  ViewController.m
//  FormattedCurrencyInput
//
//  Created by Peter Boni on 4/07/13.
//  Copyright (c) 2013 Peter Boni. All rights reserved.
//

#import "ViewController.h"

static NSUInteger const kMaxLength = 11;

typedef NS_ENUM(NSUInteger, InputType) {
    InputTypeRegular,
    InputTypeSuffix
};

@interface ViewController ()<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UITextField *suffixField;

@property (nonatomic, strong) NSNumberFormatter *regularFormatter;
@property (nonatomic, strong) NSNumberFormatter *suffixFormatter;

- (IBAction)valueButton:(id)sender;

@end

@implementation ViewController

@synthesize textField = _textField;

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textField.text = [self.regularFormatter stringFromNumber:@0];
    self.suffixField.text = [self.suffixFormatter stringFromNumber:@0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.textField becomeFirstResponder];
}

#pragma mark - Accessors
- (NSNumberFormatter *) regularFormatter
{
    if (_regularFormatter)
    {
        return _regularFormatter;
    }
    
    _regularFormatter = [[NSNumberFormatter alloc] init];
    _regularFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    _regularFormatter.maximumFractionDigits = 2;
    _regularFormatter.minimumFractionDigits = 2;
    
    return _regularFormatter;
}

- (NSNumberFormatter *) suffixFormatter
{
    if (_suffixFormatter)
    {
        return _suffixFormatter;
    }
    
    _suffixFormatter = [[NSNumberFormatter alloc] init];
    _suffixFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    _suffixFormatter.positiveFormat = @"#,##0.00¤";
    _suffixFormatter.negativeFormat = @"(#,##0.00¤";
    _suffixFormatter.currencySymbol = @"YTL";
    
    return _suffixFormatter;
}

#pragma mark - private
- (NSString *) valueFromString:(NSString *)string
{
    NSCharacterSet *valueSet= [[NSCharacterSet characterSetWithCharactersInString:@"0123456789,."] invertedSet];
    return [[[string componentsSeparatedByCharactersInSet:valueSet] componentsJoinedByString:@""] mutableCopy];
}

- (NSString *) numberFromString:(NSString *)string
{
    NSCharacterSet *numberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    return [[[string componentsSeparatedByCharactersInSet:numberSet] componentsJoinedByString:@""] mutableCopy];
}

- (NSDecimalNumber *) dividerForFormatter:(NSNumberFormatter *)formatter
{
    return [[[NSDecimalNumber alloc] initWithInt:10] decimalNumberByRaisingToPower:formatter.maximumFractionDigits];
}

- (NSString *) alertTextForField:(UITextField *)field formatter:(NSNumberFormatter *)formatter
{
    NSDecimalNumber *textFieldNum = [NSDecimalNumber decimalNumberWithString:[self numberFromString:field.text]];
    textFieldNum = [textFieldNum decimalNumberByDividingBy:[self dividerForFormatter:formatter]];
    return [NSString stringWithFormat:@"Value:%@\nNumber:%@", field.text, textFieldNum];
}

#pragma mark - Action
- (IBAction)valueButton:(id)sender
{
    NSString *regular = [self alertTextForField:self.textField formatter:self.regularFormatter];
    NSString *suffix = [self alertTextForField:self.suffixField formatter:self.suffixFormatter];
    NSString *message = [NSString stringWithFormat:@"Regular\n%@\n\nSuffix\n%@", regular, suffix];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSNumberFormatter *formatter;
    
    if (textField.tag == InputTypeSuffix)
    {
        formatter = self.suffixFormatter;
    }
    else
    {
        formatter = self.regularFormatter;
    }
    
    NSString *stringMaybeChanged = [NSString stringWithString:string];
    if (stringMaybeChanged.length > 1)
    {
        NSMutableString *stringPasted = [NSMutableString stringWithString:stringMaybeChanged];
        stringPasted = [[self numberFromString:stringPasted] mutableCopy];
        NSDecimalNumber *numberPasted = [NSDecimalNumber decimalNumberWithString:stringPasted];
        stringMaybeChanged = [formatter stringFromNumber:numberPasted];
    }
    
    UITextRange *selectedRange = [textField selectedTextRange];
    UITextPosition *start = textField.beginningOfDocument;
    NSInteger cursorOffset = [textField offsetFromPosition:start toPosition:selectedRange.start];
    NSMutableString *textFieldTextStr = [NSMutableString stringWithString:textField.text];
    NSUInteger textFieldTextStrLength = textFieldTextStr.length;
    
    NSUInteger originalLength = textFieldTextStr.length;
    textFieldTextStr = [[self valueFromString:textFieldTextStr] mutableCopy];
    NSUInteger newLength = textFieldTextStr.length;
    range.location += newLength - originalLength;
    
    [textFieldTextStr replaceCharactersInRange:range withString:stringMaybeChanged];
    textFieldTextStr = [[self numberFromString:textFieldTextStr] mutableCopy];
    
    if (textFieldTextStr.length <= kMaxLength)
    {
        NSDecimalNumber *textFieldTextNum = [NSDecimalNumber decimalNumberWithString:textFieldTextStr];
        NSDecimalNumber *divideByNum = [self dividerForFormatter:formatter];
        NSString *textFieldTextNewStr;
        
        if (!isnan(textFieldTextNum.doubleValue))
        {
            NSDecimalNumber *textFieldTextNewNum = [textFieldTextNum decimalNumberByDividingBy:divideByNum];
            textFieldTextNewStr = [formatter stringFromNumber:textFieldTextNewNum];
        }
        
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
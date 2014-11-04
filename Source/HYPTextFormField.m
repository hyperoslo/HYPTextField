//
//  HYPTextField.m

//
//  Created by Elvis Nunez on 07/10/14.
//  Copyright (c) 2014 Hyper. All rights reserved.
//

#import "HYPTextFormField.h"

#import "HYPTextFieldTypeManager.h"

@interface HYPTextFormField () <UITextFieldDelegate>

@property (nonatomic, getter = isModified) BOOL modified;

@end

@implementation HYPTextFormField

@synthesize rawText = _rawText;

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.delegate = self;

    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = self.defaultBorderColor;
    self.layer.cornerRadius = 5.0f;
    self.backgroundColor = self.defaultBackgroundColor;

    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 20.0f)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;

    [self addTarget:self action:@selector(textFieldDidUpdate:) forControlEvents:UIControlEventEditingChanged];

    return self;
}

#pragma mark - Setters

- (void)setText:(NSString *)text
{
    if (text.length > super.text.length) {
        NSRange range = NSMakeRange(text.length, 0);
        UITextPosition *beginning = self.beginningOfDocument;
        UITextPosition *start     = [self positionFromPosition:beginning offset:range.location];
        UITextPosition *end       = [self positionFromPosition:start offset:range.length];
        UITextRange *newRange     = [self textRangeFromPosition:start toPosition:end];
        [self setSelectedTextRange:newRange];
        [super setText:text];
    } else {
        UITextRange *selectedRange  = [self selectedTextRange];
        [super setText:text];
        [self setSelectedTextRange:selectedRange];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];

    if (enabled) {
        self.backgroundColor = self.defaultBackgroundColor;
        self.layer.borderColor = self.defaultBorderColor;
    } else {
        self.backgroundColor = self.disabledBackgroundColor;
        self.layer.borderColor = self.disabledBorderColor;
    }
}

- (void)setRawText:(NSString *)rawText
{
    if (self.formatter && rawText.length > _rawText.length) {
        self.text = [self.formatter formatString:rawText reverse:NO];
    } else {
        self.text = rawText;
    }

    _rawText = rawText;
}

- (void)setValid:(BOOL)valid
{
    _valid = valid;

    if (!self.isEnabled) return;

    if (valid) {
        self.backgroundColor = self.defaultBackgroundColor;
        self.layer.borderColor = self.defaultBorderColor;
    } else {
        self.backgroundColor = self.invalidBackgroundColor;
        self.layer.borderColor = self.invalidBorderColor;
    }
}

- (void)setTypeString:(NSString *)typeString
{
    _typeString = typeString;

    HYPTextFieldType type;
    if ([typeString isEqualToString:@"name"]) {
        type = HYPTextFieldTypeName;
    } else if ([typeString isEqualToString:@"username"]) {
        type = HYPTextFieldTypeUsername;
    } else if ([typeString isEqualToString:@"phone"]) {
        type = HYPTextFieldTypePhoneNumber;
    } else if ([typeString isEqualToString:@"number"]) {
        type = HYPTextFieldTypeNumber;
    } else if ([typeString isEqualToString:@"float"]) {
        type = HYPTextFieldTypeFloat;
    } else if ([typeString isEqualToString:@"address"]) {
        type = HYPTextFieldTypeAddress;
    } else if ([typeString isEqualToString:@"email"]) {
        type = HYPTextFieldTypeEmail;
    } else if ([typeString isEqualToString:@"date"]) {
        type = HYPTextFieldTypeDate;
    } else if ([typeString isEqualToString:@"select"]) {
        type = HYPTextFieldTypeDropdown;
    } else if ([typeString isEqualToString:@"text"]) {
        type = HYPTextFieldTypeDefault;
    } else if (!typeString.length) {
        type = HYPTextFieldTypeDefault;
    } else {
        type = HYPTextFieldTypeUnknown;
    }

    self.type = type;
}

- (void)setType:(HYPTextFieldType)type
{
    _type = type;

    HYPTextFieldTypeManager *typeManager = [[HYPTextFieldTypeManager alloc] init];
    [typeManager setUpType:type forTextField:self];
}

#pragma mark - Getters

- (NSString *)rawText
{
    if (_rawText && self.formatter) {
        return [self.formatter formatString:_rawText reverse:YES];
    }

    return _rawText;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(HYPTextFormField *)textField
{
    BOOL selectable = (textField.type == HYPTextFieldTypeDropdown || textField.type == HYPTextFieldTypeDate);

    if (selectable) {
        if ([self.textFieldDelegate respondsToSelector:@selector(hyp_textFieldDidBeginEditing:)]) {
            [self.textFieldDelegate hyp_textFieldDidBeginEditing:self];
        }
    }

    return !selectable;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.modified = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.textFieldDelegate respondsToSelector:@selector(hyp_textFieldDidEndEditing:)]) {
        [self.textFieldDelegate hyp_textFieldDidEndEditing:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string) return YES;

    BOOL validator = (self.inputValidator && [self.inputValidator respondsToSelector:@selector(validateReplacementString:withText:)]);

    if (validator) return [self.inputValidator validateReplacementString:string withText:self.rawText];

    return YES;
}

#pragma mark - UIResponder Overwritables

- (BOOL)becomeFirstResponder
{
    if (self.type == HYPTextFieldTypeDropdown || self.type == HYPTextFieldTypeDate) {
        if ([self.textFieldDelegate respondsToSelector:@selector(hyp_textFieldDidBeginEditing:)]) {
            [self.textFieldDelegate hyp_textFieldDidBeginEditing:self];
        }
    }

    return [super becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    if (self.type == HYPTextFieldTypeDropdown || self.type == HYPTextFieldTypeDate) return NO;

    return [super canBecomeFirstResponder];
}

#pragma mark - Notifications

- (void)textFieldDidUpdate:(UITextField *)textField
{
    if (!self.isValid) {
        self.valid = YES;
    }

    self.modified = YES;
    self.rawText = self.text;

    if ([self.textFieldDelegate respondsToSelector:@selector(hyp_textField:didUpdateWithText:)]) {
        [self.textFieldDelegate hyp_textField:self didUpdateWithText:self.rawText];
    }
}

@end

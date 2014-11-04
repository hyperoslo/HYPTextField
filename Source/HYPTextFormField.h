//
//  HYPTextField.h

//
//  Created by Elvis Nunez on 07/10/14.
//  Copyright (c) 2014 Hyper. All rights reserved.
//

@import UIKit;

#import "HYPInputValidator.h"

#import "HYPFormatter.h"

typedef NS_ENUM(NSInteger, HYPTextFieldType) {
    HYPTextFieldTypeDefault = 0,
    HYPTextFieldTypeName,
    HYPTextFieldTypeUsername,
    HYPTextFieldTypePhoneNumber,
    HYPTextFieldTypeNumber,
    HYPTextFieldTypeFloat,
    HYPTextFieldTypeAddress,
    HYPTextFieldTypeEmail,
    HYPTextFieldTypePassword,
    HYPTextFieldTypeDropdown,
    HYPTextFieldTypeDate,
    HYPTextFieldTypeUnknown
};

@protocol HYPTextFieldDelegate;

@interface HYPTextField : UITextField

@property (nonatomic, copy) NSString *rawText;

@property (nonatomic, copy) NSString *typeString;

@property (nonatomic) HYPTextFieldType type;

@property (nonatomic, getter = isValid) BOOL valid;

@property (nonatomic, strong) HYPFormatter *formatter;

@property (nonatomic, strong) HYPInputValidator *inputValidator;

@property (nonatomic, weak) id <HYPTextFieldDelegate> textFieldDelegate;

@property (nonatomic) UIColor *defaultBackgroundColor;
@property (nonatomic) UIColor *defaultBorderColor;

@property (nonatomic) UIColor *selectedBackgroundColor;
@property (nonatomic) UIColor *selectedBorderColor;

@property (nonatomic) UIColor *invalidBackgroundColor;
@property (nonatomic) UIColor *invalidBorderColor;

@property (nonatomic) UIColor *disabledBackgroundColor;
@property (nonatomic) UIColor *disabledBorderColor;

@end

@protocol HYPTextFieldDelegate <NSObject>

@optional

- (void)hyp_textFieldDidBeginEditing:(HYPTextFormField *)textField;

- (void)hyp_textFieldDidEndEditing:(HYPTextFormField *)textField;

- (void)hyp_textField:(HYPTextFormField *)textField didUpdateWithText:(NSString *)text;

@end
